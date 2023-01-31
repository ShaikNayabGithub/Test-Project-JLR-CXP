/**
 * Created by caleb@argologic.com.au on 24/01/2020.
 */

@IsTest
public with sharing class SalesMatchControllerTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        // Set Mock Because some trigger from a different region makes a web service callout
        //Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        // setup data
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :ass.AccountId];
        acc.Country_ISO_Code__c = 'AU';
        update acc;
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity(ass.Id, acc.Id);
        Account corpAccount = TestClass_AccountCreator.GenerateCorporateAccount();
        RDA__c rda = TestClass_RDACreater.CreateRDA(opp.Id, corpAccount.Id, acc.Id, ass.Id, acc.PersonContactId);

        // setup request
        GetSalesMatchRequestDto req = new GetSalesMatchRequestDto();
        req.CreatedDate = Date.today().addMonths(-1);

        // ACT
        Test.startTest();
        GetSalesMatchResponseDto res = SalesMatchController.getAssets(req);
        Test.stopTest();

        System.debug(JSON.serialize(res));
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.assertEquals(1, res.Data.size());
    }
}