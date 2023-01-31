@isTest
public with sharing class PdiQuotaBoardController_Tests {
    
    @isTest 
    public static void Test_fetchPdiQuota() {
        Integer year = 2022;
        Integer month = 11;

        Test.startTest();
        List<PDI_Quota__c> quotas = PdiQuotaBoardController.fetchPdiQuota(year, month);
        Test.stopTest();

        Assert.isNotNull(quotas);
    }

    @isTest 
    public static void Test_saveTargetRecords() {
        Account retailer  = TestClass_AccountCreator.CreateRetailer();

        String pdiQuotaRecords = '[{"Allocation_Day_1__c": 10, "Retailer__c": "' + retailer.Id + '"}]';

        Test.startTest();
        String output = PdiQuotaBoardController.saveTargetRecords(pdiQuotaRecords);
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_GetDays() {
        Integer year = 2022;
        Integer month = 11;

        Test.startTest();
        PdiQuotaBoardController.GetDayswithHolidayWrapper output = PdiQuotaBoardController.GetDays(year, month);
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_GetYearMonth() {

        Test.startTest();
        List<String> output = PdiQuotaBoardController.GetYearMonth();
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_getLangofUserLoggedin() {
        Test.startTest();
        String output = PdiQuotaBoardController.getLangofUserLoggedin();
        Test.stopTest();

        Assert.isNotNull(output);
    }

    
}