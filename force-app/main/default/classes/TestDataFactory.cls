public class TestDataFactory
{
    public static String getRecordType(String objectType, String recordTypeName)
    {
        RecordType rt = [select Id from RecordType where sobjecttype = :objectType and name = :recordTypeName]; 
        return rt.Id;
    }
    public static List<Account> generateAccounts(Integer count, String recordTypeId, String prefectures, String wards)
    {
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < count; i++)
        {
            Account acc = new Account(Name = 'Retailer' + i, Region_Or_Market__c = 'JP', RecordTypeId = recordTypeId, Brand__c = 'Land Rover', Record_Sub_Type__c = 'Branded', merchant_id__c = '72637', service_id__c = '001', c_udaan_marketarea1__c = prefectures, c_udaan_marketarea2__c = wards);
            accList.add(acc);
        }
        insert accList;
        return accList;
    }
    public static void generatePrefectureWardsMapping(String prefecture, List<String> wards)
    {
        List<JUDAAN_Prefecture_Ward__c> pws = new List<JUDAAN_Prefecture_Ward__c>();
        for(String ward : wards)
        {
            pws.add(new JUDAAN_Prefecture_Ward__c(Name = ward, Prefecture__c = prefecture, Ward__c = ward));
        }
        insert pws;
    }
    public static String  generateAsset(string brand, string retailer)
    {
        ModelId = generateModels(brand);
        Id derivativeId = generateDerivative(brand);
        Asset asset = new Asset(Name = 'SALCA2AG0GH550580', VIN__c = 'SN1111111111111111', Brand__c = brand, CurrencyIsoCode = 'JPY', AccountId = retailer, Price = 10000000, Local_Price__c = 10000000, Name_Plate__c = 'Discovery Sport', Model__c = ModelId, Product2Id = derivativeId , Derivative__c = derivativeId);
        insert asset;
        return asset.Id;
    }
    public static Opportunity generateOpportunity(String assetId, String accId)
    {
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Save a Quote', CloseDate = Date.today().addDays(3), Budget__c = 100000, CurrencyIsoCode = 'JPY', 
                                            Asset__c = assetId, AccountId = accId);
        insert opp;
        return opp;
                                            
    }
    public static FinanceRates__c generateRates()
    {
        FinanceRates__c finance = new FinanceRates__c(Name = 'DISCOVERY SPORT,37', NamePlate__c = 'Discovery Sport', ResidualRateUp__c = 50, ResidualRateBottom__c = 5, DefaultRate__c = '50%', Times__c = 37);
        insert finance;
        return finance;
    }
    public static String generateModels(string make)
    {
        Product2 model = new Product2(Name = 'Discovery Sport', Make__c = make, CurrencyIsoCode = 'JPY', RecordTypeId = getRecordType('Product2', 'Model'));
        insert model;
        return model.Id;
    }

    public static Id ModelId { get; set; }
    public static String generateDerivative(String brand)
    {
        Product2 derivative = new Product2(Name = 'Discovery Sport 2.0L Si4 Petrol 5DR TL4 - HSE LUX, Japan JAP, IUTV/350QD, 2016.5',  CurrencyIsoCode = 'JPY',Registration_Year_Alternative__c = '2018', RecordTypeId = getRecordType('Product2', 'Derivative'), Model_Alternative__c = 'Discovery Sport', Model__c = ModelId, Make__c = brand);
        insert derivative;
        return derivative.Id;
    }

    public static void generateCampaign(string model)
    {
        //String make = generateVehicleSpecification('Land Rover');
        //String model = generateModels(make);
        Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Promotional_Banner).getRecordTypeId();
        JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c(Name = 'Discovery Sport Campaign', JapaneseDescription__c = 'テスト', EnglishDescription__c = 'test', StartDate__c = system.today(),  EndDate__c = system.today().addDays(30), Product__c = model,RecordTypeId= campaignRecordTypeId );
        insert campaign;
    }
     public static void generateCampaign(string model, string market)
    {
        //String make = generateVehicleSpecification('Land Rover');
        //String model = generateModels(make);
        Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Promotional_Banner).getRecordTypeId();
        JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c(Name = 'Discovery Sport Campaign', JapaneseDescription__c = 'テスト', EnglishDescription__c = 'test', StartDate__c = system.today(),  EndDate__c = system.today().addDays(30), Product__c = model, Market__c = market,RecordTypeId= campaignRecordTypeId);
        insert campaign;
    }
    
    public static Id MakeId { get; set; }
    public static String  generateVehicleSpecification(String name)
    {
        Vehicle_Specification__c brand = new Vehicle_Specification__c(Name = name, CurrencyIsoCode = 'JPY');
        insert brand;
        return brand.Id;
    }
    
    public static void generateSavedVehicleForLead(Integer count, String leadId, String assetId)
    {
        List<Saved_Vehicle_for_Lead__c> vehicleList = new List<Saved_Vehicle_for_Lead__c>();
        for(Integer i = 0; i < count; i ++)
        {
            vehicleList.add(new Saved_Vehicle_for_Lead__c( Lead__c = leadId, Saved_Vehicle__c = assetId));
        }
        insert vehicleList;
    }

    public static List<Offers__c> createOfferList(String derivativeProduct2Id){
        return createOfferList(derivativeProduct2Id, null);
    }

        // Generates a list of 10 offers with random Types
    public static List<Offers__c> createOfferList(String derivativeProduct2Id, String servicePlanProduct2Id)
    {
        List<Offers__c> offers = new List<Offers__c>();
        for (Integer i = 0 ; i < 10; i++)
        {
            Offers__c offer = new Offers__c();
            List<Schema.PicklistEntry> picklistEntries =  Offers__c.Type__c.getDescribe().getPicklistValues();
            offer.Type__c = picklistEntries[Math.mod(i, picklistEntries.size())].getValue();
            offer.CurrencyIsoCode = 'JPY';
            if (string.isNotBlank(derivativeProduct2Id)){
                offer.Derivative_Product2Id__c = derivativeProduct2Id;
            }
            if(!String.isNotBlank(servicePlanProduct2Id)){
                offer.Service_Plan_Product2Id__c = servicePlanProduct2Id;
            }
            offer.Start_Date__c = date.today().addDays(-1);
            offer.End_Date__c = date.today().addDays(1);
            offer.IsActive__c = true;
            offers.add(offer);
        }
        insert offers;
        return  offers;
    }



    public static Id createServicePlan(String productCode)
    {
        Product2 servicePlan = new Product2(
                Name = 'Test Service Plan',
                Family = '2018', ProductCode = productCode,
                CurrencyIsoCode = 'JPY',
                Kilometers__c = 100, Months__c = 2,
                RecordTypeId = RecordTypeUtility.getRecordTypeId('Product2', 'Service Plans'),
                IsActive = true
        );
        insert servicePlan;
        return servicePlan.Id;
    }
}