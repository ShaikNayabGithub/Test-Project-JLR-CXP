/**
 * Created by caleb@argologic.com.au on 29/07/2020.
 */

@IsTest
public with sharing class ServicePlanControllerTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity();
        opp.Country_ISO_Code__c = 'AU';
        opp.CurrencyIsoCode = 'AUD';
        Vehicle_Specification__c landRoverMake = TestClass_VehicleSpecificationBuilder.BuildLandRoverMake();
        Product2 model = TestClass_ProductBuilder.BuildModel(landRoverMake);
        model.CurrencyIsoCode = 'AUD';
        update model;
        Product2 derivative = new Product2(Name = 'Discovery Sport 2.0L Si4 Petrol 5DR TL4 - HSE LUX, Japan JAP, IUTV/350QD, 2016.5',  CurrencyIsoCode = 'AUD',Registration_Year_Alternative__c = '2018', RecordTypeId = TestDataFactory.getRecordType('Product2', 'Derivative'), Model_Alternative__c = 'Discovery Sport', Model__c = model.Id, Make__c = landRoverMake.Id);
        insert derivative;
        String derivativeId = derivative.Id;
        Product2 prod = [SELECT Make__c, Model__c FROM Product2 WHERE Id = :derivativeId];
        PricebookEntry pbe = TestClass_OppLineItemCreator.CreatePricebookEntry(prod.Make__c, prod.Model__c);
        opp.Pricebook2Id = pbe.Pricebook2Id;
        update opp;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        //oli.Asset__c = TestClass_AssetBuilder.BuildAndInsertVehicle().Id;
        oli.Product2Id = derivativeId;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.TotalPrice = 100;
        insert oli;

        // ACT
        test.startTest();
        ServicePlanController.getServicePlan(oli.OpportunityId);
        test.stopTest();

        // ASSERT

    }

    @IsTest
    public static void test2()
    {
        ServicePlanController.TestCoverage();
    }

    @IsTest
    public static void servicePlanResDtoTest()
    {
        // ARRANGE
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2 = new Product2();
        oli.Product2.Name = '100 miles';
        oli.Assignment_Type__c = 'Corp';

        Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
        spc.Service_Plan_Product__r = new Product2();
        spc.Service_Plan_Product__r.Name = 'con';

        // ACT
        test.startTest();
        ServicePlanResponseDto res1 = new ServicePlanResponseDto(oli);
        ServicePlanResponseDto res2 = new ServicePlanResponseDto(spc);
        test.stopTest();

    }
}