@isTest
public class LC_AssetOwnershipMismatchController_Test {

    public static testmethod void Controller_ReturnsTrueWhenAssetOwnedByRetailerAndHasRoadsideEvent() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account retailerAccount = new Account(Name = 'Test Retailer', RecordTypeId = retailerRecordTypeId);
        insert retailerAccount;
        //create Asset
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Product2 model = new Product2(Name='TestModel', Make__c=make.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        Product2 derivative = new Product2(Name='TestDerivative', Make__c=make.Id, Model__c=model.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivative;
        Id vehicleRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=retailerAccount.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id, RecordTypeId=vehicleRecordTypeId);
        insert vehicle;
        Id roadsideRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').getRecordTypeId();
        Event roadsideEvent = new Event(Subject='Test Event', StartDateTime=DateTime.now(), EndDateTime=DateTime.now().addHours(1), RecordTypeId=roadsideRecordTypeId, WhatId=vehicle.Id);
        insert roadsideEvent;
        System.assert(LC_AssetOwnershipMismatch_Controller.getMismatchWarningMessage(vehicle.Id) == true);
    }
    
    public static testmethod void Controller_ReturnsFalseWhenAssetNotOwnedByRetailerAndHasRoadsideEvent() {
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Account corporateAccount = new Account(Name = 'Test Retailer', RecordTypeId = corporateRecordTypeId);
        insert corporateAccount;
        //create Asset
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Product2 model = new Product2(Name='TestModel', Make__c=make.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        Product2 derivative = new Product2(Name='TestDerivative', Make__c=make.Id, Model__c=model.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivative;
        Id vehicleRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=corporateAccount.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id, RecordTypeId = vehicleRecordTypeId);
        insert vehicle;
        Id roadsideRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').getRecordTypeId();
        Event roadsideEvent = new Event(Subject='Test Event', StartDateTime=DateTime.now(), EndDateTime=DateTime.now().addHours(1), RecordTypeId=roadsideRecordTypeId, WhatId=vehicle.Id);
        insert roadsideEvent;
        System.assert(LC_AssetOwnershipMismatch_Controller.getMismatchWarningMessage(vehicle.Id) == false);
    }
    
    public static testmethod void Controller_ReturnsTrueWhenAssetOwnedByRetailerAndHasContract() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account retailerAccount = new Account(Name = 'Test Retailer', RecordTypeId = retailerRecordTypeId);
        insert retailerAccount;
        //create Asset
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Product2 model = new Product2(Name='TestModel', Make__c=make.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        Product2 derivative = new Product2(Name='TestDerivative', Make__c=make.Id, Model__c=model.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivative;
        Id vehicleRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=retailerAccount.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id, RecordTypeId=vehicleRecordTypeId);
        insert vehicle;
        Id roadsideRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').getRecordTypeId();
        Contract cont = new Contract(StartDate=Date.today(), AccountId=retailerAccount.Id, Asset__c=vehicle.Id);
        insert cont;
        System.assert(LC_AssetOwnershipMismatch_Controller.getMismatchWarningMessage(vehicle.Id) == true);
    }
    
    public static testmethod void Controller_ReturnsFalseWhenAssetNotOwnedByRetailerAndHasContract() {
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Account corporateAccount = new Account(Name = 'Test Retailer', RecordTypeId = corporateRecordTypeId);
        insert corporateAccount;
        //create Asset
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Product2 model = new Product2(Name='TestModel', Make__c=make.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        Product2 derivative = new Product2(Name='TestDerivative', Make__c=make.Id, Model__c=model.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivative;
        Id vehicleRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=corporateAccount.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id, RecordTypeId = vehicleRecordTypeId);
        insert vehicle;
        Id roadsideRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').getRecordTypeId();
        Contract cont = new Contract(StartDate=Date.today(), AccountId=corporateAccount.Id, Asset__c=vehicle.Id);
        insert cont;
        System.assert(LC_AssetOwnershipMismatch_Controller.getMismatchWarningMessage(vehicle.Id) == false);
    }
    
    public static testmethod void Controller_ReturnsTrueWhenAssetOwnedByRetailerAndHasServiceData() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account retailerAccount = new Account(Name = 'Test Retailer', RecordTypeId = retailerRecordTypeId);
        insert retailerAccount;
        //create Asset
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Product2 model = new Product2(Name='TestModel', Make__c=make.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        Product2 derivative = new Product2(Name='TestDerivative', Make__c=make.Id, Model__c=model.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivative;
        Id vehicleRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=retailerAccount.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id, RecordTypeId=vehicleRecordTypeId);
        insert vehicle;
        Id roadsideRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').getRecordTypeId();
        Service_Data__c service = new Service_Data__c(Asset__c=vehicle.Id);
        insert service;
        System.assert(LC_AssetOwnershipMismatch_Controller.getMismatchWarningMessage(vehicle.Id) == true);
    }
    
    public static testmethod void Controller_ReturnsFalseWhenAssetNotOwnedByRetailerAndHasServiceData() {
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Account corporateAccount = new Account(Name = 'Test Retailer', RecordTypeId = corporateRecordTypeId);
        insert corporateAccount;
        //create Asset
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Product2 model = new Product2(Name='TestModel', Make__c=make.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        Product2 derivative = new Product2(Name='TestDerivative', Make__c=make.Id, Model__c=model.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivative;
        Id vehicleRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=corporateAccount.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id, RecordTypeId = vehicleRecordTypeId);
        insert vehicle;
        Id roadsideRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').getRecordTypeId();
        Service_Data__c service = new Service_Data__c(Asset__c=vehicle.Id);
        insert service;
        System.assert(LC_AssetOwnershipMismatch_Controller.getMismatchWarningMessage(vehicle.Id) == false);
    }
    
    public static testmethod void Controller_ReturnsFalseWhenAssetOwnedByRetailerAndHasNoRelatedRecords() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account retailerAccount = new Account(Name = 'Test Retailer', RecordTypeId = retailerRecordTypeId);
        insert retailerAccount;
        //create Asset
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Product2 model = new Product2(Name='TestModel', Make__c=make.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        Product2 derivative = new Product2(Name='TestDerivative', Make__c=make.Id, Model__c=model.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivative;
        Id vehicleRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=retailerAccount.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id, RecordTypeId=vehicleRecordTypeId);
        insert vehicle;
        System.assert(LC_AssetOwnershipMismatch_Controller.getMismatchWarningMessage(vehicle.Id) == false);
    }

}