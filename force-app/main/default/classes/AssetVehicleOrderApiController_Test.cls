@isTest
public class AssetVehicleOrderApiController_Test {
    
    @isTest static void TestAssetVehicle(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'ValidOrder'));
        Product2 derivative = TestClass_AssetBuilder.buildDerivative();
        derivative.ProductCode = '5000529105';
        update derivative;
        
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        assetIns.VIN__c = 'Vin123456';
        assetIns.Product2Id = derivative.Id;
        update assetIns;
        
        Test.startTest();
        AssetVehicleOrderApiController.AssetWrap assetWrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(assetIns.Id);
        system.assertEquals(assetWrapIns.message,'Asset has been updated Successfully!');
        system.assertEquals(assetWrapIns.hasError,false);
        Test.stopTest();
    }
    @isTest static void TestAssetVehicleTokenBadRequest(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(400,200,'ValidOrder'));
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        assetIns.VIN__c = 'Vin123456';
        update assetIns;
        Test.startTest();
        AssetVehicleOrderApiController.AssetWrap assetWrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(assetIns.Id);
        system.assertEquals(assetWrapIns.message,'Error Occured during Access Token Call {"access_token":"e2c5f19c","scope":"am_application_scope default","token_type":"Bearer","expires_in":3600}');
        system.assertEquals(assetWrapIns.hasError,true);
        Test.stopTest();
    }
    @isTest static void TestAssetVehicleBadRequest(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,400,'ValidOrder'));
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        assetIns.VIN__c = 'Vin123456';
        update assetIns;
        Test.startTest();
        AssetVehicleOrderApiController.AssetWrap assetWrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(assetIns.Id);
        // system.assertEquals(assetWrapIns.message,'Error Occured during Vehicle Orders Call {"commonOrderNo":"Order123456","distributorRef":"111904","brand":{"id":"SAL","descr":"Land Rover","lang":"en-GB"},"model":{"id":"S8","descr":"L560 Range Rover Velar","orgLevel":30,"lang":"en-GB"},"modelYear":{"id":"001CB","descr":"2018 Model Year","orgLevel":10,"lang":"en-GB"},"product":{"id":"5000313200","descr":"L560 3.0P Si6 S/C AWD 5DR SWB First Edition, Brazil BRA, AM560/560AJ, 2018","lang":"en-GB"},"placingOrganisationId":"SALN661006777","placingOrgansationMarket":{"id":"BH","descr":"Brazil","lang":"en-GB"},"distributorUniqueId":"SALN6610","orderMarket":{"id":"BH","descr":"Brazil","lang":"en-GB"},"globalSalesType":{"id":"P"},"commonOrderType":{"id":"1","descr":"Private Individual","lang":"en-GB"},"typeOfSale":{"id":"AAA","descr":"Individual","lang":"en-GB"},"brandOrderType":{"id":"RET","descr":"Individual","lang":"en-GB"},"orderCreatedDate":"2017-01-13T13:28:32Z","acceptedBuildStartDate":"2017-06-16","manufactureASAPIndicator":false,"soldBuildToOrderDate":"2017-11-30","lastSpecificationChangeDate":"2017-08-09","plannedHandoverDate":"2017-12-27","currentStatus":{"id":"175","descr":"Customer Handover","lang":"en-GB","timestamp":"2017-11-30T17:30:27Z"},"brandOrderStatus":{"id":"HANDOVER","descr":"Customer Handover (HANDOVER)","lang":"en-GB"},"orderFrozenIndicator":false,"autoTradeIndicator":false,"onlineSalesIndicator":false,"svoIndicator":false,"wltpSensitive":false,"financialStatus":"660","indicativeCo2Emission":0.0,"indicativeFuelEfficiency":0.0,"indicativeElectricEfficiency":0.0,"indicativePer":0.0,"indicativeAer":0.0,"indicativeEaer":0.0,"indicativeUfWeightedFC":0.0,"indicativeUfWeightedEC":0.0,"finalCo2Emission":0.0,"finalFuelEfficiency":0.0,"finalElectricEfficiency":0.0,"finalPer":0.0,"finalAer":0.0,"finalEaer":0.0,"finalUfWeightedEC":0.0,"finalUfWeightedFC":0.0,"pedVersion":0.0,"vin":"Vin123456","shortVin":"Vin123","engineNumber":"17083010484306PS","chassisNumber":"721307","registrationNumber":"30/11/2017","registrationDate":"2017-11-30","basePrice":0.0,"totalFixedPrice":0.0,"totalOnRoadPrice":0.0,"totalLocalOptionsPrice":0.0,"totalOptionalFeaturesPrice":0.0}');
        system.assertEquals(assetWrapIns.hasError,true);
        Test.stopTest();
    }
    
    @isTest static void TestAssetVehicleWithoutOrdernumber(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'ValidOrder'));
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.VIN__c = 'Vin123456';
        update assetIns;
        Test.startTest();
        AssetVehicleOrderApiController.AssetWrap assetWrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(assetIns.Id);
        system.assertEquals(assetWrapIns.message,'Asset has been updated Successfully!');
        system.assertEquals(assetWrapIns.hasError,false);
        Test.stopTest();
    }
    
    @isTest static void TestAssetVehicleVin(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'ValidOrder'));
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        update assetIns;
        Test.startTest();
        AssetVehicleOrderApiController.AssetWrap assetWrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(assetIns.Id);
        system.assertEquals(assetWrapIns.message,'Asset has been updated Successfully!');
        system.assertEquals(assetWrapIns.hasError,false);
        Test.stopTest();
    }
    
    @isTest static void TestAssetVehicleVinOrOrder(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'ValidOrder'));
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Test.startTest();
        AssetVehicleOrderApiController.AssetWrap assetWrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(assetIns.Id);
        system.assertEquals(assetWrapIns.message,'Invalid Asset Record');
        system.assertEquals(assetWrapIns.hasError,true);
        Test.stopTest();
    }
    
    @isTest static void TestAssetVehicleWithNullValue(){
        Test.startTest();
        AssetVehicleOrderApiController.AssetWrap assetWrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(null);
        system.assertEquals(assetWrapIns.message,'Invalid Asset Id');
        system.assertEquals(assetWrapIns.hasError,true);
        Test.stopTest();
    }
    @isTest static void TestAssetVehicleOrderApiWrapper(){
        AssetVehicleOrderApiWrapper orderApi = new AssetVehicleOrderApiWrapper();
        orderApi.onlineSalesIndicator = true;
        orderApi.svoIndicator  = true;
        orderApi.wltpSensitiveIndicator  = true;
        orderApi.archiveStatus  = true;
        orderApi.autoTradeIndicator  = true;
        orderApi.orderFrozenIndicator  = true;
        orderApi.orderDate = '1/1/2020';
        orderApi.orderConfirmedDate   = '1/1/2020';
        orderApi.lastNormalSpecificationChangeDate = '1/1/2020';
        orderApi.lastConfirmationResponseDate = '1/1/2020';
        orderApi.currentPlannedBuildDate  = '1/1/2020';
        orderApi.acceptedBuildDate    = '1/1/2020';
        orderApi.firstPlannedDeliveryDate    = '1/1/2020';
        orderApi.currentPlannedDeliveryDate = '1/1/2020';
        orderApi.acceptedDeliveryDate  = '1/1/2020';
        orderApi.factoryCompleteDate = '1/1/2020';
        orderApi.rccUrl    = 'https://cxp--preprod.my.salesforce.com/';
        orderApi.commonOrderNo    = '12345';
        orderApi.retailerRef    =  '12345';
        orderApi.distributorRef   = '12345';
        orderApi.plantOrderNo    = '12345';
        orderApi.financialStatus    = '12345';
        orderApi.plant = '12345';
        orderApi.shortVin = '12345';
        orderApi.manufactureASAPIndicator = true;
        
        AssetVehicleOrderApiWrapper.Derivative derIns = new AssetVehicleOrderApiWrapper.Derivative();
        derIns.type_Z = 'Type1';
        derIns.id = 'Type1';
        derIns.group_Z = 'Type1';
        derIns.descr = 'Type1';
        derIns.lang = 'Type1';
        
        AssetVehicleOrderApiWrapper.Vehicle vehIns = new AssetVehicleOrderApiWrapper.Vehicle();
        AssetVehicleOrderApiWrapper.SteeringCode codeIns = new AssetVehicleOrderApiWrapper.SteeringCode();
        AssetVehicleOrderApiWrapper.GlobalSalesType glIns = new AssetVehicleOrderApiWrapper.GlobalSalesType();
        AssetVehicleOrderApiWrapper.OrderMarket ordMarkIns = new AssetVehicleOrderApiWrapper.OrderMarket();
        vehIns.vin = 'Order12345';
        vehIns.shortVin = 'Order12345';
        vehIns.specificationLock = 'Order12345';
        vehIns.programId = 'Order12345';
        vehIns.engineNo = 'Order12345';
        vehIns.chassisNo = 'Order12345';
        vehIns.registrationNo = 'Order12345';
        vehIns.pedVersion = 'Order12345';
        vehIns.pedCertificateStatus = 'Order12345';
        vehIns.vin = 'Order12345';
        vehIns.specificationMarket = codeIns;
        vehIns.brochureModel = codeIns;
        vehIns.engineType = codeIns;
        vehIns.bodyStyle = codeIns;
        vehIns.drive = codeIns;
        vehIns.wheelBase = codeIns;
        vehIns.exteriorColour = codeIns;
        vehIns.trim = codeIns;
        vehIns.transmission = codeIns;
        vehIns.fuelType = codeIns;
        vehIns.x_embedded = codeIns;
        vehIns.trim = codeIns;
        vehIns.steeringCode = codeIns;
        vehIns.derivativePack = codeIns;
        vehIns.derivative = derIns;
        vehIns.brand = ordMarkIns;
        vehIns.model = glIns;
        vehIns.modelYear = glIns;
        
        AssetVehicleOrderApiWrapper.Prices PriceIns = new AssetVehicleOrderApiWrapper.Prices();
        PriceIns.priceType = 'New';
        PriceIns.priceValue = 1234567890;
        PriceIns.source = 'New';
        
        AssetVehicleOrderApiWrapper.PlacingOrganisationId orgIns = new AssetVehicleOrderApiWrapper.PlacingOrganisationId();
        orgIns.id = '12345';
        orgIns.organisationId = '12345';
        orgIns.name = '12345';
        orgIns.addressLine1 = '12345';
        orgIns.city = '12345';
        orgIns.postCode = '12345';
        orgIns.countryCode = '12345';
        
        AssetVehicleOrderApiWrapper.Distribution distIns = new AssetVehicleOrderApiWrapper.Distribution();
        distIns.commonOrderNo = 'Order12345';
        distIns.shippingBillOfLadingId = 'Order12345';
        distIns.plannedDeliveryDate = 'Order12345';
        distIns.acceptedDeliveryDate = 'Order12345';
        distIns.commonOrderNo = 'Order12345';
        distIns.calloverIndicator = 'Order12345';
        
        AssetVehicleOrderApiWrapper.OrderMarket ordIns = new AssetVehicleOrderApiWrapper.OrderMarket();
        ordIns.id = '123456';
        ordIns.descr = '123456';
        ordIns.lang = 'Eng-Gb';
        
        AssetVehicleOrderApiWrapper.FinalDestination finDes = new AssetVehicleOrderApiWrapper.FinalDestination();
        finDes.id = '12345';
        finDes.desc_Z = '12345';
        finDes.orgLevel = '12345';
        
    }
}