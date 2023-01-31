//created By Masthan Andela as part of Golden Record Change

public class PrimaryAccountUpserter {
    public static Map<String, List<Account>> accountMap = new Map<String, List<Account>>(); //mapping of child Account Name/Last Name to list of potential Primary Accounts
    public static Map<Id, Account> updateAccountMap;
    
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    
    public static Set<String> individualAccountMatchList; //{'PersonEmail','Phone','PersonMobilePhone','PersonMailingStreet'};
    public static Set<String> corporateAccountMatchList; //{'Retailer_Email__c','Phone','BillingStreet'};
    public static Set<String> excludedEmailList;
    
    public static List<Account> accountsUpdatedOnPreInsert = new List<Account>();
   
    //search for existing Primary Accounts and add Id to 'child' Accounts where relevant
    public static void AccountPreInsert(List<Account> triggerNew){
        //if Owner_Retailer__c is blank, this Account needs to be converted to a Primary Account, otherwise, a Primary Account needs to be created and linked
        List<Account> retailerAccounts = new List<Account>();
        for(Account acc : triggerNew){
                // // System.debug('HERE AccountPreInsert acc.Is_Primary__c '+   acc.Is_Primary__c);
            if(acc.Owner_Retailer__c != null && !acc.Is_Primary__c){
                if(acc.Primary_Account__c == null && acc.Primary_Account__pc == null){
                    retailerAccounts.add(acc);
                }
            }
            else{
                //acc.Is_Primary__c = true; //this causes the Duplicate Detection Rules to not run - set this through a Workflow instead
                SetPrimaryDataEnrichmentPriorityValues(acc);
            }
        }
        if(retailerAccounts.size() > 0){
            //getMatchingFields(); //populate individualAccountMatchList and corporateAccountMatchList (from Custom Metadata Type)
            List<Account> primaryAccounts = getPrimaryAccounts(retailerAccounts); //construct map accountMap (map of Name/Last Name as key to list of potential Primary Accounts)
           SYSTEM.debug('HERE primaryAccounts'+primaryAccounts);
            if(primaryAccounts.size() > 0){
                accountMap = createAccountMap(primaryAccounts);
                SYSTEM.debug('HERE accountMap'+accountMap);
                SYSTEM.debug('HERE HERE accountMap'+Json.serializePretty(accountMap)  );
            }
            primaryAccountUpdate(retailerAccounts, accountMap); //update Primary_Account__c field for each record in triggerNew
        }
    }
    
    public static Map<String, List<Account>> createAccountMap(List<Account> primaryAccounts) {
        Map<String, List<Account>> mapNameToPotentialAccounts = new Map<String, List<Account>>();
        System.debug('PRIMARY ACCOUNTS: ' + primaryAccounts);
        if(primaryAccounts != null || primaryAccounts.size() > 0){
            for(Account primaryAccount : primaryAccounts){
                String mapKey;
                if(primaryAccount.RecordTypeId == goldenCorporateRecordType ){
                    mapKey = primaryAccount.Name.toLowerCase();
                }
                else{
                    mapKey = primaryAccount.LastName.toLowerCase();
                }
                if(mapKey != null && !mapNameToPotentialAccounts.containskey(mapKey)){
                    mapNameToPotentialAccounts.put(mapKey, new List<Account>());
                }
                mapNameToPotentialAccounts.get(mapKey).add(primaryAccount);                                           
            }
        }
        return mapNameToPotentialAccounts;
    }
    
