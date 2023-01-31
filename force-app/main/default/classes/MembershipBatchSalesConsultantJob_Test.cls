@isTest(SeeAllData=false)
public class MembershipBatchSalesConsultantJob_Test {
 @testSetup 
    static void setup(){
        Account retailer = new Account();
            retailer.Name = 'test retailer - test - 01074';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailer.Dealer_CI_Code__c = 'test retailer';
            retailer.Primary_Dealer_Code__c = 'test retailer';
            retailer.Secondary_Dealer_Code__c = 'test retailer';
            retailer.Alternative_Key__c = 'test retailer';
        retailer.Country_ISO_Code__c='KR';
        retailer.Phone = '12131313';
        insert retailer;
        
        Contact newContact = new Contact(
            FirstName='Joe',
            LastName='Smith',
            Phone='415.555.1212',
            Language__c = 'English (UK)',
            Gender__c = 'Male',
            Birthdate= Date.newInstance(1990, 01, 01),
            AccountId= retailer.Id);
            insert newContact;
        
    }
    public static testmethod void testScheduler() {
        Test.startTest();
        Contact con = [select id,Account.Name from Contact where Account.Name != null limit 1];
        Id p = [select Id from Profile where Name='Sales Manager/Receptionist MENA'].Id;
        User user = new User(Alias = 'test123', Email='test123@noemail.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p,IsActive =true,
                             ContactId = con.Id,
                             Market__c = 'Korea',
                             TimeZoneSidKey='America/Los_Angeles', Username='tester1@noemail.com.unittest');

        insert user;
        user.Title = 'test';
        update user;
        
       user usrtest =[select id,title,Contact.Account.Name,Alias,Email,Profile.Name from user where Market__c = 'Korea' And ContactId != null AND isActive = True
                   AND Profile.Name = 'Sales Manager/Receptionist MENA' limit 1 ];
        
        //user usrtest =[select id,Contact.Account.Name,Alias from user where Market__c = 'Korea' And ContactId != null AND isActive = True
                  // AND Profile.Name = 'Sales Manager/Receptionist MENA' limit 1 ];

        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobID = System.schedule('TestSchedule', CRON_EXP, new MembershipBatchSalesConsultantJob() );
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobID];
        System.assertEquals(CRON_EXP,ct.CronExpression); 
        System.assertEquals(jobID,ct.Id);
        Test.stopTest();
        
        
        
    }
    
    public static testmethod void testuser(){
      
        Contact con = [select id,Account.Name from Contact where Account.Name != null limit 1];
        Id p = [select Id from Profile where Name='Sales Manager/Receptionist MENA'].Id;
        User user = new User(Alias = 'test123', Email='test123@noemail.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = p,IsActive =true,
                             ContactId = con.Id,
                             Market__c = 'Korea',
                             TimeZoneSidKey='America/Los_Angeles', Username='tester1@noemail.com.unittest');

        insert user;
        user.Title = 'test';
        update user;
        
       user usrtest =[select id,LastName,title,Contact.Account.Name,Alias,Email,Profile.Name from user where Market__c = 'Korea' And ContactId != null AND isActive = True
                   and LastModifiedDate = LAST_N_DAYS:1 and id =:user.Id limit 1];
     Test.startTest();
        Database.executeBatch(new MembershipBatchSalesConsultantJob(), 200);
        Test.stopTest();
        Membership__c obj = [select id,User_Name__c,Department__c, Role__c,Email__c from Membership__c where Email__c = 'test123@noemail.com'];
        system.debug('@@@@membershipCheck' + obj);
        assert.areEqual(usrtest.LastName, obj.User_Name__c);
        assert.areEqual('test123@noemail.com', obj.Email__c);
        
    }
    
    

}