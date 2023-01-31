public without sharing class  LCConvertAccountType_Controller {
    public static Id corporateRecordtypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id individualRecordtypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporatePrimaryRecordtypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public static Id individualPrimaryRecordtypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    
    
    @AuraEnabled
    public static Account getAccount(Id accountId) {
        return [SELECT Id,Recordtype.DeveloperName, (SELECT Id FROM contacts), Is_Primary__c, Primary_Account__c FROM Account WHERE Id =: accountId];
    }
    @AuraEnabled
    public static String convertRecordType(Id accountId) {
        String successMessage = '';
        try{
            Account convertAccount = [SELECT Id,Name,RecordtypeId, Recordtype.DeveloperName,FirstName,LastName,Retailer_Email__c,phone,OwnerId, CurrencyIsoCode,Is_Primary__c, 
                                      Primary_Account__c, Primary_Account__r.Name,  Primary_Account__r.RecordtypeId,  Primary_Account__r.FirstName,  Primary_Account__r.LastName, 
                                      Primary_Account__r.Retailer_Email__c, Primary_Account__r.phone, Primary_Account__r.OwnerId, Primary_Account__r.CurrencyIsoCode  
                                      FROM Account WHERE Id=:accountId];
            if(convertAccount.RecordtypeId == corporateRecordtypeId || convertAccount.RecordtypeId == corporatePrimaryRecordtypeId){
                List<Contact> newContactList = new List<Contact>();
                Contact newContact = new Contact(Lastname = convertAccount.Name, Email = convertAccount.Retailer_Email__c, AccountId =convertAccount.Id, CurrencyIsoCode = convertAccount.CurrencyIsoCode, OwnerId =convertAccount.OwnerId);
                newContactList.add(newContact);
                if(!convertAccount.Is_Primary__c && convertAccount.Primary_Account__c != null){
                    Contact newprimaryContact = new Contact(Lastname = convertAccount.Primary_Account__r.Name, Email = convertAccount.Primary_Account__r.Retailer_Email__c, 
                                                            AccountId =convertAccount.Primary_Account__c, CurrencyIsoCode = convertAccount.Primary_Account__r.CurrencyIsoCode,
                                                            OwnerId =convertAccount.Primary_Account__r.OwnerId);
                    newContactList.add(newprimaryContact); 
                }
                insert newContactList;
                system.debug('corpContact'+newContactList);
                List<Account> updateAccountList = new List<Account>();
                Account updateAccount = new Account(Id=convertAccount.Id, recordTypeId = individualRecordtypeId);
                updateAccountList.add(updateAccount);
                if(!convertAccount.Is_Primary__c && convertAccount.Primary_Account__c != null){
                    Account updatePrimaryAccount = new Account(Id=convertAccount.Primary_Account__c, recordTypeId = individualPrimaryRecordtypeId);
                    updateAccountList.add(updatePrimaryAccount);
                }
                update updateAccountList;
            } else  if(convertAccount.RecordtypeId == individualRecordtypeId || convertAccount.RecordtypeId == individualPrimaryRecordtypeId){
                
                List<Account> updateAccountList = new List<Account>();
                Account updateAccount = new Account(Id=convertAccount.Id, recordTypeId = corporateRecordtypeId);
                updateAccountList.add(updateAccount);
                if(!convertAccount.Is_Primary__c && convertAccount.Primary_Account__c != null){
                    Account updatePrimaryAccount = new Account(Id=convertAccount.Primary_Account__c, recordTypeId = corporatePrimaryRecordtypeId);
                    updateAccountList.add(updatePrimaryAccount);
                }
                update updateAccountList;
            }
            successMessage = 'Success';
        }catch(exception e){
            successMessage = ''+e.getMessage();
        }
        return successMessage;
    }
    
    
    
    
}