/**
 * Created by caleb@argologic.com.au on 13/01/2020.
 */

@IsTest
public with sharing class RetailDeliveryControllerTest
{
    @IsTest
    public static void getRetailDeliveryAdvicesTest()
    {

        // ARRANGE
        // Set Mock Because some trigger from a different region makes a web service callout
        //Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        // setup data
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :ass.AccountId];
        acc.Country_ISO_Code__c = 'AU';
        update acc;
        Test.startTest();
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity(ass.Id, acc.Id);
        Account corpAccount = TestClass_AccountCreator.GenerateCorporateAccount();
        RDA__c rda = TestClass_RDACreater.CreateRDA(opp.Id, corpAccount.Id, acc.Id, ass.Id, acc.PersonContactId);
        rda.Handover_Date__c = Date.today();
        rda.Submitted_Status__c = RetailDeliveryController.SUBMITED_STATUS_COMPLETED;
        rda.RecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get(RetailDeliveryController.NEW_RETAIL_RECORD_TYPE_DEV_NAME).getRecordTypeId();

        update rda;

        // setup request
        GetRetailDeliveryAdvicesRequestDto req = new GetRetailDeliveryAdvicesRequestDto();
        req.DateStart = Date.today().addMonths(1);

        // ACT
        System.debug('Handover Date = ' + rda.Handover_Date__c);
        GetRetailDeliveryAdvicesResponseDto res = RetailDeliveryController.getRetailDeliveryAdvices(req);
        Test.stopTest();

        System.debug(JSON.serialize(res));
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.assertEquals(1, res.Data.size());
    }
}