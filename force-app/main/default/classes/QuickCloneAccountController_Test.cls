@IsTest
public class QuickCloneAccountController_Test {
    
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    
    static testmethod void testGoldenINdividualWithIncorrectUser()
    {
        List<Account> accountList = New List<Account>();
        Account account = new Account(RecordTypeId = goldenIndividualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = true;
        account.Phone = '611234567890';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        accountList.add(account);
        Account result ;
        Boolean threwError = false;
        
        Test.startTest();
        // QuickCloneAccountController
        //    public static  Account getAccount(Id accountId) {
        //    public static Account cloneAccount(Account owner, Id accountId) {  
        Account owner = new Account();
        owner.OwnerId = UserInfo.getUserId();
        try{
            result =   QuickCloneAccountController.cloneAccount( owner, account.Id);
        }catch(Exception ex){
            threwError = true;
        }
        
        
        Test.stopTest();
        system.assert(threwError);
    }
    static testmethod void testGoldenCorporateIncorrectUser()
    {
        List<Account> accountList = New List<Account>();
        Account account = new Account(RecordTypeId = goldenCorporateRecordType, Name = 'ValidFirstname'); 
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = false;
        account.Phone = '611234567890';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        accountList.add(account);
        Account result ;
        Boolean threwError = false;
        
        Test.startTest();
        // QuickCloneAccountController
        //    public static  Account getAccount(Id accountId) {
        //    public static Account cloneAccount(Account owner, Id accountId) {  
        Account owner = new Account();
        owner.OwnerId = UserInfo.getUserId();
        try{
            result =   QuickCloneAccountController.cloneAccount( owner, account.Id);
        }catch(Exception ex){
            threwError = true;
        }
        
        
        Test.stopTest();
        system.assert(threwError);
        
    }
    static testmethod void testGoldenIndividualCorrectOwner()
    {
        List<Account> accountList = New List<Account>();
        Account account = new Account(RecordTypeId = goldenIndividualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = true;
        account.Phone = '611234567890';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        accountList.add(account);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account result;
        Test.startTest();
        // QuickCloneAccountController
        //    public static  Account getAccount(Id accountId) {
        //    public static Account cloneAccount(Account owner, Id accountId) {  
        Account owner = new Account();
        owner.OwnerId = portalUser.id;
        
        result =   QuickCloneAccountController.cloneAccount( owner, account.Id);
        
        
        
        Test.stopTest();
        system.assert(result != null);
    }
    static testmethod void testGoldenCorporateCorrectOwner()
    {
        List<Account> accountList = New List<Account>();
        Account account = new Account(RecordTypeId = goldenCorporateRecordType, Name = 'ValidFirstname'); 
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = false;
        account.Phone = '611234567890';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        accountList.add(account);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        
        Account result;
        
        Test.startTest();
        // QuickCloneAccountController
        //    public static  Account getAccount(Id accountId) {
        //    public static Account cloneAccount(Account owner, Id accountId) {  
        Account owner = new Account();
        owner.OwnerId = portalUser.id;
        try{
            result =   QuickCloneAccountController.cloneAccount( owner, account.Id);
         Account acc2=     QuickCloneAccountController.getAccount( account.Id); 
        }catch(Exception ex){
            
        }
        
        
        Test.stopTest();
        system.assert(result != null);
    }

    
    
}