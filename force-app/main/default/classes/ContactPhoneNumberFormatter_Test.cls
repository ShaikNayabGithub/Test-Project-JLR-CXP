@isTest(seeAllData=false)
public class ContactPhoneNumberFormatter_Test {
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    
    static testmethod void test1()
    {
        List<Contact> contactList = New List<Contact>();
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
        contactList=[select id,
                     AssistantPhone,
                     Country_ISO_Code__c,
                     Account_Country_Iso_Code__c,
                     HomePhone,
                     MobilePhone,
                     OtherPhone,
                     Phone,
                     Assistant_Phone_Hidden__c,
                     Other_Phone_Hidden__c,
                     Work_Order_contact_Home_Phone__c,
                     Work_Order_contact_Mobile_Phone__c,
                     Work_Order_contact_Work_Phone__c
                     from contact];
        
        Test.startTest();
        ContactPhoneNumberFormatter.phoneFormatterOnInsertUpdate(contactList);
        Test.stopTest();
    }
}