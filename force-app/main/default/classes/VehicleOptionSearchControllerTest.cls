@isTest
public with sharing class VehicleOptionSearchControllerTest {

    public static String getRecordTypeId(String objectType, String recordTypeName)
    {
        RecordType rt = [select Id from RecordType where sobjecttype = :objectType and DeveloperName = :recordTypeName]; 
        return rt.Id;
    }

    @TestSetup
    static void makeData(){

        Id retailerRecordTypeId = getRecordTypeId('Account', 'Retailer');

        Account acc = new Account(
        Name = 'Retailer' , 
        RecordTypeId = retailerRecordTypeId, 
        Region_Or_Market__c = 'KR', 
        Country_ISO_Code__c = 'KR', 
        Record_Sub_Type__c = 'Dual Brand');
        insert acc;

        Account individualAcc = new Account(
        LastName = 'Retailer' , 
        RecordTypeId = getRecordTypeId('Account', 'Individual'), 
        Region_Or_Market__c = 'KR', 
        PersonEmail = 'a@a.a',
        PersonMobilePhone = '010111222',
        Country_ISO_Code__c = 'KR');
        insert individualAcc;

        Vehicle_Specification__c brand = new Vehicle_Specification__c(Name = 'Land Rover', CurrencyIsoCode = 'KRW');
        insert brand;

        Product2 model = new Product2(Name = 'Discovery Sport', 
        CurrencyIsoCode = 'KRW', 
        Model_Alternative__c = 'Discovery Sport', 
        Make__c = brand.Id,
        RecordTypeId = getRecordTypeId('Product2', 'Model'));
        insert model;

        Product2 derivative = new Product2(
            Name = 'Discovery Sport 2.0L Si4 Petrol 5DR TL4 - HSE LUX, Korea - South JAP, IUTV/350QD, 2023.5',  
            CurrencyIsoCode = 'KRW',
            KR_Model_Year__c = '2023', 
            RecordTypeId = getRecordTypeId('Product2', 'Derivative'), 
            Model_Alternative__c = 'Discovery Sport', 
            Alternative_Name__c = '350QD 5DR',
            Make__c = brand.Id,
            Model__c = model.Id,
            ProductCode = '50001234'
            );
        insert derivative;

        Product2 option = new Product2(
            Name = '003KR',  
            CurrencyIsoCode = 'KRW',
            RecordTypeId = getRecordTypeId('Product2', 'Accessories'), 
            ProductCode = '003KR'
            );
        insert option;

        Asset asset = new Asset(
            Name = 'SAL11111111', 
            VIN__c = 'SAL11111111', 
            CurrencyIsoCode = 'KRW', 
            AccountId = acc.Id, 
            Price = 10000000, 
            Local_Price__c = 10000000, 
            Name_Plate__c = '111가 1111', 
            Status = 'For Sale',
            RecordTypeId = getRecordTypeId('Asset', 'Vehicle'),
            Arrival_Date__c = Date.newInstance(2023, 1, 1),
            Brand__c = brand.Id,
            Model__c = model.Id, 
            Product2Id = derivative.Id, 
            Derivative__c = derivative.Id);
        insert asset;

        Asset assetOption = new Asset(
            Name = '003KR', 
            ParentId = asset.Id,
            Brand__c = brand.Id,
            Product2Id = option.Id, 
            CurrencyIsoCode = 'KRW', 
            AccountId = acc.Id, 
            RecordTypeId = getRecordTypeId('Asset', 'Vehicle_Option')
            );
        insert assetOption;

        Pricebook2 pb = new Pricebook2(
            Country_ISO_Code__c = 'KR',
            CurrencyIsoCode = 'KRW',
            IsActive = true,
            Name = 'Korea, Republic of'
        );
        insert pb;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbeStandard = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = derivative.Id,
            CurrencyIsoCode = 'KRW',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbeStandard;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = derivative.Id,
            CurrencyIsoCode = 'KRW',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;

        Test.startTest();
        PricebookEntry pbeStandardOption = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = option.Id,
            CurrencyIsoCode = 'KRW',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbeStandardOption;
        
        PricebookEntry pbeOption = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = option.Id,
            CurrencyIsoCode = 'KRW',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbeOption;

        Product_Option_Mapping__c mapping = new Product_Option_Mapping__c(
            Option__c = option.Id,
            Product__c = derivative.Id,
            Option_Derivative_Price_Override__c = 1
        );
        insert mapping;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp', 
            StageName = 'Handover & RDA', 
            CloseDate = Date.today().addDays(3), 
            CurrencyIsoCode = 'KRW',
            Pricebook2Id = pb.Id,  
            AccountId = individualAcc.Id);
        insert opp;

        OpportunityLineItem opptyLineItem = new OpportunityLineItem(
            Product2Id = derivative.Id,
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 0
        );
        insert opptyLineItem;
        Test.stopTest();

    }

    @isTest
    static void case1(){
        
        Id opptyId = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ]?.Id;

        Set<String> optionSet = new Set<String>();
        optionSet.add('003KR');

        Test.startTest();
        VehicleOptionSearchController.getProductMaster();
        VehicleOptionSearchController.getOpptyLineItemsByOpptyId(opptyId);
        VehicleOptionSearchController.getAssetMapByOptionCodes('50001234', optionSet);
        VehicleOptionSearchController.getOptionPriceBy5000Code('50001234', false);
        VehicleOptionSearchController.generateDatatableList('50001234', new List<String>(optionSet));

        Test.stopTest();

    }

    @isTest 
    public static void testShowOptionSearch() {
        Test.startTest();
        Boolean showOptionSearch = VehicleOptionSearchController.showVehicleOptionsSearch();
        Test.stopTest();

        Assert.isNotNull(showOptionSearch);
    }


}