public class PrimaryAccountUpdateHandler {

    public static List<String> individualPiiFields = new List<String>{'Salutation', 'FirstName', 'LastName', 'PersonMailingStreet', 'PersonMailingState', 'PersonMailingPostalCode','PersonMailingCity','PersonMailingCountry','BillingStreet', 'BillingState','BillingCity','BillingPostalCode', 'BillingCountry', 'ShippingStreet', 'ShippingState','shippingcity','ShippingPostalCode', 'ShippingCountry',  'Phone', 'PersonMobilePhone', 'PersonEmail',
        'PersonHomePhone','PersonOtherPhone','Email2__pc','Email3__pc'};
    public static List<String> corporatePiiFields = new List<String>{'Name', 'BillingStreet','BillingCity','BillingState','BillingPostalCode', 'BillingCountry', 'ShippingStreet', 'shippingcity','ShippingState', 'ShippingPostalCode', 'ShippingCountry', 'Phone', 'Retailer_Email__c', 'Website'};
    
        public static List<String> allPiiFields = new List<String>{'Salutation','Name', 'FirstName', 'LastName', 'PersonMailingStreet', 'PersonMailingState', 'PersonMailingPostalCode','PersonMailingCity','PersonMailingCountry','BillingStreet', 'BillingState','BillingCity','BillingPostalCode', 'BillingCountry', 'ShippingStreet', 'ShippingState','shippingcity','ShippingPostalCode', 'ShippingCountry',  'Phone', 'PersonMobilePhone', 'PersonEmail',  'Retailer_Email__c', 'Website',
            'PersonHomePhone','PersonOtherPhone','Email2__pc','Email3__pc'};
  
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id individualPrimaryRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id corporatePrimaryRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    
    private static String currentUserProfileName;
    private static List<Primary_Account_Update_Conditions_Acc__mdt> metaUpdateConditions;

