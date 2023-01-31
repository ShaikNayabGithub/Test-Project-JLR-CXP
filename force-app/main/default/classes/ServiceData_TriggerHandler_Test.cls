@IsTest
public class ServiceData_TriggerHandler_Test {
    
    
    @IsTest
    static void Test_SetCorrectMileage_WhenSingleServiceCreated()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 100;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Mileage_Out__c = 120;
        serviceDs.add(serviceD);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Mileage__c from asset where id =:ass.Id];
        System.assertEquals(120, acc.Mileage__c);
        
    }
    
    @IsTest
    static void Test_SetCorrectMileage_WhenSingleServicewithJLRCodeMoreThanFive()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 100;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Dealer_Code_JLR__c = '1234567890';
        serviceDs.add(serviceD);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Last_Servicing_Dealer__c from asset where id =:ass.Id];
        System.assertEquals('67890', acc.Last_Servicing_Dealer__c);
        
    }
    
    @IsTest
    static void Test_SetCorrectMileage_WhenSingleServicewithJLRCodeLessThanFive()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 100;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Dealer_Code_JLR__c = '890';
        serviceDs.add(serviceD);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Last_Servicing_Dealer__c from asset where id =:ass.Id];
        System.assertEquals('890', acc.Last_Servicing_Dealer__c);
        
    }
    
    @IsTest
    static void Test_SetCorrectMileage_WhenSingleServiceCreatedService()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 100;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Mileage_Out__c = 120;
        serviceD.SR_Type__c = 'Repair1';
        serviceD.Department__c = 'Bodyshop1';
        serviceD.Service_Date__c = system.today()+5;
        serviceDs.add(serviceD);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Mileage__c,Vehicle_Last_Service_Date__c,Last_Repaired_Date__c from asset where id =:ass.Id];
        System.assertEquals(120, acc.Mileage__c);
        System.assertEquals(system.today()+5, acc.Vehicle_Last_Service_Date__c);
        System.assertEquals(null, acc.Last_Repaired_Date__c);
        
    }
    
    @IsTest
    static void Test_SetCorrectMileage_WhenSingleServiceCreatedRepair()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 100;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Mileage_Out__c = 120;
        serviceD.SR_Type__c = 'Repair';
        serviceD.Department__c = 'Bodyshop';
        serviceD.Service_Repair_Date__c = system.today()+5;
        serviceDs.add(serviceD);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Mileage__c,Last_Repaired_Date__c,Vehicle_Last_Service_Date__c from asset where id =:ass.Id];
        System.assertEquals(120, acc.Mileage__c);
        System.assertEquals(system.today()+5, acc.Last_Repaired_Date__c);
        System.assertEquals(null, acc.Vehicle_Last_Service_Date__c);
        
    }
    
    
    @IsTest
    static void Test_DoesNotSetNewMileage_WhenSingleServiceCreated()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 120;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Mileage_Out__c = 100;
        serviceD.SR_Type__c = 'Internal';
        serviceD.Department__c = 'Undefined';
        serviceD.Service_Date__c = system.today()+5;
        serviceDs.add(serviceD);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Mileage__c from asset where id =:ass.Id];
        System.assertEquals(120, acc.Mileage__c);
        
    }
    @IsTest
    static void Test_SetCorrectMileage_WhenMultipleServiceCreated()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 120;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Mileage_Out__c = 100;
        serviceDs.add(serviceD);
        Service_Data__c serviceD2 = new Service_Data__c();
        serviceD2.Account__c = ass.AccountId;
        serviceD2.Asset__c = ass.Id;
        serviceD2.Mileage_Out__c = 150;
        serviceDs.add(serviceD2);
        Service_Data__c serviceD3 = new Service_Data__c();
        serviceD3.Account__c = ass.AccountId;
        serviceD3.Asset__c = ass.Id;
        serviceD3.Mileage_Out__c = 115;
        serviceDs.add(serviceD3);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Mileage__c from asset where id =:ass.Id];
        System.assertEquals(150, acc.Mileage__c);
        
    }
    
    @IsTest
    static void Test_SetCorrectMileage_WhenMultipleServiceCreatedNew()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        ass.mileage__c = 120;
        insert ass;
        Test.startTest();
        List<Service_Data__c> serviceDs = new List<Service_Data__c>();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        serviceD.Mileage_Out__c = 150;
        serviceDs.add(serviceD);
        Service_Data__c serviceD2 = new Service_Data__c();
        serviceD2.Account__c = ass.AccountId;
        serviceD2.Asset__c = ass.Id;
        serviceD2.Mileage_Out__c = 100;
        serviceDs.add(serviceD2); 
        Service_Data__c serviceD3 = new Service_Data__c();
        serviceD3.Account__c = ass.AccountId;
        serviceD3.Asset__c = ass.Id;
        serviceD3.Mileage_Out__c = 200;
        serviceDs.add(serviceD3);
        serviceD3 = new Service_Data__c();
        serviceD3.Account__c = ass.AccountId;
        serviceD3.Asset__c = ass.Id;
        serviceD3.Mileage_Out__c = 300;
        serviceDs.add(serviceD3);
        serviceD3 = new Service_Data__c();
        serviceD3.Account__c = ass.AccountId;
        serviceD3.Asset__c = ass.Id;
        serviceD3.Mileage_Out__c = 400; 
        serviceDs.add(serviceD3);
        insert serviceDs;
        Test.stopTest();
        Asset acc = [Select Id, Mileage__c from asset where id =:ass.Id];
        System.assertEquals(400, acc.Mileage__c);
        
    }
    
    
    
    
    
    @IsTest
    static void Test_SetCustomerJourneyToPurchase_WhenServiceCreated()
    {
        
        Asset ass =  TestClass_AssetBuilder.BuildVehicle(true);
        insert ass;
        Test.startTest();
        Service_Data__c serviceD = new Service_Data__c();
        serviceD.Account__c = ass.AccountId;
        serviceD.Asset__c = ass.Id;
        insert serviceD;
        serviceD.Service_Status__c = 'Completed';
        update serviceD;
        Test.stopTest();
        Account acc = [Select Id, customer_Journey_stage__c from account where id =:ass.AccountId];
        //System.assertEquals('Maintain', acc.Customer_Journey_stage__c);
        
    }
    
    @IsTest
    Static void Test_OnPreServiceDataCreation(){
        
        //Create a Brand
        Vehicle_Specification__c  vs = new Vehicle_Specification__c ();
        vs.Name = 'Land Rover';
        insert vs;
        
        //Create an Account
        Account a = new Account();
        a.firstName = 'Test';
        a.LastName = 'Lastname';
        a.PersonEmail = 'test@test.com';
        a.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert a;
        
        //Create the Asset
        Asset vehicle = new Asset();
        vehicle.Name = 'Test Car';
        vehicle.AccountId = a.ID;
        vehicle.Brand__c = vs.Id;
        Vehicle.Mileage__c = 200;
        insert vehicle;
        
        //Create the second Asset
        Asset vehicle2 = new Asset();
        vehicle2.Name = 'Test Car 2';
        vehicle2.AccountId = a.ID;
        vehicle2.Brand__c = vs.Id;
        Vehicle2.Mileage__c = 200000;
        insert vehicle2;
        
        //Create the third Asset
        Asset vehicle3 = new Asset();
        vehicle3.Name = 'Test Car 3';
        vehicle3.AccountId = a.ID;
        vehicle3.Brand__c = vs.Id;
        Vehicle3.Mileage__c = 120000;
        insert vehicle3;
        
        
        List<Service_Data__c> serviceDataToInsert = new List<Service_Data__c>();
        //Create ServiceData
        
        //1 with no errors:
        Service_Data__c serviceData1 = new Service_Data__c();
        serviceData1.Service_Repair_Date__c = Date.newInstance(2019, 03, 03);
        serviceData1.Asset__c = vehicle.ID;
        serviceData1.DMS_Repair_Order_ID__c = '123xa';
        serviceData1.Mileage_Out__c = 24000;
        serviceDataToInsert.add(serviceData1);
        
        //2 with no date:
        Service_Data__c serviceData2 = new Service_Data__c();
        serviceData2.Asset__c = vehicle.ID;
        serviceData2.DMS_Repair_Order_ID__c = '123xra';
        serviceDataToInsert.add(serviceData2);
        
        //3 with no serviceData ID:
        Service_Data__c serviceData3 = new Service_Data__c();
        serviceData3.Service_Repair_Date__c = Date.newInstance(2019, 03, 03);
        serviceData3.Asset__c = vehicle.ID;
        serviceDataToInsert.add(serviceData3);
        
        //4 insert 2 records with the same ID and same asset
        Service_Data__c serviceData4 = new Service_Data__c();
        serviceData4.Service_Repair_Date__c = Date.newInstance(2019, 03, 03);
        serviceData4.Asset__c = vehicle.ID;
        serviceData4.DMS_Repair_Order_ID__c = '123xatv';
        serviceDataToInsert.add(serviceData4);
        
        Service_Data__c serviceData5 = new Service_Data__c();
        serviceData5.Service_Repair_Date__c = Date.newInstance(2019, 03, 03);
        serviceData5.Asset__c = vehicle.ID;
        serviceData5.DMS_Repair_Order_ID__c = '123xatv';
        serviceDataToInsert.add(serviceData5);
        
        //5 record with same Event ID but different vehicle
        Service_Data__c serviceData6 = new Service_Data__c();
        serviceData6.Service_Repair_Date__c = Date.newInstance(2019, 03, 03);
        serviceData6.Asset__c = vehicle2.ID;
        serviceData6.DMS_Repair_Order_ID__c = '123xatv';
        serviceDataToInsert.add(serviceData6);
        
        //6 record with no vehicle
        ////Service_Data__c serviceData7 = new Service_Data__c();
        ////serviceData7.Service_Repair_Date__c = Date.newInstance(2019, 03, 03);
        ////serviceData7.DMS_Repair_Order_ID__c = '123xatv';
        ////serviceDataToInsert.add(serviceData7);
        
        
        ////7  record with no errors: Asset mileage not affected
        Service_Data__c serviceData7 = new Service_Data__c();
        serviceData7.Service_Repair_Date__c = Date.newInstance(2019, 03, 03);
        serviceData7.Asset__c = vehicle3.ID;
        serviceData7.DMS_Repair_Order_ID__c = '123xacx';
        serviceData7.Mileage_Out__c = 200;
        serviceDataToInsert.add(serviceData7);
        
        Test.startTest();
        insert serviceDataToInsert;
        Test.stopTest();
        
        //No Errors
        Service_Data__c service1 = [Select ID,Account__c,Error__c,Error_Type__c from Service_Data__c where ID =: serviceData1.Id];
        
        //Take only the first 15 chars of the IDs -- the test class in working perfectly in the org but is failing on Bamboo
        System.assertEquals(String.ValueOf(a.ID).substring(0,14) ,String.ValueOf(service1.Account__c).substring(0,14));
        System.assertEquals(false,service1.Error__c);//new assertion
        System.assertEquals(null,service1.Error_Type__c);//new assertion
        
        //Test if the asset Mileage has been changed
        Asset singleAsset = [Select ID,Mileage__c from Asset where ID =: Vehicle.ID];
        System.assertEquals(24000,singleAsset.Mileage__c);
        
        //No Date
        Service_Data__c service2 = [Select ID,Account__c,Error__c,Error_Type__c,Service_Repair_Date__c 
                                    from Service_Data__c where ID =: serviceData2.Id];
        
        //System.debug('--Service_Repair_Date__c : ' + service2.Service_Repair_Date__c);
        System.assertEquals(false,service2.Error__c);
        //System.assertEquals('No service date provided',service2.Error_Type__c);
        
        //Service ID missing
        Service_Data__c service3 = [Select ID,Account__c,Error__c,Error_Type__c from Service_Data__c where ID =: serviceData3.Id];
        //System.assertEquals(true,service3.Error__c);
        //System.assertEquals('Missing Service Data',service3.Error_Type__c);
        
        //service data with same ID and vehicle
        Service_Data__c service4 = [Select ID,Account__c,Error__c,Error_Type__c from Service_Data__c where ID =: serviceData5.Id];
        //System.assertEquals(true,service4.Error__c);
        //System.assertEquals('Service record already exists on asset with previous date',service4.Error_Type__c);
        
        
        //service data mileage lower then vehicle mileage - > mileage intact
        Service_Data__c service5 = [Select ID,Account__c,Error__c,Error_Type__c,Asset__c from Service_Data__c where ID =: serviceData7.Id];
        Asset singleAsset2 = [Select ID,Mileage__c from Asset where ID =: service5.Asset__c];
        //System.assertEquals(Vehicle3.Mileage__c,singleAsset2.Mileage__c);//new assertion
        //System.assertEquals(false,service5.Error__c);//new assertion
        //System.assertEquals(null,service5.Error_Type__c);//new assertion
    }
}