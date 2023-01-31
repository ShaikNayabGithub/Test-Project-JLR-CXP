public class PrimaryAccount_AccountCreator {

    public static void CreateAccounts(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        Id individualRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id corporateRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualGoldenRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id corporateGoldenRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : newAccounts){
            if(oldAccountMap != null && oldAccountMap.containsKey(acc.Id) && oldAccountMap.get(acc.Id).Create_Golden_Record__c == false && acc.Create_Golden_Record__c == true){
                if(acc.RecordTypeId == individualRecordTypeId || acc.RecordTypeId == corporateRecordTypeId){
                    if(acc.Is_Primary__c == false){
                        accountsToUpdate.add(acc);
                        accountIds.add(acc.Id);
                    }
                }
            }
        }
        if(accountsToUpdate.size() > 0){
            //need to identify the corresponding Dummy User for the Account's Country ISO Code, or the Owner's Country ISO Code or Market
            Map<Id, Account> accountOwnerDetails = new Map<Id, Account>([SELECT Id, Country_ISO_Code__c, Owner.Country_ISO_Code__c, Owner.Market__c FROM Account WHERE Id IN :accountIds]);
            List<User> dummyUsers = [SELECT Id, Name, UserRole.DeveloperName, Country_ISO_Code__c FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE DeveloperName LIKE '%DUMMY%') AND UserType='Standard' AND IsActive = true];
            List<Account> goldenRecords = new List<Account>();
            //for each Account, set the Record Type Id, tick Is Primary, remove Primary Account, remove Owner Retailer, set Account Owner
            for(Account acc : accountsToUpdate){
                Account gracc = acc.clone(false, false, false, false);
                gracc.Is_Primary__c = true;
                gracc.VITAL_Ref__c = null;
                gracc.Primary_Account__c = null;
                gracc.Owner_Retailer__c = null;
                gracc.Create_Golden_Record__c = false;
                if(acc.RecordTypeId == individualRecordTypeId){
                    gracc.RecordTypeId = individualGoldenRecordTypeId;
                }
                else if(acc.RecordTypeId == corporateRecordTypeId){
                    gracc.RecordTypeId = corporateGoldenRecordTypeId;
                }
                grAcc.OwnerId = null;
                if(acc.Country_ISO_Code__c != null){
                    for(User u : dummyUsers){
                        if(u.Country_ISO_Code__c == acc.Country_ISO_Code__c){
                            grAcc.OwnerId = u.Id;
                            break;
                        }
                    }
                }
                if(grAcc.OwnerId == null){
                    if(accountOwnerDetails.containsKey(acc.Id)){
                        Account ownerAcc = accountOwnerDetails.get(acc.Id);
                        if(ownerAcc != null){
                            if(ownerAcc.Owner.Country_ISO_Code__c != null){
                                for(User u : dummyUsers){
                                    if(u.Country_ISO_Code__c == ownerAcc.Owner.Country_ISO_Code__c){
                                        grAcc.OwnerId = u.Id;
                                        break;
                                    }
                                }
                            }
                            if(grAcc.OwnerId == null){
                                if(ownerAcc.Owner.Market__c != null){
                                    for(User u : dummyUsers){
                                        if(u.Name.toUpperCase().contains(ownerAcc.Owner.Market__c.toUpperCase())){
                                            grAcc.OwnerId = u.Id;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(grAcc.OwnerId == null){
                    grAcc.OwnerId = acc.OwnerId;
                }
                grAcc.DMS_Identifier__c = null; //have to remove DMS_Identifier__c as this is a unique field
                grAcc.Bronze_Record_Id__c = acc.Id;
                goldenRecords.add(grAcc);
            }
            if(goldenRecords.size() > 0){
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.AllowSave = true;
                Database.insert(goldenRecords, dml);
            }        
        }
    }

}