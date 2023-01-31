@isTest 
public class CaseCommentTriggerTest  {

    static testmethod void testPositive() {

        Case c = TestClass_CaseCreator.Create('Phone');
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CXP Support').getRecordTypeId();
        update c;

        system.assert([select id from case].size()==1,'Case failed creation during test execution');

        system.assert(Limits.getEmailInvocations()==0);

        Test.startTest();

        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'test';
        insert cc; 
 
        system.assert(Limits.getEmailInvocations()>0,'Email was not sent in test class but was expected');

        Test.stopTest();
 
    }

    static testmethod void testNegative_DoNotNotifyFlagOn() {

        Case c = TestClass_CaseCreator.Create('Phone');
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CXP Support').getRecordTypeId();
        c.Do_Not_Notify_CXP_Support__c = true;
        update c;

        system.assert([select id from case].size()==1,'Case failed creation during test execution');

        system.assert(Limits.getEmailInvocations()==0);

        Test.startTest();

        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'test';
        insert cc; 
 
        system.assert(Limits.getEmailInvocations()==0,'Email was sent in test class but this was not expected');

        Test.stopTest();
 
    }

    static testmethod void testNegative_WrongRecordType() {

        Case c = TestClass_CaseCreator.Create('Phone'); 
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Enquiry').getRecordTypeId(); 
        update c;

        system.assert([select id from case].size()==1,'Case failed creation during test execution');

        system.assert(Limits.getEmailInvocations()==0);

        Test.startTest();

        CaseComment cc = new CaseComment();
        cc.ParentId = c.Id;
        cc.CommentBody = 'test';
        insert cc; 
 
        system.assert(Limits.getEmailInvocations()==0,'Email was sent in test class but this was not expected');

        Test.stopTest();
 
    }

}