@isTest
private class UserHandler_Test {

    @testSetup
    static void setup(){
        Id dealerPrinciple = ProfileUtilities.Profiles.get('Dealer Principle').Id;
        User_Profile_for_Queues__c addQueue = new User_Profile_for_Queues__c(Name='test', Profile_ID__c = dealerPrinciple);
        insert addQueue;

        Group g = new Group(Name='TestGroup', Type='Queue', Email='test@test.com');
        Group g2 = new Group(Name='TestGroup2', Type='Queue', Email='test@test.com');
        List<Group> groupsToInsert = new List<Group>();
        groupsToInsert.add(g);
        groupsToInsert.add(g2);
        insert groupsToInsert;    
        //Account testRetailer = TestClass_AccountCreator.CreateRetailer();
        //Account newTestRetailer = TestClass_AccountCreator.CreateRetailer();
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();
        Account newTestRetailer = TestClass_AccountCreator.BuildRetailer();
        testRetailer.Queue_ID__c = g.Id;
        newTestRetailer.Queue_ID__c = g2.Id;
        List<Account> accountsToInsert = new List<Account>();
        accountsToInsert.add(testRetailer);
        accountsToInsert.add(newTestRetailer);
        insert accountsToInsert;
        
        Contact testContact = TestClass_ValidContactBuilder.Build(testRetailer);
        User testUser = new User(Phone='07681102495', Email='test@test.test', UserName='TestClass_UserCreator@test.test', Country_ISO_Code__c='IN', Alias='TTT', FirstName='Test', LastName='Test', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', EmailEncodingKey='UTF-8', Dealer_CI_Code__c='test', Dealer_CI_Code_2__c='test', PortalRole='Manager', ContactId=testContact.Id);
        testUser.ProfileId = dealerPrinciple;
        //TestClass_LockableRecordInserter.AttemptInsert(testUser, 5);
        Contact newTestContact = TestClass_ValidContactBuilder.Build(newTestRetailer);
        User newTestUser = new User(Phone='07681102495', Email='test2@test.test', UserName='TestClass_UserCreator@test2.test', Country_ISO_Code__c='IN', Alias='TTT', FirstName='Test2', LastName='Test2', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', EmailEncodingKey='UTF-8', Dealer_CI_Code__c='test', Dealer_CI_Code_2__c='test', PortalRole='Manager', ContactId=newTestContact.Id);
        newTestUser.ProfileId = dealerPrinciple;
        //TestClass_LockableRecordInserter.AttemptInsert(newTestUser, 5);
        List<User> usersToInsert = new List<User>();
        usersToInsert.add(testUser);
        usersToInsert.add(newTestUser);
        System.RunAs(new User(Id=userinfo.getUserId())){
        TestClass_LockableRecordInserter.AttemptInsert(usersToInsert, 5);
        }
    }

    @isTest
    static void UserHandler_AddsUserToQueue_GivenNonQueueProfile() {        
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE UserName = 'TestClass_UserCreator@test.test'];
        Test.stopTest();

        //test that user is added to queue
        GroupMember queueMember = [SELECT Id, Group.Name FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
        System.assertEquals('TestGroup', queueMember.Group.Name);
    }
    
    @isTest
    static void UserHandler_RemovesUserToQueue_GivenQueueProfile() {
        Id salesExecutive = ProfileUtilities.Profiles.get('Sales Executive').Id;
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE UserName = 'TestClass_UserCreator@test.test'];
        testUser.ProfileId = salesExecutive;
        update testUser;
        Test.stopTest();

        //test that user is removed from queue
        List<GroupMember> queueMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
        System.assertEquals(0, queueMembers.size());
    }
    
    @isTest
    static void UserHandler_MovesUserToCorrectQueue_GivenQueueProfileAndChangeOfAccountId() {
        //testing Contact trigger
        Test.startTest();
        User testUser = [SELECT Id, ContactId FROM User WHERE UserName = 'TestClass_UserCreator@test.test'];
        Contact testContact = [SELECT AccountId FROM Contact WHERE Id = :testUser.ContactId];
        Account testNewRetailer = [SELECT Queue_ID__c FROM Account WHERE Id != :testContact.AccountId AND RecordTypeId = :AccountUtilities.RecordTypes.get('Retailer').Id];
        testContact.AccountId = testNewRetailer.Id;
        update testContact;
        Test.stopTest();

        //test that user is moved to new queue i
        GroupMember queueMember = [SELECT Id, Group.Name FROM GroupMember WHERE UserOrGroupId = :testUser.Id];
        System.assertEquals('TestGroup2', queueMember.Group.Name);
    }
        
}