    //when an Account is updated, check whether any PII data has been updated and, if it has, check the corresponding PII data in the related Primary Account
    public static void CheckAccountsForUpdatedPII(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        system.debug('CheckAccountsForUpdatedPII');
        Map<Id, Account> primaryAccountMap = new Map<Id, Account>(); //map Primary Account Id to the changed Account fields
         Map<Id, Account> corpPrimaryAccountMap = new Map<Id, Account>(); //map Primary Account Id to the changed Account fields
        for(Account a : newAccounts){
            if(a.RecordTypeId == individualRecordType){ //only do this for Individual accounts
                if(oldAccountMap != null && oldAccountMap.containsKey(a.Id) && a.Primary_Account__c != null){ //if Account has a Primary Acount
                    if(individualPiiFields != null){
                        boolean piiDataChanged = false;
                        Account primaryAccountUpdate = new Account(Id=a.Primary_Account__c);
                        if(primaryAccountMap.containsKey(a.Primary_Account__c)){
                            primaryAccountUpdate = primaryAccountMap.get(a.Primary_Account__c);
                        }
                        SObject newAccountObj = (SObject)a; //new retailer account
                        SObject oldAccountObj = (SObject)oldAccountMap.get(a.Id); //old retailer account
                        for(String fieldName : individualPiiFields){
                            if(newAccountObj.get(fieldName) != null && newAccountObj.get(fieldName) != oldAccountObj.get(fieldName)){ //if field has been changed (and is non null)
                                piiDataChanged = true;
                                primaryAccountUpdate.put(fieldName, newAccountObj.get(fieldName)); //add the field value to the new Primary Account
                            }
                        }
                        if(piiDataChanged){
                            primaryAccountMap.put(primaryAccountUpdate.Id, primaryAccountUpdate); //add to map for given Primary Account (can be multiple Retailer Accounts per Primary Account)
                        }
                    }
                }
            }
                 if(a.RecordTypeId == corporateRecordType){ //only do this for accounts
                if(oldAccountMap != null && oldAccountMap.containsKey(a.Id) && a.Primary_Account__c != null){ //if Account has a Primary Acount
                  // system.debug('corp account has primary');
                    
                    if(corporatePiiFields != null){
                        boolean piiDataChanged = false;
                        Account primaryAccountUpdate = new Account(Id=a.Primary_Account__c);
                        if(corpPrimaryAccountMap.containsKey(a.Primary_Account__c)){
                            primaryAccountUpdate = corpPrimaryAccountMap.get(a.Primary_Account__c);
                        }
                        SObject newAccountObj = (SObject)a; //new retailer account
                        SObject oldAccountObj = (SObject)oldAccountMap.get(a.Id); //old retailer account
                        for(String fieldName : corporatePiiFields){
                            if(newAccountObj.get(fieldName) != null && newAccountObj.get(fieldName) != oldAccountObj.get(fieldName)){ //if field has been changed (and is non null)
                                piiDataChanged = true;
                                      system.debug('corp account has changed');
                                primaryAccountUpdate.put(fieldName, newAccountObj.get(fieldName)); //add the field value to the new Primary Account
                            }
                        }
                        if(piiDataChanged){
                            corpPrimaryAccountMap.put(primaryAccountUpdate.Id, primaryAccountUpdate); //add to map for given Primary Account (can be multiple Retailer Accounts per Primary Account)
                        }
                    }
                }
            }
            
          
        }
        if(primaryAccountMap.size() > 0){
            String soqlQuery = ConstructSOQLString();
            if(soqlQuery != null){
                Set<Id> primaryIds = primaryAccountMap.keySet();
                soqlQuery += ' AND Id IN :primaryIds';
                List<Account> primaryAccounts = Database.query(soqlQuery);
                UpdatePrimaryAccounts(primaryAccountMap, primaryAccounts); //need to check the existing field values on the Primary Accounts before changing them
            }
        }
                if(corpPrimaryAccountMap.size() > 0){
            String soqlQuery = ConstructCorpSOQLString();
            if(soqlQuery != null){
                Set<Id> primaryIds = corpPrimaryAccountMap.keySet();
                soqlQuery += ' AND Id IN :primaryIds';
                List<Account> primaryAccounts = Database.query(soqlQuery);
                UpdatePrimaryAccounts(corpPrimaryAccountMap, primaryAccounts); //need to check the existing field values on the Primary Accounts before changing them
            }
        }
        
    }
    


    




    
    //given a Map of Primary Account Id to the new field values (in an Account), and the list of primary accounts to update
    public static void UpdatePrimaryAccounts(Map<Id, Account> primaryChildAccountMap, List<Account> primaryAccounts) {
        system.debug('UpdatePrimaryAccounts');
        //now have Map of Account field values that have changed, retrieve the values for the Primary Accounts
        List<Account> primaryAccountsToUpdate = new List<Account>();
        for(Account primaryAcc : primaryAccounts){
            if(primaryAcc.RecordTypeId == individualPrimaryRecordType){
                if(primaryChildAccountMap.containsKey(primaryAcc.Id)){
                    Account updatedPrimaryAccount = UpdatePrimaryAccount(primaryAcc, primaryChildAccountMap.get(primaryAcc.Id)); //set the new field values if criteria passes
                    if(updatedPrimaryAccount != null){
                        primaryAccountsToUpdate.add(updatedPrimaryAccount);
                    }
                }
            }
                  if(primaryAcc.RecordTypeId == corporatePrimaryRecordType){
                       system.debug('primary an corp');
                if(primaryChildAccountMap.containsKey(primaryAcc.Id)){
                    Account updatedPrimaryAccount = UpdateCorporatePrimaryAccount(primaryAcc, primaryChildAccountMap.get(primaryAcc.Id)); //set the new field values if criteria passes
                    if(updatedPrimaryAccount != null){
                        primaryAccountsToUpdate.add(updatedPrimaryAccount);
                    }
                }
            }
        }
        if(primaryAccountsToUpdate.size() > 0){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.update(primaryAccountsToUpdate, dml);
        }
    }
    
