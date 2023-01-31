@isTest
public class AccountJagANDLRStatusHandler_Test {
    
    @testsetup static void testSetupData(){
        account acc=new account();
        acc.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        acc.firstname='individual';
        acc.lastname='dfsdf';
        acc.personemail='invidivudal@fafds.com';
        acc.phone='0074343430';
        acc.Owner_Retailer__c = 'Test';
        insert acc; 
    }
    
    @isTest static void testOppInsertDataJaguar(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        update retailer;
        
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test OppName Name';
        opp.StageName = 'Negotiation';
        opp.AccountId = retailer.Id;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        opp.VME_Segment__c = 'Not Applicable';
        opp.VME_Sub_Division__c = 'Not Applicable';
        opp.VME_Trade_in_Type__c = 'Not Applicable';
        insert opp;
        
        opp.StageName = 'Order';
        Test.startTest();
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, vehicleSpec1.Id, null);
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        opportunityLineItem1.Asset__c = ass.Id;
        opportunityLineItem1.Vista_Order_Number__c = '123456';
        insert opportunityLineItem1;
        update opp;
        Test.stopTest();
    }
    
    @isTest static void testOppInsertDataLandRover(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Land Rover';
        insert vehicleSpec1;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test OppName Name';
        opp.StageName = 'Negotiation';
        opp.AccountId = retailer.Id;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        opp.VME_Segment__c = 'Not Applicable';
        opp.VME_Sub_Division__c = 'Not Applicable';
        opp.VME_Trade_in_Type__c = 'Not Applicable';
        insert opp;
        
        opp.StageName = 'Order';
        Test.startTest();
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, vehicleSpec1.Id, null);
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        opportunityLineItem1.Asset__c = ass.Id;
        opportunityLineItem1.Vista_Order_Number__c = '123456';
        insert opportunityLineItem1;
        update opp;
        Test.stopTest();
    }
    
    @isTest static void testRoleInsertDataJaguar(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = BuildVehicle('Jaguar');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        Test.startTest();
        insert role;
        Test.Stoptest();
    }
    
    @isTest static void testRoleInsertDataJaguarUpdate(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = BuildVehicle('Jaguar');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        insert role;
        Test.startTest();
        role.Role__c = 'Previous Owner';
        update role;
        Test.Stoptest();
    }
    
    @isTest static void testRoleInsertDataJaguarMultipleData(){
        List<Role__c> roleList = new List<Role__c>();
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = BuildVehicle('Jaguar');
        
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        roleList.add(role);
        
        role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        roleList.add(role);
        
        role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Previous Owner';
        roleList.add(role);
        
        role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Previous Owner';
        roleList.add(role);
        
        Test.startTest();
        insert roleList;
        Test.Stoptest();
    }
    
    @isTest static void testRoleInsertDataLandRover(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = BuildVehicle('Land Rover');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        Test.startTest();
        insert role;
        Test.Stoptest();
    }
    
    @isTest static void testRoleInsertDataLandRoverMultiple(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = BuildVehicle('Land Rover');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        insert role;
        Test.startTest();
        role.Role__c = 'Previous Owner';
        update role;
        Test.Stoptest();
    }
    
    @isTest static void testRoleInsertDataLandRoverMultipleData(){
        List<Role__c> roleList = new List<Role__c>();
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = BuildVehicle('Land Rover');
        
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        roleList.add(role);
        
        role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        roleList.add(role);
        
        role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Previous Owner';
        roleList.add(role);
        
        role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Previous Owner';
        roleList.add(role);
        
        Test.startTest();
        insert roleList;
        Test.Stoptest();
    }
    @isTest static void testRoleInsertLapsedJaguar(){
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Test.startTest();
        retailer.Customer_Journey_Stage__c = 'Lapse';
        update retailer;
        Test.Stoptest();
    }
    
    @IsTest
    static void Test_SetCustomerJourneyToTakeOwnership_WhenOpportunityUpdatedToHandover() {
        System.debug('Test_SetCustomerJourneyToPurchased_WhenOpportunityUpdatedToOrder START');
        Opportunity opp = new Opportunity();
        opp = createOpportunity();
        Test.startTest();
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
        insert opportunityLineItem1;
        Test.stopTest();
        opp.StageName = 'Handover';
        //opp.Customer_Journey_Stage_Update__c = 'Enjoy';
        update opp;
        
    } 
    
    public static Asset BuildVehicle(String vehicleBrand){
        Account retailer = TestClass_AccountCreator.CreateRetailer(); //utility method saves Account
        Vehicle_Specification__c make = BuildMake(vehicleBrand); //utility method saves Vehicle Spec
        Product2 model = new Product2(Name='TestModel');
        model.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        model.Make__c = make.Id;
        insert model;
        Product2 derivative = new Product2(Name='TestDerivative');
        derivative.Make__c = make.Id;
        derivative.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        derivative.Model__c = model.Id;
        insert derivative;
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=retailer.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id);
        vehicle.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        insert vehicle;
        return vehicle;
    }
    
    public static Vehicle_Specification__c BuildMake(String vehicleBrand){ 
        Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        make.Name = vehicleBrand; 
        insert make; 
        return make; 
    }
    
    public static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.LastName = 'Testrec Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'testrec@test.test';
        testAccount.Customer_Journey_Stage__c = 'Take the Keys';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }
    
}