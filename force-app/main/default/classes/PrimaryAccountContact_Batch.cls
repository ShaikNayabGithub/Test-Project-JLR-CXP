global class PrimaryAccountContact_Batch implements Database.batchable<sObject>, Database.Stateful {
    //Database.executebatch(new PrimaryAccountContact_Batch('AU'), 20);
    //  //Database.executebatch(new PrimaryAccountContact_Batch('AU', '2'), 20);
    Static final List<String> NOTIFICATION_EMAILS = Label.IMS_BATCH_NOTIFICATION_EMAILS.split(','); 
    Static final Integer BATCH_SIZE = Integer.ValueOf(Label.IMS_BATCH_REQUEST_SIZE);
    string Query,errMsg = ''; 
    String IsoCountryCode = '';
       boolean insertNewAccounts = true; 
  boolean matchOnDotNames = true; 
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();    
    public static Id retailerContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
    public static Id jlrContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    Public static Map<string, User> ownerMap;
    
    Integer counter = 0;
    
    global PrimaryAccountContact_Batch(string countryCode, string limitNum) {  
        
        IsoCountryCode = countryCode;
        
        
        
        Query = 'select id, AccountId,Title,Primary_Contact__c, HomePhone,FirstName,LastName,Country_ISO_Code__c,RecordTypeId,Gender__c, Phone, MobilePhone, Email, OtherPhone, Email2__c, Email3__c from Contact where  ';
        Query += ' Data_Quality_No_Contact_Details__c = false and  account.Data_Quality_Recordtype_Mismatch__c = false and account.country_iso_code__c = \'' + IsoCountryCode + '\' and Primary_Contact__c = null and RecordTypeId =  \'' + retailerContactRecordType + '\'  LIMIT ' + limitNum + '   ';
        
    }
           global PrimaryAccountContact_Batch(string countryCode, string limitNum,  boolean dotMatch) {  
        
        IsoCountryCode = countryCode;
        //insertNewAccounts = createNewAccounts;
        matchOnDotNames = dotMatch;
        
        Query = 'select id, AccountId,Title,Primary_Contact__c, HomePhone,FirstName,LastName,Country_ISO_Code__c,RecordTypeId,Gender__c, Phone, MobilePhone, Email, OtherPhone, Email2__c, Email3__c from Contact where  ';
        Query += ' Data_Quality_No_Contact_Details__c = false and  account.Data_Quality_Recordtype_Mismatch__c = false and account.country_iso_code__c = \'' + IsoCountryCode + '\' and Primary_Contact__c = null  and  RecordTypeId =  \'' + retailerContactRecordType + '\'  LIMIT ' + limitNum + '   ';
        
    }
    
    
       global PrimaryAccountContact_Batch(string countryCode,string name, string limitNum,  boolean dotMatch) {  
        
        IsoCountryCode = countryCode;
        //insertNewAccounts = createNewAccounts;
        matchOnDotNames = dotMatch;
        
        Query = 'select id, AccountId,Title,Primary_Contact__c, HomePhone,FirstName,LastName,Country_ISO_Code__c,RecordTypeId,Gender__c, Phone, MobilePhone, Email, OtherPhone, Email2__c, Email3__c from Contact where  ';
        Query += ' Data_Quality_No_Contact_Details__c = false and  account.Data_Quality_Recordtype_Mismatch__c = false and account.country_iso_code__c = \'' + IsoCountryCode + '\' and Primary_Contact__c = null and Name = \'' + name + '\'  and  RecordTypeId =  \'' + retailerContactRecordType + '\'  LIMIT ' + limitNum + '   ';
        
    }
    
    global PrimaryAccountContact_Batch(string countryCode) {  
        
        IsoCountryCode = countryCode;
        
        
        
        Query = 'select id, AccountId,Title,Primary_Contact__c, HomePhone,FirstName,LastName,Country_ISO_Code__c,RecordTypeId,Gender__c, Phone, MobilePhone, Email, OtherPhone, Email2__c, Email3__c from Contact where  ';
        Query += ' Data_Quality_No_Contact_Details__c = false and  account.Data_Quality_Recordtype_Mismatch__c = false and account.country_iso_code__c = \'' + IsoCountryCode + '\' and Primary_Contact__c = null and RecordTypeId =  \'' + retailerContactRecordType + '\'   ';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        return Database.getQueryLocator(query);
    }  
    
    global void execute(Database.BatchableContext BC, List<Contact> contactsList)
    {   
        PrimaryAccountContactLogic prmla = new PrimaryAccountContactLogic();
        
        system.debug('contactsList '+contactsList);
        try {
            
            if(ownerMap == null){
                
                ownerMap = new Map<string, user>();
                //get Default owner e.g. default australia
                List<User> users = [SELECT Id, Name, UserRole.DeveloperName, Country_ISO_Code__c, Market__c FROM User WHERE (UserRole.DeveloperName LIKE '%DUMMY%') AND IsActive = true AND Country_ISO_Code__c != null AND UserType = 'Standard'];
                for(User dummy : users){
                    if(!ownerMap.containsKey(dummy.Country_ISO_Code__c)){
                        ownerMap.put(dummy.Country_ISO_Code__c, dummy);
                    }
                }
                
            }
            Set<Id> accountIds = new Set<Id>();
            for(Contact cont : contactsList){
                accountIds.add(cont.accountId);
            }
            
            PrimaryAccountContactGateway gateway = new PrimaryAccountContactGateway();
            
            List<Account> accs = gateway.getSecondaryAccountDetails(accountIds);
            Map<Id,Account> accountsWithNoPrimaryMap = new  Map<Id,Account>();
            List<Contact> contactsWithNoPrimaryAccount = new List<Contact>();
            List<Contact> contactsWithExistingPrimaryAccount = new List<Contact>();
            Map<id,id> secondaryAccountIdPrimaryAccountIdMap = new Map<Id,Id>();
            Map<Id, List<Contact>> primaryAccountIdSecondaryContactsMap = new Map<Id,List<Contact>>();
            for(Contact c : contactsList){
                for(Account ac :accs ){
                    if(c.AccountId == ac.id && ac.Primary_Account__c == null){
                        contactsWithNoPrimaryAccount.add(c);
                        if(accountsWithNoPrimaryMap == null || !accountsWithNoPrimaryMap.containsKey(ac.id) ){
                            accountsWithNoPrimaryMap.put(ac.id,ac); 
                        }
                        
                    }
                    
                    if(c.AccountId == ac.id && ac.Primary_Account__c != null){
                       
                        contactsWithExistingPrimaryAccount.add(c);
                        secondaryAccountIdPrimaryAccountIdMap.put(c.AccountId,ac.Primary_Account__c);
                        if(primaryAccountIdSecondaryContactsMap.containsKey(ac.Primary_Account__c)){
                            List<Contact> contacts = primaryAccountIdSecondaryContactsMap.get(ac.Primary_Account__c);
                            contacts.add(c);
                            primaryAccountIdSecondaryContactsMap.put(ac.Primary_Account__c, contacts);
                        } else {
                            primaryAccountIdSecondaryContactsMap.put(ac.Primary_Account__c, new List<Contact>{ c });
                        }
                        
                    }
                }
                
            }
            
            if(!contactsWithExistingPrimaryAccount.isEmpty()){
                prmla.preCreateSecondaryContactExistingPrimaryAccount(matchOnDotNames, contactsWithExistingPrimaryAccount,  primaryAccountIdSecondaryContactsMap, secondaryAccountIdPrimaryAccountIdMap, true);
                
            }
            
            if(!contactsWithNoPrimaryAccount.isEmpty()){
                prmla.preCreateSecondaryContactNoPrimaryAccount(matchOnDotNames, contactsWithNoPrimaryAccount, accountsWithNoPrimaryMap, true  );
                
            }
            
            
            
            
            
        } catch (Exception e) { 
            errMsg +=  e.getMessage() + '----' + e.getStackTraceString() + '\n'; 
        } 
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        if (string.isNotEmpty(errMsg)){
            Integration_Log__c il = new Integration_Log__c();
            il.Service__c = 'contactBatchUpdate';
            il.Apex_Log__c = errMsg;
            insert il;
            // SELECT Id, Service__c, System_Error__c, Apex_Log__c FROM Integration_Log__c
            //    EmailUtility.SendEmail(NOTIFICATION_EMAILS, 'PrimaryAccountContact_Batch', 'BatchIMSDeltaProcessor Status Report - ' + system.now(),'<pre>'+errMsg+'</pre>'); 
        } 
    }
    
}