@isTest(SeeAllData=false)
public class AccountPhoneNumberFormatter_Test {
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();

    static testmethod void test1()
    {
		List<Account> accountList = New List<Account>();
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = false;
        account.Phone = '611234567890';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        accountList.add(account);
        
        Test.startTest();
        AccountPhoneNumberFormatter.phoneFormatterOnInsertUpdate(accountList);
        Test.stopTest();
    }
}