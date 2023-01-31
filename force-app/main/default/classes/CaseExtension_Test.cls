@isTest
public class CaseExtension_Test {
    
     @TestSetup
    static void createTestData() {
       User currentUser = new User(Id=UserInfo.getUserId());
        Account accounts = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contactuser = TestClass_ValidContactBuilder.Build(accounts);
        User user;
        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contactuser);
            user.Market__c = 'IN';
            user.Country_ISO_Code__c = 'IN';
            //insert user;
        }
        
        Account account = TestClass_AccountCreator.createPersonAccount();
        List<contact> cts1 = [select id, lastname, email,phone,mobilephone, accountId,account.Country_ISO_Code__c  from contact];
       
        Contact contact = new Contact();        
        contact.id = cts1[0].id;       
        contact.phone = '9985090590';
        contact.mobilephone = '9985090590';
        update contact;
       
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC').getRecordTypeId();
        
        Case caseRecord = new Case();
        caseRecord.Origin = 'Phone';
        caseRecord.RecordTypeId = devRecordTypeId;
        caseRecord.SuppliedEmail = 'test123@test.com';
        caseRecord.Case_Contact_Phone__c = '9985090590';
        caseRecord.OwnerId = user.id; 
        insert caseRecord; 
        
    }
    
    static testmethod void matchEmail()
    {
        List<contact> cts = [select id, lastname, email,phone,mobilephone, accountId,account.Country_ISO_Code__c from contact];
        case cs = [select id, ownerid,SuppliedEmail,Case_Contact_Email__c,Case_Contact_Phone__c, Owner_ISO_Code__c from case limit 1];
        system.debug('case after insert---' + cs);
        Boolean phoneLinked = CaseExtensions.MatchCaseToContactByEmail(cs, cts);
    }
    static testmethod void matchPhone()
    {
        List<contact> cts = [select id, lastname, email,phone,mobilephone, accountId,account.Country_ISO_Code__c from contact];
        case cs = [select id, ownerid,SuppliedEmail,Case_Contact_Phone__c, Owner_ISO_Code__c from case limit 1];
        system.debug('case after insert---' + cs);
        Boolean phoneLinked = CaseExtensions.MatchCaseToContactByPhone(cs, cts);
    }
    static testmethod void matchMobile()
    {
        List<contact> cts = [select id, lastname, email,phone,mobilephone, accountId,account.Country_ISO_Code__c from contact];
        case cs = [select id, ownerid,SuppliedEmail,Case_Contact_Phone__c, Owner_ISO_Code__c from case limit 1];
        system.debug('case after insert---' + cs);
        Boolean mobileLinked = CaseExtensions.MatchCaseToContactByMobile(cs, cts);  
    }
    
    
}