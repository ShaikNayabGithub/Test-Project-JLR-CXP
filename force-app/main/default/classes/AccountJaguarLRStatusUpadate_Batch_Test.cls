@isTest
public class AccountJaguarLRStatusUpadate_Batch_Test {
    
    @testsetup static void testSetupData(){
        account acc=new account();
        acc.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        acc.firstname='individual';
        acc.lastname='dfsdf';
        acc.personemail='invidivudal@fafds.com';
        acc.phone='0074343430';
        acc.Owner_Retailer__c = 'Test';
        acc.Region_or_Market__c = 'IN';
        insert acc; 
    }
    @isTest static void testOppInsertDataJaguar(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        
        
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
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest();
        
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,'Prospect');
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,null);
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
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest();
        
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,null);
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,'Prospect');
    }
    
    @isTest static void testRoleInsertDataJaguar(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = AccountJagANDLRStatusHandler_Test.BuildVehicle('Jaguar');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        insert role;
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest();
        
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,'Customer');
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,null);
    }
    
    @isTest static void testRoleInsertDataJaguarMultiple(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = AccountJagANDLRStatusHandler_Test.BuildVehicle('Jaguar');
        List<Role__c> roleList = new List<Role__c>();
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
        role.Role__c = 'Current Owner';
        roleList.add(role);
        
        insert roleList;
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest();
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,'Repeat Customer');
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,null);
    }
    
    
    @isTest static void testRoleInsertDataLandRoverMultiple(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = AccountJagANDLRStatusHandler_Test.BuildVehicle('Land Rover');
        List<Role__c> roleList = new List<Role__c>();
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
        role.Role__c = 'Current Owner';
        roleList.add(role);
        
        insert roleList;
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest();
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,null);
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,'Repeat Customer');
    }
    
    @isTest static void testRoleInsertDataLandRover(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        Asset vehicle = AccountJagANDLRStatusHandler_Test.BuildVehicle('Land Rover');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        insert role;
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest();
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,null);
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,'Customer');
    }
    
    @isTest static void testOppInsertDataJaguarWithRole(){
        Account retailer = [select id,RecordTypeId from Account where firstname = 'individual'];
        
        
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
        Asset vehicle = AccountJagANDLRStatusHandler_Test.BuildVehicle('Jaguar');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        insert role;
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest();
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,'Customer');
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,null);
    }
    
    
    @isTest static void testOppInsertDataLandRoverWithRole(){
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
        Asset vehicle = AccountJagANDLRStatusHandler_Test.BuildVehicle('Land Rover');
        Role__c role = new Role__c();
        role.Account__c = retailer.Id;
        role.recordtypeid = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        role.Vehicle__c = vehicle.Id;
        role.Role__c = 'Current Owner';
        insert role;
        
        retailer.RecordTypeId =  AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.ntt_Jaguar_Status__c = null;
        retailer.ntt_Land_Rover_Status__c = null;
        update retailer;
        
        
        Test.startTest();
        AccountJaguarLRStatusUpadate_Batch jlrBatchIns = new AccountJaguarLRStatusUpadate_Batch('IN');
        database.executeBatch(jlrBatchIns,1);
        Test.stopTest(); 
        Account retailerVal = [select id,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c from Account where id =: retailer.Id];
        system.assertEquals(retailerVal.ntt_Jaguar_Status__c,null);
        system.assertEquals(retailerVal.ntt_Land_Rover_Status__c,'Customer');
    }
}