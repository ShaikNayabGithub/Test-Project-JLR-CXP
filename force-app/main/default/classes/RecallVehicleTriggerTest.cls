/**
 * Created by caleb on 19/07/2022.
 */

@IsTest
public with sharing class RecallVehicleTriggerTest
{
    @IsTest
    public static void test1()
    {
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        
        Recall_Campaign__c rc = new Recall_Campaign__c();
        insert rc;

        Recalled_Vehicle__c rv = new Recalled_Vehicle__c();
        rv.Asset_Name_Text__c = ass.Name;
        rv.Recall_Campaign__c = rc.Id;

        Test.startTest();
        insert rv;
        Test.stopTest();
    }

    @IsTest
    public static void test2()
    {
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(false);


        Recall_Campaign__c rc = new Recall_Campaign__c();
        insert rc;

        Recalled_Vehicle__c rv = new Recalled_Vehicle__c();
        rv.Asset_Name_Text__c = ass.Name;
        rv.Recall_Campaign__c = rc.Id;

        Test.startTest();
        insert rv;
        Test.stopTest();
    }

    @IsTest
    public static void test3()
    {
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);


        Account acc = TestClass_AccountCreator.BuildRetailer();
        insert acc;
        ass.AccountId = acc.Id;
        update ass;

        Recall_Campaign__c rc = new Recall_Campaign__c();
        insert rc;

        Recalled_Vehicle__c rv = new Recalled_Vehicle__c();
        rv.Asset_Name_Text__c = ass.Name;
        rv.Recall_Campaign__c = rc.Id;

        Test.startTest();
        insert rv;
        Test.stopTest();
    }

    @IsTest
    public static void test4()
    {
        RecallVehicleTriggerHandlerAU.TestCoverage();
    }
}