@IsTest
public class TestClass_AssetBuilder {
    
    public static Asset BuildVehicle(){
        return BuildVehicle(false);
    }
    public static Asset BuildAndInsertVehicle(){
        Asset ass = BuildVehicle(false);
        insert ass;
        return ass;
    }

    public static Asset BuildAndInsertVehicle(Boolean personAccountOwner){
        Asset ass = BuildVehicle(personAccountOwner);
        insert ass;
        return ass;
    }

    public static Asset BuildVehicle(Boolean personAccountOwner){
        //query for the record types we wish to assign once in order to reduce soql queries
        //Map<String, Id> requiredRecordTypes = new Map<String, Id>();
        //for(RecordType rt : [SELECT Id, Name, SObjectType FROM RecordType WHERE Name IN ('Vehicle', 'Model', 'Derivative') AND SObjectType IN ('Asset', 'Product2')]){
        //    if(rt.Name.equalsIgnoreCase('VEHICLE') && rt.SObjectType.equalsIgnoreCase('ASSET')) requiredRecordTypes.put('VEHICLE', rt.Id);
        //    else if(rt.Name.equalsIgnoreCase('MODEL') && rt.SObjectType.equalsIgnoreCase('PRODUCT2')) requiredRecordTypes.put('MODEL', rt.Id);
        //    else if(rt.Name.equalsIgnoreCase('DERIVATIVE') && rt.SObjectType.equalsIgnoreCase('PRODUCT2')) requiredRecordTypes.put('DERIVATIVE', rt.Id);
        //} 
        //Asset must have a parent Account
        Account retailer;
        if(personAccountOwner) retailer = TestClass_AccountCreator.createPersonAccount();
        else retailer = TestClass_AccountCreator.CreateRetailer(); //utility method saves Account
        //need to create a Brand and a Model
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake(); //utility method saves Vehicle Spec
        Product2 model = new Product2(Name='TestModel');
        //if(requiredRecordTypes.containsKey('MODEL')) model.RecordTypeId = requiredRecordTypes.get('MODEL');
        model.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        model.Make__c = make.Id;
        insert model;
        Product2 derivative = new Product2(Name='TestDerivative');
        derivative.Make__c = make.Id;
        //if(requiredRecordTypes.containsKey('DERIVATIVE')) derivative.RecordTypeId = requiredRecordTypes.get('DERIVATIVE');
        derivative.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        derivative.Model__c = model.Id;
        insert derivative;
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=retailer.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id , Model_Year_Description__c = '2021 MY' , Model_Year_code__c = '001');
        //if(requiredRecordTypes.containsKey('VEHICLE')) vehicle.RecordTypeId = requiredRecordTypes.get('VEHICLE');
        vehicle.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        return vehicle;
    }
    
    public static List<Asset> BuildVehicles(Integer numberVehicles){
        return BuildVehicles(numberVehicles, false);
    }
    
    public static List<Asset> BuildVehicles(Integer numberVehicles, Boolean personAccountOwner){
        List<Asset> vehicleList = new List<Asset>();
        //only need to create one Retailer, one Make and one Model
        //query for the record types we wish to assign once in order to reduce soql queries
        //Map<String, Id> requiredRecordTypes = new Map<String, Id>();
        //for(RecordType rt : [SELECT Id, Name, SObjectType FROM RecordType WHERE Name IN ('Vehicle', 'Model') AND SObjectType IN ('Asset', 'Product2')]){
        //    if(rt.Name.equalsIgnoreCase('VEHICLE') && rt.SObjectType.equalsIgnoreCase('ASSET')) requiredRecordTypes.put('VEHICLE', rt.Id);
        //    else if(rt.Name.equalsIgnoreCase('MODEL') && rt.SObjectType.equalsIgnoreCase('PRODUCT2')) requiredRecordTypes.put('MODEL', rt.Id);
        //}
        //Asset must have a parent Account
        Account retailer;
        if(personAccountOwner) retailer = TestClass_AccountCreator.createPersonAccount(); //utility method saves Account
        else retailer = TestClass_AccountCreator.CreateRetailer();
        //need to create a Brand and a Model
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake(); //utility method saves Vehicle Spec
        Product2 model = new Product2(Name='TestModel');
        //if(requiredRecordTypes.containsKey('MODEL')) model.RecordTypeId = requiredRecordTypes.get('MODEL');
        model.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        model.Make__c = make.Id;
        insert model;
        for(Integer i=0; i<numberVehicles; i++){
            String formattedName = String.valueOf(i);
            if(formattedName.length() < 2){
                formattedName = '00' + formattedName;
            }
            else if(formattedName.length() < 3){
                formattedName = '0' + formattedName;
            }
            Asset vehicle = new Asset(Name='TestVehicle' + formattedName, AccountId=retailer.Id, Brand__c=make.Id, Model__c=model.Id);
            //if(requiredRecordTypes.containsKey('VEHICLE')) vehicle.RecordTypeId = requiredRecordTypes.get('VEHICLE');
            vehicle.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            vehicleList.add(vehicle);
        }
        return vehicleList;
    }
    public static List<Asset> createAssetList(Integer numberOfAssetsToCreate, Id accountId, Product2 derivative)
    {

        List<Asset> assets = new List<Asset>();
        for (Integer i = 0; i < numberOfAssetsToCreate; i++)
        {
            Asset ass = new Asset();
            ass.Name = 'Test' + i;
            List<Schema.PicklistEntry> picklistEntries =  Asset.Status.getDescribe().getPicklistValues();
            ass.Status =  picklistEntries[Math.mod(i, picklistEntries.size())].getValue();
            ass.AccountId = accountId;
            ass.Brand__c = derivative.Make__c;
            ass.Model__c = derivative.Model__c;
            ass.Derivative__c = derivative.Id;
            ass.VIN__c = 'SAL12345676'+i;
            assets.add(ass);
        }
        insert assets;
        return assets;
    }

    public static List<Asset> createAssetList(Integer numberOfAssetsToCreate, String accountId)
    {
        Product2 derivative = buildDerivative();
        System.debug(JSON.serialize(derivative));
        List<Asset> assets = new List<Asset>();
        for (Integer i = 0; i < numberOfAssetsToCreate; i++)
        {
            Asset ass = new Asset();
            ass.Name = 'Test' + i;
            List<Schema.PicklistEntry> picklistEntries =  Asset.Status.getDescribe().getPicklistValues();
            ass.Status =  picklistEntries[Math.mod(i, picklistEntries.size())].getValue();
            ass.AccountId = accountId;
            ass.Brand__c = derivative.Make__c;
            ass.Model__c = derivative.Model__c;
            ass.Derivative__c = derivative.Id;
            ass.VIN__c = 'SAL12345676'+i;
            assets.add(ass);
        }
        insert assets;
        return assets;
    }

    public static String  generateAsset(Id retailer)
    {
        Product2 derivative = buildDerivative();
        Asset asset = new Asset(
                Name = 'SALCA2AG0GH550580',
                VIN__c = 'SN1111111111111111',
                Brand__c = derivative.Make__c,
                CurrencyIsoCode = 'JPY',
                AccountId = retailer,
                Price = 10000000,
                Local_price__c = 10000000,
                Name_Plate__c = 'Discovery Sport',
                Model__c = derivative.Model__c,
                Product2Id = derivative.Id ,
                Derivative__c = derivative.Id
        );
        insert asset;
        return asset.Id;
    }

    public static String generateModels(String modelName, Id makeId)
    {
        Product2 model = new Product2(
                Name = modelName,
                Make__c = makeId,
                CurrencyIsoCode = 'JPY',
                RecordTypeId = RecordTypeUtility.getRecordTypeId('Product2', 'Model')
        );
        insert model;
        return model.Id;
    }

    public static String generateModelVehicleSpecAustralia(String modelName, Id makeId)
    {
        Vehicle_Specification__c model = new Vehicle_Specification__c();
            model.Name = modelName;
        model.Is_Australia__c = true;
        model.RecordTypeId = RecordTypeUtility.getRecordTypeId('Vehicle_Specification__c', 'Model');
        model.Make__c = makeId;
        model.Is_Currently_Sold__c = true;
        model.Not_Sold_In__c = '';


        insert model;
        return model.Id;
    }


    public static Product2 generateDerivative(Id modelId, Id vehicleSpecId)
    {

        Product2 derivative = new Product2(
                Name = 'Discovery Sport 2.0L Si4 Petrol 5DR TL4 - HSE LUX, Japan JAP, IUTV/350QD, 2016.5',
                CurrencyIsoCode = 'JPY',
                Registration_Year_Alternative__c = '2018',
                RecordTypeId = RecordTypeUtility.getRecordTypeId('Product2', 'Derivative'),
                Model_Alternative__c = 'Discovery Sport',
                Model__c = modelId,
                Make__c = vehicleSpecId);
        insert derivative;
        return derivative;
    }

    public static String  generateVehicleSpecification(String name)
    {
        Vehicle_Specification__c brand = new Vehicle_Specification__c(Name = name, CurrencyIsoCode = 'JPY');
        brand.aop_JLR_Owned__c = true;
        insert brand;
        return brand.Id;
    }

    public static Product2 buildDerivative(){
        String makeId = generateVehicleSpecification('Land Rover');
        String modelId = generateModels('Test Model', makeId);
        return generateDerivative(modelId, makeId);
    }

    public static Product2 buildDerivativeAustralia(){
        String makeId = generateVehicleSpecification('Land Rover');
        String modelId = generateModels('Test Model', makeId);
        Product2 product = generateDerivative(modelId, makeId);
        product.Model_Vehicle_Spec__c = generateModelVehicleSpecAustralia('Test Model', makeId);
        update product;
        return product;
    }
}