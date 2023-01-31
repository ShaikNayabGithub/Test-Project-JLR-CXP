public class RecordSharer  {
    //Schema.DescribeFieldResult ACCOUNT_RETAIL_OWNER_FIELD = Schema.Account.Retailer_Owner_Account__c.getDescribe();
    Schema.DescribeFieldResult RECORDSHARE_RETAILER_FIELD = Schema.Record_Share__c.Retailer__c.getDescribe();
    public static Boolean DisableRecordSharing = false;
    
    public static Map < Id, User > ownerUserMap = new Map < Id, User > ();

    //only called in AccountHandler
    public void Share_Accounts(List<Account> records){
        if(DisableRecordSharing) return; //Used to reduce complexity in selected unit tests

        //Set<String> ownerIds = SObjectUtilities.GetFieldValues(records, 'Pseudo_Account_Owner__c');
        Set<String> ownerIds = SObjectUtilities.GetFieldValues(records, 'OwnerId');
        Set<String> accountIds = SObjectUtilities.GetFieldValues(records, 'Id');
        Map<Id,List<Account>> recordsRetailerId = new Map<Id,List<Account>>();// = SObjectUtilities.MapByIdField(records,ACCOUNT_RETAIL_OWNER_FIELD);

        // Map<Id,User> ownerUsers = new Map<Id,User>([Select Id, Contact.accountId From User Where Id in : ownerIds]);
        
        // Code Optmization to avoid SOQL-101 Error - CXPD-1670
        Boolean runUserQuery = false;
        for(Id ownId: ownerIds) {
            if(!ownerUserMap.containsKey(ownId)) {
                runUserQuery = true;
            }
        }
        if(runUserQuery) {
            for(User userObj: [Select Id, Contact.accountId From User Where Id in : ownerIds]) {
                ownerUserMap.put(userObj.Id, userObj);
            }
        }
        Map < Id, User > ownerUsers = ownerUserMap;
        
        //Create map of records by retailer
        for(Account account : records){
            if(ownerUsers.containsKey(account.OwnerId)){
                User ownerUser = ownerUsers.get(account.OwnerId);

                if(ownerUser.ContactId == null || ownerUser.Contact.AccountId == null) continue; //User is not a partner user?

                if(!recordsRetailerId.containsKey(ownerUser.Contact.AccountId)){
                    recordsRetailerId.put(ownerUser.Contact.AccountId, new List<Account>());
                }
                recordsRetailerId.get(ownerUser.Contact.AccountId).add(account); //map of User's related Contact Account Id -> list related accounts
            }
        }           
        
        if(recordsRetailerId == null || recordsRetailerId.size() == 0){
            return;
        }

        List<SObject> retailUsers = [Select id,  Account__c, Account_Case__c, Account_Opportunity__c, Retailer__c, User__c
                                                FROM Record_Share__c 
                                                WHERE Retailer__c in : recordsRetailerId.keySet() And Account__c != null and User__r.IsActive = true]; //get list of Record Shares currently associated with Retailer

        Map<Id,List<SObject>> retailerUserByRetailerId = SObjectUtilities.MapByIdField(retailUsers, RECORDSHARE_RETAILER_FIELD);

        List<AccountShare> sharesToAdd = new List<AccountShare>();                  
        for(Id retailerId : recordsRetailerId.keySet()){
            
            List<SObject> retailerUsers = retailerUserByRetailerId.get(retailerId);

            if(retailerUsers != null && retailerUsers.size() > 0){
                for(sObject userSetting :  retailerUsers){
                    Record_Share__c userShare = (Record_Share__c) userSetting;
                    List<SObject> retailerRecords = recordsRetailerId.get(retailerId);

                    for(SObject record : retailerRecords){
                        if(((Account)record).ownerId == userShare.User__c) continue;
                        
                        AccountShare share = new AccountShare();
                        share.UserOrGroupId = userShare.user__c;
                        share.AccountId = record.id;
                        share.AccountAccessLevel = userShare.Account__c;
                        share.CaseAccessLevel = 'none';
                        share.OpportunityAccessLevel = 'none';
                        share.RowCause = 'Manual';                      
                        sharesToAdd.add(share);
                    }
                }
            }
        }
        if(sharesToAdd.size() > 0){
            insert sharesToAdd;
        }
    }

    public void Share_Opportunities(List<Opportunity> records){
        if(DisableRecordSharing) return; //Used to reduce complexity in selected unit tests
        
        Set<String> ownerIds = SObjectUtilities.GetFieldValues(records, 'OwnerId');
        Map<Id,List<Opportunity>> recordsRetailerId = new Map<Id,List<Opportunity>>();// = SObjectUtilities.MapByIdField(records,ACCOUNT_RETAIL_OWNER_FIELD);

        // Map<Id,User> ownerUsers = new Map<Id,User>([Select Id, Contact.accountId From User Where Id in : ownerIds and Contact.accountId != null]);
        
        // Code Optmization to avoid SOQL-101 Error - CXPD-1670
        Boolean runUserQuery = false;
        for(Id ownId: ownerIds) {
            if(!ownerUserMap.containsKey(ownId)) {
                runUserQuery = true;
            }
        }
        if(runUserQuery) {
            for(User userObj: [Select Id, Contact.accountId From User Where Id in : ownerIds]) {
                ownerUserMap.put(userObj.Id, userObj);
            }
        }
        Map < Id, User > ownerUsers = ownerUserMap;
        
        //Create map of records by retailer
        for(Opportunity opportunityRecord : records){
            if(ownerUsers.containsKey(opportunityRecord.ownerid)){
                User ownerUser = ownerUsers.get(opportunityRecord.ownerid);
                if(ownerUser.Contact == null || ownerUser.Contact.AccountId == null) continue;
                if(!recordsRetailerId.containsKey(ownerUser.Contact.AccountId)){
                    recordsRetailerId.put(ownerUser.Contact.AccountId, new List<Opportunity>());
                }
                recordsRetailerId.get(ownerUser.Contact.AccountId).add(opportunityRecord);
            }
        }           

        if(recordsRetailerId == null || recordsRetailerId.size() == 0){
            return;
        }

        List<SObject> retailUsers = [Select id,  Account_Opportunity__c, Retailer__c, User__c
                                                FROM Record_Share__c 
                                                WHERE Retailer__c in : recordsRetailerId.keySet() And Account_Opportunity__c != null and User__r.IsActive = true];

        Map<Id,List<SObject>> retailerUserByRetailerId = SObjectUtilities.MapByIdField(retailUsers,RECORDSHARE_RETAILER_FIELD);

        List<OpportunityShare> sharesToAdd = new List<OpportunityShare>();                        
        for(Id retailerId : recordsRetailerId.keySet()){
            
            List<SObject> retailerUsers = retailerUserByRetailerId.get(retailerId);

            if(retailerUsers != null && retailerUsers.size() > 0){
                for(sObject userSetting :  retailerUsers){
                    Record_Share__c userShare = (Record_Share__c) userSetting;
                        List<SObject> retailerRecords = recordsRetailerId.get(retailerId);

                    for(SObject record : retailerRecords){
                        if(((Opportunity)record).ownerId == userShare.User__c) continue;

                        OpportunityShare share = new OpportunityShare();
                        share.UserOrGroupId = userShare.user__c;
                        share.OpportunityId = record.id;
                        share.OpportunityAccessLevel = userShare.Account_Opportunity__c;
                        share.RowCause = 'Manual';                      
                        sharesToAdd.add(share);
                    }
                }
            }
        }
        insert sharesToAdd;
    }

    public void Share_Cases(List<Case> records){
        if(DisableRecordSharing) return; //Used to reduce complexity in selected unit tests
        
        Set<String> ownerIds = SObjectUtilities.GetFieldValues(records, 'OwnerId');
        Map<Id,List<Case>> recordsRetailerId = new Map<Id,List<Case>>();// = SObjectUtilities.MapByIdField(records,ACCOUNT_RETAIL_OWNER_FIELD);

        // Map<Id,User> ownerUsers = new Map<Id,User>([Select Id, Contact.accountId From User Where Id in : ownerIds and Contact.accountId != null]);
        
        // Code Optmization to avoid SOQL-101 Error - CXPD-1670
        Boolean runUserQuery = false;
        for(Id ownId: ownerIds) {
            if(!ownerUserMap.containsKey(ownId)) {
                runUserQuery = true;
            }
        }
        if(runUserQuery) {
            for(User userObj: [Select Id, Contact.accountId From User Where Id in : ownerIds]) {
                ownerUserMap.put(userObj.Id, userObj);
            }
        }
        Map < Id, User > ownerUsers = ownerUserMap;
        
        //Create map of records by retailer
        for(Case caseRecord : records){
            if(ownerUsers.containsKey(caseRecord.ownerid)){
                User ownerUser = ownerUsers.get(caseRecord.ownerid);
                if(ownerUser.Contact == null || ownerUser.Contact.AccountId == null) continue;
                if(!recordsRetailerId.containsKey(ownerUser.Contact.AccountId)){
                    recordsRetailerId.put(ownerUser.Contact.AccountId, new List<Case>());
                }
                recordsRetailerId.get(ownerUser.Contact.AccountId).add(caseRecord);
            }
        }           
        
        if(recordsRetailerId == null || recordsRetailerId.size() == 0){
            return;
        }

        List<SObject> retailUsers = [Select id,  Account_Case__c, Retailer__c, User__c
                                                FROM Record_Share__c 
                                                WHERE Retailer__c in : recordsRetailerId.keySet() And Account_Case__c != null and User__r.IsActive = true];

        Map<Id,List<SObject>> retailerUserByRetailerId = SObjectUtilities.MapByIdField(retailUsers,RECORDSHARE_RETAILER_FIELD);

        List<CaseShare> sharesToAdd = new List<CaseShare>();                        
        for(Id retailerId : recordsRetailerId.keySet()){
            
            List<SObject> retailerUsers = retailerUserByRetailerId.get(retailerId);

            if(retailerUsers != null && retailerUsers.size() > 0){
                for(sObject userSetting :  retailerUsers){
                    Record_Share__c userShare = (Record_Share__c) userSetting;
                        List<SObject> retailerRecords = recordsRetailerId.get(retailerId);

                    for(SObject record : retailerRecords){
                        if(((Case)record).ownerId == userShare.User__c) continue;

                        CaseShare share = new CaseShare();
                        share.UserOrGroupId = userShare.user__c;
                        share.CaseId = record.id;
                        share.CaseAccessLevel = userShare.Account_Case__c;
                        share.RowCause = 'Manual';                      
                        sharesToAdd.add(share);
                    }
                }
            }
        }
        insert sharesToAdd;
    }

    public void Share_Leads(List<Lead> records){
        if(DisableRecordSharing) return; //Used to reduce complexity in selected unit tests

        Set<String> ownerIds = SObjectUtilities.GetFieldValues(records, 'OwnerId');
        Map<Id,List<Lead>> recordsRetailerId = new Map<Id,List<Lead>>();// = SObjectUtilities.MapByIdField(records,ACCOUNT_RETAIL_OWNER_FIELD);

        // Map<Id,User> ownerUsers = new Map<Id,User>([Select Id, Contact.accountId From User Where Id in : ownerIds and Contact.accountId != null]);
        
        // Code Optmization to avoid SOQL-101 Error - CXPD-1670
        Boolean runUserQuery = false;
        for(Id ownId: ownerIds) {
            if(!ownerUserMap.containsKey(ownId)) {
                runUserQuery = true;
            }
        }
        if(runUserQuery) {
            for(User userObj: [Select Id, Contact.accountId From User Where Id in : ownerIds]) {
                ownerUserMap.put(userObj.Id, userObj);
            }
        }
        Map < Id, User > ownerUsers = ownerUserMap;
        
        //Create map of records by retailer
        for(Lead lead : records){
            if(ownerUsers.containsKey(lead.ownerid)){
                User ownerUser = ownerUsers.get(lead.ownerid);
                if(ownerUser.Contact == null || ownerUser.Contact.AccountId == null) continue;
                if(!recordsRetailerId.containsKey(ownerUser.Contact.AccountId)){
                    recordsRetailerId.put(ownerUser.Contact.AccountId, new List<Lead>());
                }
                recordsRetailerId.get(ownerUser.Contact.AccountId).add(lead);
            }
        }       

        if(recordsRetailerId == null || recordsRetailerId.size() == 0){
            return;
        }       

        List<SObject> retailUsers = [Select id,  Lead__c, Retailer__c, User__c
                                                FROM Record_Share__c 
                                                WHERE Retailer__c in : recordsRetailerId.keySet() And Lead__c != null and User__r.IsActive = true];

        Map<Id,List<SObject>> retailerUserByRetailerId = SObjectUtilities.MapByIdField(retailUsers,RECORDSHARE_RETAILER_FIELD);

        List<LeadShare> sharesToAdd = new List<LeadShare>();                        
        for(Id retailerId : recordsRetailerId.keySet()){
            
            List<SObject> retailerUsers = retailerUserByRetailerId.get(retailerId);

            if(retailerUsers != null && retailerUsers.size() > 0){
                for(sObject userSetting :  retailerUsers){
                    Record_Share__c userShare = (Record_Share__c) userSetting;
                        List<SObject> retailerRecords = recordsRetailerId.get(retailerId);

                    for(SObject record : retailerRecords){
                        if(((Lead)record).ownerId == userShare.User__c) continue;

                        

                        LeadShare share = new LeadShare();
                        share.UserOrGroupId = userShare.user__c;
                        share.LeadId = record.id;
                        share.LeadAccessLevel = userShare.Lead__c;
                        share.RowCause = 'Manual';                      
                        sharesToAdd.add(share);
                    }
                }
            }
        }
        insert sharesToAdd;
    }

    public void Share_Campaign(List<Campaign> records){
        if(DisableRecordSharing) return; //Used to reduce complexity in selected unit tests
        Set<String> ownerIds = SObjectUtilities.GetFieldValues(records, 'OwnerId');
        Map<Id,List<Campaign>> recordsRetailerId = new Map<Id,List<Campaign>> ();// = SObjectUtilities.MapByIdField(records,ACCOUNT_RETAIL_OWNER_FIELD);

        // Map<Id,User> ownerUsers = new Map<Id,User>([Select Id, Contact.accountId From User Where Id in : ownerIds ]);
        
        // Code Optmization to avoid SOQL-101 Error - CXPD-1670
        Boolean runUserQuery = false;
        for(Id ownId: ownerIds) {
            if(!ownerUserMap.containsKey(ownId)) {
                runUserQuery = true;
            }
        }
        if(runUserQuery) {
            for(User userObj: [Select Id, Contact.accountId From User Where Id in : ownerIds]) {
                ownerUserMap.put(userObj.Id, userObj);
            }
        }
        Map < Id, User > ownerUsers = ownerUserMap;
        
        //Create map of records by retailer
        for(Campaign campaign : records){
            if(ownerUsers.containsKey(campaign.ownerid)){
                User ownerUser = ownerUsers.get(campaign.ownerid);
                if(ownerUser.ContactId == null || ownerUser.Contact.AccountId == null) continue;
                if(!recordsRetailerId.containsKey(ownerUser.Contact.AccountId)){
                    recordsRetailerId.put(ownerUser.Contact.AccountId, new List<Campaign>());
                }
                recordsRetailerId.get(ownerUser.Contact.AccountId).add(campaign);
            }
        }           
        
        if(recordsRetailerId == null || recordsRetailerId.size() == 0){
            return;
        }

        List<SObject> retailUsers = [Select id,  Campaign__c, Retailer__c, User__c
                                                FROM Record_Share__c 
                                                WHERE Retailer__c in : recordsRetailerId.keySet() And Campaign__c != null and User__r.IsActive = true];

        Map<Id,List<SObject>> retailerUserByRetailerId = SObjectUtilities.MapByIdField(retailUsers,RECORDSHARE_RETAILER_FIELD);

        List<CampaignShare> sharesToAdd = new List<CampaignShare>();                        
        for(Id retailerId : recordsRetailerId.keySet()){
            
            List<SObject> retailerUsers = retailerUserByRetailerId.get(retailerId);

            if(retailerUsers != null && retailerUsers.size() > 0){
                for(sObject userSetting :  retailerUsers){
                    Record_Share__c userShare = (Record_Share__c) userSetting;
                    List<SObject> retailerRecords = recordsRetailerId.get(retailerId);

                    for(SObject record : retailerRecords){
                        if(((Campaign)record).ownerId == userShare.User__c) continue;
                        CampaignShare share = new CampaignShare();
                        share.UserOrGroupId = userShare.user__c;
                        share.CampaignId = record.id;
                        share.CampaignAccessLevel = userShare.Campaign__c;
                        share.RowCause = 'Manual';                      
                        sharesToAdd.add(share);
                    }
                }
            }
        }
        insert sharesToAdd;
    }


/* LB- for now we will not be removing shares
    public void UnShareAccounts(Map<Id,Account> oldAccounts, List<Account> newAccounts){
        
       
            
        Set<Id> userIds = SObjectUtilities.GetFieldValuesId(oldAccounts.values(),'Pseudo_Account_Owner__c');
        userIds.addAll(SObjectUtilities.GetFieldValuesId(newAccounts,'Pseudo_Account_Owner__c'));


        //Get the pseudo users for these accounts
        Map<Id, User> users = new Map<Id,User>([Select Id, contact.Accountid from User
                                WHERE Id in : userIds]);
            
    Set<Id> sharesToRemove = new Set<Id>();     
                
        for(Account account : newAccounts){
            Account oldAccount = oldAccounts.get(account.id);
            //need to detect change of retailer in the pseudo users

            User oldUser = users.get(oldAccount.Pseudo_Account_Owner__c);
            User newUser = users.get(oldAccount.Pseudo_Account_Owner__c);
                        
            if(oldUser.Contact != null && oldUser.Contact.AccountId != null){
                //previous owner was a partner user

                if(newUser.ContactId == null || newUser.Contact.AccountId == null || newUser.Contact.AccountId != oldUser.Contact.AccountId){
                    sharesToRemove.add(account.Id);
                }
            }
        }

        if(sharesToRemove.size() == 0) return;

        Map<String, ObjectShareRecord__c> searchFirstShareMap = ObjectShareRecord__c.getAll();

        List<AccountShare> accountShares = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare 
                WHERE RowCause = 'Manual' AND Id NOT IN: searchFirstShareMap.keySet() 
                AND AccountId IN: sharesToRemove];

        delete accountShares;
    }
    */
}