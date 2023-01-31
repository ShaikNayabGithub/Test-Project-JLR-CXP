/**
 * Created by caleb@argologic.com.au on 3/12/2019.
 */

@IsTest
private class WelcomePacksService_Test
{
    @IsTest
    static void test1()
    {
        // ARRANGE
        Task t = new Task();
        Account personAccount = TestClass_AccountCreator.createPersonAccount_Australia();
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        t.whoId = [SELECT Id FROM Contact WHERE Country_ISO_Code__c = :Constants.COUNTRY_CODE_AU].Id;
        t.whatId = vehicle.Id;
        t.Status = 'Call Completed';
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(WelcomePacksController.WELCOME_TO_THE_BRAND_RECORD_TYPE_NAME).getRecordTypeId();
        t.Completed_Time__c = Datetime.now();
        t.Subject = 'Test';
        insert t;

        GetWelcomePacksRequestDto req = new GetWelcomePacksRequestDto();
        req.dateStart = Datetime.now().addDays(-1);

        // ACT
        Test.startTest();
        GetWelcomePacksResponseDto res = WelcomePacksController.getWelcomePacks(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertEquals(1, res.Data.size());
    }

    @IsTest
    static void test2()
    {
        // ARRANGE
        Task t = new Task();
        Account personAccount = TestClass_AccountCreator.createPersonAccount_Australia();
        personAccount.BillingStreet = 'Harold St';
        personAccount.BillingPostalCode = '2000';
        personAccount.BillingState = 'New South Wales';
        personAccount.BillingCity = 'Sydney';
        personAccount.BillingCountry = 'Australia';
        personAccount.PersonMailingStreet = null;
        personAccount.PersonMailingPostalCode = null;
        personAccount.PersonMailingState = null;
        personAccount.PersonMailingCity = null;
        update personAccount;
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        t.whoId = [SELECT Id FROM Contact WHERE Country_ISO_Code__c = :Constants.COUNTRY_CODE_AU].Id;
        t.whatId = vehicle.Id;
        t.Status = 'Call Completed';
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(WelcomePacksController.WELCOME_TO_THE_BRAND_RECORD_TYPE_NAME).getRecordTypeId();
        t.Completed_Time__c = Datetime.now();
        t.Subject = 'Test';
        insert t;

        GetWelcomePacksRequestDto req = new GetWelcomePacksRequestDto();
        req.dateStart = Datetime.now().addDays(-1);

        // ACT
        Test.startTest();
        GetWelcomePacksResponseDto res = WelcomePacksController.getWelcomePacks(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertEquals(1, res.Data.size());
    }
}