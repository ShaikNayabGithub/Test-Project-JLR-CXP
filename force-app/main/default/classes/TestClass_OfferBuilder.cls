/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 30/09/2019.
 */
@IsTest
public with sharing class TestClass_OfferBuilder {

    // Generates a list of 10 offers with random Types
    public static List<Offers__c> createOfferList(String variationId)
    {
        List<Offers__c> offers = new List<Offers__c>();
        for (Integer i = 0 ; i < 10; i++)
        {
            Offers__c offer = new Offers__c();
            List<Schema.PicklistEntry> picklistEntries =  Offers__c.Type__c.getDescribe().getPicklistValues();
            offer.Type__c = picklistEntries[Math.mod(i, picklistEntries.size())].getValue();
            offer.CurrencyIsoCode = 'JPY';
            offer.Derivative_Product2Id__c = variationId;
            offer.Service_Plan_Product2Id__c = variationId;
            offer.Start_Date__c = date.today().addDays(-1);
            offer.End_Date__c = date.today().addDays(1);
            offer.IsActive__c = true;
            offers.add(offer);
        }
        insert offers;
        return  offers;
    }

    public static List<Offers__c> createCorporateOffersList(String variationId, String corporatePartnerId, Integer count, Id pricebook2Id){
        List<Offers__c> offers = new List<Offers__c>();

        Product2 car = [SELECT id, Service_Plan__c FROM Product2 WHERE id = :variationId LIMIT 1];
        Id servicePlanId = null;

        if (car.Service_Plan__c == null){
            Product2 servicePlan = buildServicePlan(pricebook2Id);
            car.Service_Plan__c = servicePlan.Id;
            servicePlanId = servicePlan.Id;
            update car;
        }else{
            servicePlanId = car.Service_Plan__c;
        }

        for (Integer i = 0 ; i < count; i++)
        {
            Offers__c offer = new Offers__c();
            offer.Type__c = Constants.SERVICE_PLAN_TYPE_CORPORATE;
            offer.CurrencyIsoCode = 'AUD';
            offer.Derivative_Product2Id__c = variationId;
            offer.Service_Plan_Product2Id__c = servicePlanId;
            offer.Start_Date__c = date.today().addDays(-1);
            offer.End_Date__c = date.today().addDays(1);
            offer.Corporate_Partner__c = corporatePartnerId;
            offer.IsActive__c = true;
            offers.add(offer);
        }
        insert offers;
        For(Offers__c offer: offers){
            Id pricebookId = Test.getStandardPricebookId();

            PricebookEntry spbe = new PricebookEntry();
            spbe.Pricebook2Id = pricebookId;
            spbe.IsActive = true;
            spbe.Product2Id = variationId;
            spbe.UnitPrice = 0;
            List<PricebookEntry> existingsPbeEntries = [SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = : spbe.Pricebook2Id
            AND Product2Id = :spbe.Product2Id
            AND IsActive = TRUE];
            if (existingsPbeEntries.size() == 0){
                insert spbe;
            }


            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = pricebookId;
            pbe.IsActive = true;
            pbe.Product2Id = variationId;
            pbe.UnitPrice = 0;
            List<PricebookEntry> existingPbeEntries = [SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = : pbe.Pricebook2Id
            AND Product2Id = :pbe.Product2Id
            AND IsActive = TRUE];
            if (existingPbeEntries.size() == 0){
                insert pbe;
            }
        }
        return  offers;
    }

    public static List<Offers__c> createCorporateOffersList(String variationId, String corporatePartnerId, Integer count)
    {
       	Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        return createCorporateOffersList(variationId, corporatePartnerId, count, pb.Id);

    }

    public static Product2 buildServicePlan(Id pricebook2Id) {
        Product2 servicePlan = new Product2();
        servicePlan.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
        servicePlan.Name = 'My Test Service Plan';
        insert servicePlan;

        Id standardPbId = Test.getStandardPricebookId();
        PricebookEntry standardPbe = new PricebookEntry();
        standardPbe.Product2Id  = servicePlan.Id;
        standardPbe.UnitPrice = 0;
        standardPbe.IsActive = true;
        standardPbe.Pricebook2Id = standardPbId;
        insert standardPbe;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id  = servicePlan.Id;
        pbe.UnitPrice = 0;
        pbe.IsActive = true;
        pbe.Pricebook2Id = pricebook2Id;
        insert pbe;
        return servicePlan;
    }

    public static List<Offers__c> createComplimentaryOffers(String variationId, Integer count)
    {
        List<Offers__c> offers = new List<Offers__c>();
        for (Integer i = 0 ; i < count; i++)
        {
            Offers__c offer = new Offers__c();
            offer.Type__c = Constants.SERVICE_PLAN_TYPE_COMPLIMENTARY;
            offer.CurrencyIsoCode = 'AUD';
            offer.Derivative_Product2Id__c = variationId;
            offer.Service_Plan_Product2Id__c = variationId;
            offer.Start_Date__c = date.today().addDays(-1);
            offer.End_Date__c = date.today().addDays(1);
            offer.IsActive__c = true;
            offers.add(offer);
        }
        insert offers;
        return  offers;
    }

}