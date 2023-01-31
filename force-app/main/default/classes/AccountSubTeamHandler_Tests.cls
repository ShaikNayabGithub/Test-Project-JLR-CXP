@isTest
public with sharing class AccountSubTeamHandler_Tests {
    
    @isTest 
    public static void Test_SetAccountSubTeam() {

        

        Account testRetailer = TestClass_AccountCreator.BuildRetailer();
        testRetailer.Record_Sub_Type__c = 'Dual Brand';
        insert testRetailer;
        Contact testContact = TestClass_ValidContactBuilder.Build(testRetailer);

        User currentUser = new User(Id=UserInfo.getUserId());
        //User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        User testUser = new User();
        System.runAs(currentUser) {
            testUser = TestClass_UserCreator.CreateRetailerUser(testContact);
            testUser.Division = 'Bundang Team 2';
            testUser.Dealer_CI_Code__c = '01074';
            testUser.Dealer_CI_Code_2__c = '01074';
            update testUser;
        }
        

        

        Test.startTest();

        Account personAccount;
        System.runAs(testUser) {
            personAccount = TestClass_AccountCreator.createPersonAccount();
            personAccount.Country_ISO_Code__c = 'KR';
            personAccount.Country_ISO_Code__pc = 'KR';
            personAccount.Preferred_Sales_Retailer__c = testRetailer.Id;
            personAccount.LastName = 'MyUpdatedLastName';
            personAccount.PersonMobilePhone = '01234321223';
            update personAccount;
        }
        Test.stopTest();

        Account output = [SELECT Id, LastName, PersonMobilePhone, Sub_team_Name__c, External_ID_SF__c FROM Account WHERE Id = :personAccount.Id]; 
        Assert.areEqual('KR-MyUpdatedLastName-01234321223-' + testRetailer.Id, output.External_ID_SF__c);
        Assert.areEqual('KR-01074-01074-Bundang Team 2', output.Sub_team_Name__c);


    }

    

    private static User createTestUser() {
        User testUser = new User();
        testUser.Phone = '07681102495';
        testUser.Email = 'test@test.test';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Sales User' LIMIT 1].Id;
        testUser.Username = 'AccountSubTeamHandler_Teststest@test.test.retailer';
        testUser.Alias = 'TTT';
        testUser.FirstName = 'Test';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        return testUser;
    }
}