     private static Account UpdateCorporatePrimaryAccount(Account primaryAccount, Account childAccount) {
                system.debug('UpdateCorporatePrimaryAccount');
        //loop through each PII field on childAccount and, depending on conditions, update the field on primaryAccount
        Account updatedPrimaryAccount = null;
        SObject primaryAccountObj = (SObject)primaryAccount;
        SObject childAccountObj = (SObject)childAccount;
        List<Primary_Account_Update_Conditions_Acc__mdt> updateConditions = getUpdateConditions();
        //condition 1 - if Primary Account field value is null, update the field from the Child Account
        for(String fieldName : corporatePiiFields){
            if(primaryAccountObj.get(fieldName) == null && childAccountObj.get(fieldName) != null){
                System.debug('Field ' + fieldName + ' has been set from blank to ' + childAccountObj.get(fieldName));
                if(updatedPrimaryAccount == null){
                    updatedPrimaryAccount = new Account(Id=primaryAccount.Id);
                }
                updatedPrimaryAccount.put(fieldName, childAccountObj.get(fieldName));
            }
            if(primaryAccountObj.get(fieldName) != null && childAccountObj.get(fieldName) != null && primaryAccountObj.get(fieldName) != childAccountObj.get(fieldName)  ){
                System.debug('Field ' + fieldName + ' has been changed from '+primaryAccountObj.get(fieldName)+' to ' + childAccountObj.get(fieldName));
                if(updatedPrimaryAccount == null){
                    updatedPrimaryAccount = new Account(Id=primaryAccount.Id);
                }
                updatedPrimaryAccount.put(fieldName, childAccountObj.get(fieldName));
            }
            System.debug('Updated Primary Account: ' + updatedPrimaryAccount);
        }
        //take other conditions from Metadata Type
        for(Primary_Account_Update_Conditions_Acc__mdt conditionField : updateConditions){
            if(conditionField.User_Profile__c == null || getCurrentUserProfileName() == conditionField.User_Profile__c){
                System.debug('User Profile allowed to run condition ' + conditionField);
                if(conditionField.Priority_Level_Condition__c == null || primaryAccount.Data_Enrichment_Priority_Level__c == null || primaryAccount.Data_Enrichment_Priority_Level__c <= conditionField.Priority_Level_Condition__c || primaryAccount.Data_Enrichment_Priority_Effective_To__c == null || primaryAccount.Data_Enrichment_Priority_Effective_To__c < Date.today()){
                    System.debug('Level Condition: ' + conditionField.Priority_Level_Condition__c + ', GR Priority: ' +  primaryAccount.Data_Enrichment_Priority_Level__c + ', GR Date: ' + primaryAccount.Data_Enrichment_Priority_Effective_To__c);
                    //update the data on the Primary Account including the Priority Levels
                    if(updatedPrimaryAccount == null){
                        updatedPrimaryAccount = new Account(Id=primaryAccount.Id);
                    }
                    if(primaryAccount.Data_Enrichment_Priority_Effective_To__c == null || primaryAccount.Data_Enrichment_Priority_Effective_To__c <= Date.today()){
                        updatedPrimaryAccount.Data_Enrichment_Priority_Level__c = conditionField.Expired_Priority_Level_Value__c;
                        updatedPrimaryAccount.Data_Enrichment_Priority_Effective_To__c = setPriorityDate(conditionField.Expired_Priority_Date_Value__c);
                        System.debug('Current policy out of date - setting date to ' + conditionField.Expired_Priority_Date_Value__c);
                    }
                    else{
                        updatedPrimaryAccount.Data_Enrichment_Priority_Level__c = conditionField.Active_Priority_Level_Value__c;
                        Date newDate = setPriorityDate(conditionField.Active_Priority_Date_Value__c);
                        if(newDate != null){
                            updatedPrimaryAccount.Data_Enrichment_Priority_Effective_To__c = newDate;
                        }
                        System.debug('Current policy active - setting date to ' + conditionField.Active_Priority_Date_Value__c);
                    }
                    for(String fieldName : individualPiiFields){
                        if(childAccountObj.get(fieldName) != null){
                            updatedPrimaryAccount.put(fieldName, childAccountObj.get(fieldName));
                        }
                    }
                    System.debug('Updated Primary Account: ' + updatedPrimaryAccount);
                }
            }
        }
        return updatedPrimaryAccount;
    }
    
    
    
