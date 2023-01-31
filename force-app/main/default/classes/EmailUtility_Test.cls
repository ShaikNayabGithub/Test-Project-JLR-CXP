@isTest(SeeAllData=false)
public class EmailUtility_Test{

    static testMethod void testEmailerValidEmail() 
    {
        system.assert(EmailUtility.validateEmail('this_is_a_valid_email@fake-email.com'));
    }
    
    static testMethod void testEmailerInvalidEmail() 
    {
        system.assert(!EmailUtility.validateEmail('this_is_an_invalid_email'));
        system.assert(!EmailUtility.validateEmail('this is also an invalid_email @fake-email.com'));
        system.assert(!EmailUtility.validateEmail(null));
        system.assert(!EmailUtility.validateEmail(''));
    }
    
    static testMethod void testEmailerSingleEmail()
    { 
        Test.startTest();
        system.assert(Limits.getEmailInvocations()==0); 
        EmailUtility.SendEmail('testemail@fake-email.com', 'Tester', 'Test', 'Test');
        system.assert(Limits.getEmailInvocations()==1);
        Test.stopTest();
    }
    
    static testMethod void testEmailerMulitpleEmails()
    { 
        Test.startTest();
        system.assert(Limits.getEmailInvocations()==0); 
        EmailUtility.SendEmail(new List<String>{'testemail@fake-email.com','test2email@fake-email.com'}, 'Tester', 'Test', 'Test');
        system.assert(Limits.getEmailInvocations()==1);
        Test.stopTest();    
    }    
    
    static testMethod void testEmailerMulitpleEmailsWithPlainTextAndTask()
    { 
        Test.startTest();
        system.assert(Limits.getEmailInvocations()==0); 
        system.assert([select id from task].size()==0);
        
        Case c = new Case(subject='subject',description='description',ownerid=UserInfo.getUserId());
        insert c;
        
        EmailUtility.SendEmail(new List<String>{'testemail@fake-email.com','test2email@fake-email.com'}, 
                                'Tester', 'Test', '<b>Test</b>', 'Test', 'replyTo@jaguarlandrover.com', true, c.id );
        system.assert(Limits.getEmailInvocations()>0);
        system.assert([select id from task].size()==1);
        Test.stopTest();    
    }    
    
}