    public static void AccountPostInsert(List<Account> triggerNew) {
        //individualAccountMatchList and corporateAccountMatchList should be populated from preInsert
        //accountMap will not contain any matches for the Accounts that haven't had Primary Account populated
        //need to loop through list of triggerNew and determine whether any Accounts don't have Primary Account populated
        List<Account> missingPrimaryAccount = new List<Account>();
        List<Account> newPrimaryAccounts = new List<Account>();
        getMatchingFields();
        for(Account acc : triggerNew){
            if(acc.Owner_Retailer__c != null && !acc.Is_Primary__c && acc.Primary_Account__c == null && acc.Country_ISO_Code__c != null){
              //Australia excluded to prevent duplicates while contact matching in place, as they online provide 1 piece of info
                if( (acc.RecordTypeId == corporateRecordType && acc.Country_ISO_Code__c != 'AU')||acc.RecordTypeId == individualRecordType){

                    missingPrimaryAccount.add(acc);
                    //need to create Primary Accounts for these accounts - there may be more than one Account that links to one Primary Account
                    Account primaryAccount = acc.clone(false, false, false, false);
                    primaryAccount.Is_Primary__c = true;
                    primaryAccount.Owner_Retailer__c = null;
                    primaryAccount.Bronze_Record_Id__c = acc.id;
                    boolean newPrimary = true;
                    Set<String> fieldMatchList;
                    if(primaryAccount.RecordTypeId == corporateRecordType){
                        fieldMatchList = corporateAccountMatchList;
                        primaryAccount.RecordTypeId = goldenCorporateRecordType;
                    }
                    else if(primaryAccount.RecordTypeId == individualRecordType){
                        fieldMatchList = individualAccountMatchList;
                        primaryAccount.RecordTypeId = goldenIndividualRecordType;
                    }
                    for(Account dupePrimary : newPrimaryAccounts){
                        boolean isDupe = false;
                        if(primaryAccount.Country_ISO_Code__c == dupePrimary.Country_ISO_Code__c){
                            if((primaryAccount.RecordTypeId == goldenCorporateRecordType && primaryAccount.Name.toLowerCase() == dupePrimary.Name.toLowerCase()) || (primaryAccount.RecordTypeId == goldenIndividualRecordType && primaryAccount.LastName.toLowerCase() == dupePrimary.LastName.toLowerCase())){
                                for(String accountField : fieldMatchList){
                                    if(primaryAccount.get(accountField) != null && primaryAccount.get(accountField) == dupePrimary.get(accountField)){
                                        isDupe = true;
                                        newPrimary = false;
                                    }
                                }
                                if(isDupe){
                                    for(String accountField : fieldMatchList){
                                        if(primaryAccount.get(accountField) != null && dupePrimary.get(accountField) == null){
                                            dupePrimary.put(accountField, primaryAccount.get(accountField));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(newPrimary){
                        SetPrimaryDataEnrichmentPriorityValues(primaryAccount);
                        newPrimaryAccounts.add(primaryAccount);
                    }
                }
            }
        }
        if(newPrimaryAccounts.size() > 0){ //insert new Primary Accounts
            SetPrimaryOwners(newPrimaryAccounts);
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(newPrimaryAccounts, dml);
            //now we have the inserted Primary Accounts, we need to populate the corresponding 'child' Accounts with the right Primary Account id
            Map<String, List<Account>> postInsertPrimaryMap = new Map<String, List<Account>>();
            String mapKey;
            for(Account primaryAccount : newPrimaryAccounts){
                if(primaryAccount.RecordTypeId == goldenCorporateRecordType ){
                    mapKey = primaryAccount.Name.toLowerCase();
                }
                else{
                    mapKey = primaryAccount.LastName.toLowerCase();
                }
                if(mapKey != null && !postInsertPrimaryMap.containsKey(mapKey)){
                    postInsertPrimaryMap.put(mapKey, new List<Account>());
                }
                postInsertPrimaryMap.get(mapKey).add(primaryAccount);
            }
            if(postInsertPrimaryMap.size() > 0){
                primaryAccountUpdate(missingPrimaryAccount, postInsertPrimaryMap);
            }
        }
        if(updateAccountMap != null && updateAccountMap.size() > 0){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.update(updateAccountMap.values(), dml);
        }
        UpdateFieldsOnExistingPrimaryAccounts(); //if we have created new INDIVIDUAL Account records which have updated existing Primary Accounts, we need to update the Primary Accounts depending on the Data Enrichment Priority rules
    }
   
    private static void primaryAccountUpdate(List<Account> triggerNew, Map<String, List<Account>> potentialPrimaryAccounts){
        //getPrimaryAccounts(triggerNew); //construct map accountMap (map of Name/Last Name as key to list of potential Primary Accounts)
        if(potentialPrimaryAccounts != null && potentialPrimaryAccounts.size() > 0){   
            updateAccountMap = new Map<Id, Account>();   
            for(Account account : triggerNew){ //for each account from trigger
                if(!account.Is_Primary__c && account.Primary_Account__c == null){ //as long as it's a child account that doesn't currently have a Primary Account value
                    if(account.RecordTypeId == corporateRecordType && potentialPrimaryAccounts.containskey(account.Name.toLowerCase())){
                        Account primaryAcc = getPrimaryAccountId(account, potentialPrimaryAccounts, false); //lookup the primary account using field criteria
                        if(primaryAcc != null){
                            if(account.Id != null) updateAccountMap.put(account.Id, new Account(Id = account.id, Primary_Account__c = primaryAcc.Id)); //postinsert
                            else account.Primary_Account__c = primaryAcc.Id;  //preinsert
                        }
                    }
                    else if(account.RecordTypeId == individualRecordType && potentialPrimaryAccounts.containskey(account.LastName.toLowerCase())){
                        Account primaryAcc = getPrimaryAccountId(account, potentialPrimaryAccounts, true); //lookup the primary account using field criteria
                        if(primaryAcc != null){
                            if(account.Id != null) updateAccountMap.put(account.Id, new Account(Id = account.id, Primary_Account__c = primaryAcc.Id, PersonIndividualId = primaryAcc.PersonIndividualId, Primary_Account__pc = primaryAcc.Id)); //postinsert
                            else{ //preinsert
                                account.Primary_Account__c = primaryAcc.Id;
                                account.Primary_Account__pc = primaryAcc.Id;
                                account.PersonIndividualId = primaryAcc.PersonIndividualId;
                                accountsUpdatedOnPreInsert.add(account);
                            }
                        }
                    }
                }
            }       
        }
    }
    
    public static Account getPrimaryAccountId(Account newAccount, Map<String, List<Account>> primaryAccountMap, Boolean isPersonAccount){
        SYSTEM.debug('HERE getPrimaryAccountId');
        SYSTEM.debug('HERE newAccount '+newAccount);
          SYSTEM.debug('HERE primaryAccountMap '+primaryAccountMap);
        String mapKey ;
        Set<String> fieldMatchList = new Set<String>();
        getMatchingFields();
        if(isPersonAccount){
            mapKey = newAccount.LastName.toLowerCase();
            fieldMatchList = individualAccountMatchList;
        SYSTEM.debug('HERE mapKey '+mapKey);
        SYSTEM.debug('HERE fieldMatchList '+fieldMatchList);
        }else{
            mapKey = newAccount.Name.toLowerCase();
            fieldMatchList = corporateAccountMatchList;
        }
    
        if(excludedEmailList == null){
            excludedEmailList = new Set<String>();
            Map < String, Primary_Account_Excluded_Emails__mdt > retrieveCustomMetadataMap = Primary_Account_Excluded_Emails__mdt.getAll();
            // for(Primary_Account_Excluded_Emails__mdt dummyEmail : [Select MasterLabel FROM Primary_Account_Excluded_Emails__mdt]){
            for(Primary_Account_Excluded_Emails__mdt dummyEmail : retrieveCustomMetadataMap.values()){
                excludedEmailList.add(dummyEmail.MasterLabel);
            }
        }
        
        for(Account primaryAccount : primaryAccountMap.get(mapKey)){
            SYStem.debug('primaryAccount' +primaryAccount);
                 SYStem.debug('primaryAccount.id' +primaryAccount.Id);
             
            if(newAccount.Country_ISO_Code__c != null && primaryAccount.Country_ISO_Code__c == newAccount.Country_ISO_Code__c ){ 
                
                if(  primaryAccount.Bronze_Record_Id__c != null && primaryAccount.Bronze_Record_Id__c == newAccount.id){
                 return   primaryAccount;
                }
                for(String accountField : fieldMatchList){
                       SYStem.debug('FINAL primaryAccount.get(accountField)' +primaryAccount.get(accountField));
                        SYStem.debug('FINAL newAccount.get(accountField)' +newAccount.get(accountField));
                    if(newAccount.get(accountField) != null && primaryAccount.get(accountField) == newAccount.get(accountField)){
              //if matching field equals one of the excluded email values, this is not a match
                        if(!excludedEmailList.contains(''+newAccount.get(accountField))){
                            return primaryAccount;
                        }
                    }
                }      
            }                
        }
        return null;
    }
    
    public static List<Account> getPrimaryAccounts(List<Account> accounts){
        
        // // System.debug('HERE getPrimaryAccounts');
        Set<String> indNameList = new Set<String>(); 
        Set<String> corpNameList = new Set<String>();  
        Set<String> indISOCodeList = new Set<String>();  
        Set<String> corpISOCodeList = new Set<String>();
        List<Account> PrimaryAccountList = new List<Account>();
        
        for(Account singleAccount : accounts){
            if(!singleAccount.Is_Primary__c && singleAccount.Primary_Account__c == null){
                      // // System.debug('HERE no primary');
                if(singleAccount.RecordTypeId == individualRecordType && String.IsNotBlank(singleAccount.LastName) && String.IsNotBlank(singleAccount.Country_ISO_Code__c)){                    
                    indNameList.add(singleAccount.LastName);
                    indISOCodeList.add(singleAccount.Country_ISO_Code__c);  
                }
                else if(singleAccount.RecordTypeId == corporateRecordType && String.IsNotBlank(singleAccount.Name) && String.IsNotBlank(singleAccount.Country_ISO_Code__c)){
                    corpNameList.add(singleAccount.Name);
                    corpISOCodeList.add(singleAccount.Country_ISO_Code__c);  
                }
            }
        }
        String query = getquery();
        if(indNameList.size() > 0 && indISOCodeList.size() > 0){
            String whereCondition = ' WHERE  LastName IN :indNameList AND (Country_ISO_Code__c IN :indISOCodeList) AND RecordTypeId = :goldenIndividualRecordType';
            try{
                List<Account> indPrimaryAccountList = Database.query(query + whereCondition);
                if(indPrimaryAccountList.size() > 0) PrimaryAccountList.addAll(indPrimaryAccountList);
            }
            catch(Exception e){
                EmailUtility.SendEmail(new List<String>{Label.PrimaryAccountQueryErrorEmail}, 'Primary Account Non Selective Query Error INDIVIDUAL', 'Primary Account Tracker', e.getMessage() + '- LastNames=' + indNameList + ', ISOCodes: ' + indISOCodeList + ', User: ' + UserInfo.getUserId());
            }
        }      
        if(corpNameList.size() > 0 && corpISOCodeList.size() > 0){
            String whereCondition = ' WHERE Name IN :corpNameList AND (Country_ISO_Code__c IN :corpISOCodeList) AND RecordTypeId = :goldenCorporateRecordType';
            try{
                List<Account> corpPrimaryAccountList = Database.query(query + whereCondition);
                if(corpPrimaryAccountList.size() > 0) PrimaryAccountList.addAll(corpPrimaryAccountList);
            }
            catch(Exception e){
                EmailUtility.SendEmail(new List<String>{Label.PrimaryAccountQueryErrorEmail}, 'Primary Account Non Selective Query Error CORPORATE', 'Primary Account Tracker', e.getMessage() + '- Names=' + corpNameList + ', ISOCodes: ' + corpISOCodeList + ', User: ' + UserInfo.getUserId());
            }
        }
        SYSTEM.debug('HERE HERE PrimaryAccountList '+PrimaryAccountList);
        return PrimaryAccountList;
    }
    
    private static void UpdateFieldsOnExistingPrimaryAccounts() {
        //construct a map of (primary) Account Id to (child) Account and obtain list of Primary Accounts
        Map<Id, Account> primaryAccountUpdateMap = new Map<Id, Account>();
        for(Account acc : accountsUpdatedOnPreInsert){ //for every (Retailer) Account whose Primary Account was updated with an existing Primary Account...
            if(acc.Primary_Account__c != null){
                if(primaryAccountUpdateMap.containsKey(acc.Primary_Account__c)){ //if this is a second Retailer Account with the same Primary Account, update the field value if it is currently blank
                    Account dupeAcc = primaryAccountUpdateMap.get(acc.Primary_Account__c);
                    for(String individualField : individualAccountMatchList){
                        if(dupeAcc.get(individualField) == null && acc.get(individualField) != null){
                            dupeAcc.put(individualField, acc.get(individualField));
                        }
                    }
                    primaryAccountUpdateMap.put(dupeAcc.Primary_Account__c, dupeAcc);
                }
                else{
                    primaryAccountUpdateMap.put(acc.Primary_Account__c, acc);
                }
            }
        }
        //now we have a Map of Primary Account Id and field changes (that we can pass to PrimaryAccountUpdateHandler.UpdatePrimaryAccounts)
        if(primaryAccountUpdateMap != null && primaryAccountUpdateMap.size() > 0){
            List<Account> primaryAccounts = new List<Account>();
            for(List<Account> grList : accountMap.values()){ //we already have a list of Primary Accounts to update
                primaryAccounts.addAll(grList);
            }
            if(primaryAccounts != null && primaryAccounts.size() > 0){
                PrimaryAccountUpdateHandler.UpdatePrimaryAccounts(primaryAccountUpdateMap, primaryAccounts);
            }
        }
    }
    
    private static void SetPrimaryDataEnrichmentPriorityValues(Account acc) {
        List<Primary_Account_Update_Conditions_Acc__mdt> updateConditions = PrimaryAccountUpdateHandler.getUpdateConditions();
        String currentUserProfileName = PrimaryAccountUpdateHandler.getCurrentUserProfileName();
        if(acc.RecordTypeId == goldenIndividualRecordType ){
            for(Primary_Account_Update_Conditions_Acc__mdt conditionField : updateConditions){
                if(conditionField.User_Profile__c == null || currentUserProfileName == conditionField.User_Profile__c){
                    acc.Data_Enrichment_Priority_Level__c = conditionField.Active_Priority_Level_Value__c;
                    acc.Data_Enrichment_Priority_Effective_To__c = PrimaryAccountUpdateHandler.setPriorityDate(conditionField.Active_Priority_Date_Value__c);
                }
            }
        }
    }
    
    public static String buildQuery() {
        getmatchingfields();
        return getquery();
    }
    
    private static String getquery(){
        String query ='SELECT Id, Name,Bronze_Record_Id__c , RecordTypeId, Country_ISO_Code__c, IsPersonAccount, PersonIndividualId, Data_Enrichment_Priority_Level__c, Data_Enrichment_Priority_Effective_To__c';
        Set<String> allfields = new Set<String>();
        getMatchingFields();
        allfields.addAll(corporateAccountMatchList);
        allfields.addAll(individualAccountMatchList);
        allfields.addAll(PrimaryAccountUpdateHandler.individualPiiFields);
        
        for(String field : allfields){
            query += ', ' + field;
        }
        
        return query + ' FROM Account';
    }
    
    private static void getMatchingFields(){
        if(individualAccountMatchList == null || corporateAccountMatchList == null){
            individualAccountMatchList = new Set<String>();
            corporateAccountMatchList = new Set<String>();
            Map < String, Primary_Account_Matching_Fields__mdt > retrieveCustomMetadataMap = Primary_Account_Matching_Fields__mdt.getAll();
            // for(Primary_Account_Matching_Fields__mdt field: [Select Id, Label, Account_Type__c, Field_API_Name__c FROM Primary_Account_Matching_Fields__mdt]){
            for(Primary_Account_Matching_Fields__mdt field: retrieveCustomMetadataMap.values()){
                if(field.Account_Type__c == 'Individual'){
                    individualAccountMatchList.add(field.Field_API_Name__c);
                }else if(field.Account_Type__c == 'Corporate'){
                    corporateAccountMatchList.add(field.Field_API_Name__c);
                }
            }
        }
    }
    
    public static void SetPrimaryOwners(List<Account> goldenRecords) {
         // // System.debug('HERE SetPrimaryOwners');
        //Map<String, Id> isoCodeDummyUsers = new Map<String, Id>();
        Id systemUserId;
        Set<Id> grOwnerIds = new Set<Id>();
        for(Account acc : goldenRecords){
            if(acc.OwnerId != null){
                grOwnerIds.add(acc.OwnerId);
            }
        }
        List<User> dummyUsers = [SELECT Id, Name, UserRole.DeveloperName, Country_ISO_Code__c, Market__c FROM User WHERE ( (UserRole.DeveloperName LIKE '%DUMMY%' AND UserType='Standard') OR UserRole.DeveloperName = 'Account_Contact_Owner_Role' OR Id IN :grOwnerIds) AND IsActive = true];
        for(User u : dummyUsers){
            if(u.UserRole.DeveloperName.equalsIgnoreCase('Account_Contact_Owner_Role')){
                if(u.Name.equalsIgnoreCase('SYSTEM USER')){
                    systemUserId = u.Id;
                }
            }
        }
        for(Account gr : goldenRecords){
            Id currentOwnerId = gr.OwnerId;
            gr.OwnerId = null;
            if(gr.Country_ISO_Code__c != null){
                for(User u : dummyUsers){
                    if(u.UserRole.DeveloperName.toUpperCase().contains('DUMMY') && u.Country_ISO_Code__c == gr.Country_ISO_Code__c){
                        gr.OwnerId = u.Id;
                    }
                }
            }
            if(gr.OwnerId == null){
                for(User u : dummyUsers){
                    if(u.Id == currentOwnerId && u.Country_ISO_Code__c != null){
                        for(User du : dummyUsers){
                            if(du.UserRole.DeveloperName.toUpperCase().contains('DUMMY') && du.Country_ISO_Code__c == u.Country_ISO_Code__c){
                                gr.OwnerId = du.Id;
                            }
                        }
                    }
                }
            }
            if(gr.OwnerId == null){
                for(User u : dummyUsers){
                    if(u.Id == currentOwnerId && u.Market__c != null){
                        for(User du : dummyUsers){
                            if(du.UserRole.DeveloperName.toUpperCase().contains('DUMMY') && du.Name.toUpperCase().contains(u.Market__c.toUpperCase())){
                                gr.OwnerId = du.Id;
                            }
                        }
                    }
                }
            }
            if(gr.OwnerId == null){
                gr.OwnerId = systemUserId;
            }
        }
    }
    
    public static void SetOwnerRetailer(List<Account> newAccounts, Map<Id, Account> oldMap) {
        // // System.debug('HERE SetOwnerRetailer');
        Set<Id> ownerIds = new Set<Id>();
        List<Account> accountsWithNewOwner = new List<Account>();
        for(Account acc : newAccounts){
         //27012020  if(acc.RecordTypeId == corporateRecordType || acc.RecordTypeId == individualRecordType){
                boolean setOwnerRetailer = true;
                if(((oldMap == null || oldMap.containsKey(acc.Id) == false) && acc.Owner_Retailer__c == null) || (oldMap != null && oldMap.containsKey(acc.Id) && oldMap.get(acc.Id).OwnerId != acc.OwnerId)){
                    ownerIds.add(acc.OwnerId);
                    accountsWithNewOwner.add(acc);
                }
        //27012020   }
        }
        
        if(ownerIds.size() > 0){
            Map<Id, Id> ownerRetailerMap = new Map<Id, Id>();
            for(User u : [SELECT Id, Contact.AccountId FROM User WHERE Id IN :ownerIds AND ContactId != null AND Contact.AccountId != null]){
                ownerRetailerMap.put(u.Id, u.Contact.AccountId);
            }
            
          //  system.assertEquals(ownerRetailerMap.keyset().size(), 10);
            for(Account acc : accountsWithNewOwner){
                if(ownerRetailerMap.containsKey(acc.OwnerId)){
                    if(acc.RecordTypeId == goldenIndividualRecordType){
                        acc.RecordTypeId = individualRecordType;
                    
                    }
                     if(acc.RecordTypeId == goldenCorporateRecordType){
                        acc.RecordTypeId = corporateRecordType;
                   
                    }
                    acc.Owner_Retailer__c = ownerRetailerMap.get(acc.OwnerId);
                     // System.debug('HERE SetOwnerRetailer Owner_Retailer__c '+   acc.Owner_Retailer__c);
                }
                else{
                    acc.Owner_Retailer__c = null;
                    if(acc.RecordTypeId != retailerRecordType && acc.Country_ISO_Code__c != 'KR'){
                        acc.Is_Primary__c  = true; 
                    }
                   
                }
            }
        }
    }
    


public static void primaryAccountOwnerValidation(List<Account> newAccounts, Map<Id, Account> oldMap){
    
       
    Set<Id> ownerIds = new Set<Id>();
    List<Account> accountsWithNewOwner = new List<Account>();
    for(Account acc : newAccounts){
       // system.debug(acc.RecordTypeId + '%%%%%'+ goldenIndividualRecordType +'&&'+acc.Id+'****'+acc.OwnerId);
    
        if(acc.RecordTypeId == goldenIndividualRecordType || acc.RecordTypeId == goldenCorporateRecordType){
            ownerIds.add(acc.OwnerId);
                accountsWithNewOwner.add(acc);
        }
    }
    if(ownerIds.size() > 0){
        Map<Id, Id> ownerRetailerMap = new Map<Id, Id>();
        for(User u : [SELECT Id, Contact.AccountId FROM User WHERE Id IN :ownerIds AND ContactId != null AND Contact.AccountId != null]){
            ownerRetailerMap.put(u.Id, u.Contact.AccountId);
        }
        for(Account acc : accountsWithNewOwner){
            if(ownerRetailerMap.containsKey(acc.OwnerId) && !Test.isRunningTest()){
               // acc.addError('You can\'t update primary account owner. Retailer User can\'t own Primary Account');                
            }
        }
    }
}
}

/*
  public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();

*/