    private static Account UpdatePrimaryAccount(Account primaryAccount, Account childAccount) {
        //loop through each PII field on childAccount and, depending on conditions, update the field on primaryAccount
        Account updatedPrimaryAccount = null;
        SObject primaryAccountObj = (SObject)primaryAccount;
        SObject childAccountObj = (SObject)childAccount;
        List<Primary_Account_Update_Conditions_Acc__mdt> updateConditions = getUpdateConditions();
        //condition 1 - if Primary Account field value is null, update the field from the Child Account
        for(String fieldName : individualPiiFields){
            if(primaryAccountObj.get(fieldName) == null && childAccountObj.get(fieldName) != null){
                System.debug('Field ' + fieldName + ' has been set from blank to ' + childAccountObj.get(fieldName));
                if(updatedPrimaryAccount == null){
                    updatedPrimaryAccount = new Account(Id=primaryAccount.Id);
                }
                updatedPrimaryAccount.put(fieldName, childAccountObj.get(fieldName));
            }
            System.debug('Updated Primary Account: ' + updatedPrimaryAccount);
        }
        //take other conditions from Metadata Type
        for(Primary_Account_Update_Conditions_Acc__mdt conditionField : updateConditions){
            if(conditionField.User_Profile__c == null || getCurrentUserProfileName() == conditionField.User_Profile__c){
                System.debug('User Profile allowed to run condition ' + conditionField);
                if(conditionField.Priority_Level_Condition__c == null || primaryAccount.Data_Enrichment_Priority_Level__c == null || primaryAccount.Data_Enrichment_Priority_Level__c <= conditionField.Priority_Level_Condition__c || primaryAccount.Data_Enrichment_Priority_Effective_To__c == null || primaryAccount.Data_Enrichment_Priority_Effective_To__c < Date.today()){
                    System.debug('Level Condition: ' + conditionField.Priority_Level_Condition__c + ', GR Priority: ' +  primaryAccount.Data_Enrichment_Priority_Level__c + ', GR Date: ' + primaryAccount.Data_Enrichment_Priority_Effective_To__c);
                    //update the data on the Primary Account including the Priority Levels
                    if(updatedPrimaryAccount == null){
                        updatedPrimaryAccount = new Account(Id=primaryAccount.Id);
                    }
                    if(primaryAccount.Data_Enrichment_Priority_Effective_To__c == null || primaryAccount.Data_Enrichment_Priority_Effective_To__c <= Date.today()){
                        updatedPrimaryAccount.Data_Enrichment_Priority_Level__c = conditionField.Expired_Priority_Level_Value__c;
                        updatedPrimaryAccount.Data_Enrichment_Priority_Effective_To__c = setPriorityDate(conditionField.Expired_Priority_Date_Value__c);
                        System.debug('Current policy out of date - setting date to ' + conditionField.Expired_Priority_Date_Value__c);
                    }
                    else{
                        updatedPrimaryAccount.Data_Enrichment_Priority_Level__c = conditionField.Active_Priority_Level_Value__c;
                        Date newDate = setPriorityDate(conditionField.Active_Priority_Date_Value__c);
                        if(newDate != null){
                            updatedPrimaryAccount.Data_Enrichment_Priority_Effective_To__c = newDate;
                        }
                        System.debug('Current policy active - setting date to ' + conditionField.Active_Priority_Date_Value__c);
                    }
                    for(String fieldName : individualPiiFields){
                        if(childAccountObj.get(fieldName) != null){
                            updatedPrimaryAccount.put(fieldName, childAccountObj.get(fieldName));
                        }
                    }
                    System.debug('Updated Primary Account: ' + updatedPrimaryAccount);
                }
            }
        }
        return updatedPrimaryAccount;
    }
    
    private static String ConstructSOQLString() {
        String soqlFields = '';
        for(String s : allPiiFields){
            soqlFields += ',' + s;
        }
        if(soqlFields.length() > 0){
            return 'SELECT Id, RecordTypeId, Data_Enrichment_Priority_Level__c, Data_Enrichment_Priority_Effective_To__c' + soqlFields + ' FROM Account WHERE Is_Primary__c = true ';
        }
        return null;
    }
    
      private static String ConstructCorpSOQLString() {
        String soqlFields = '';
        for(String s : allPiiFields){
            soqlFields += ',' + s;
        }
        if(soqlFields.length() > 0){
            return 'SELECT Id, RecordTypeId, Data_Enrichment_Priority_Level__c, Data_Enrichment_Priority_Effective_To__c' + soqlFields + ' FROM Account WHERE Is_Primary__c = true ';
        }
        return null;
    }
    
    public static List<Primary_Account_Update_Conditions_Acc__mdt> getUpdateConditions() {
        if(metaUpdateConditions == null){
            metaUpdateConditions = [SELECT User_Profile__c, Priority_Level_Condition__c, Active_Priority_Level_Value__c, Active_Priority_Date_Value__c, Expired_Priority_Level_Value__c, Expired_Priority_Date_Value__c FROM Primary_Account_Update_Conditions_Acc__mdt ORDER BY Active_Priority_Level_Value__c DESC];
        }
        return metaUpdateConditions;
    }
    
    public static String getCurrentUserProfileName() {
        if(currentUserProfileName == null){
            for(Profile p : [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()]){
                currentUserProfileName = p.Name;
            }
        }
        return currentUserProfileName;
    }
    
    public static Date setPriorityDate(Decimal numMonthsToAdd) {
        if(numMonthsToAdd == null || numMonthsToAdd == 0){
            return null;
        }
        else{
            return Date.today().addMonths((Integer)numMonthsToAdd);
        }
    }

}