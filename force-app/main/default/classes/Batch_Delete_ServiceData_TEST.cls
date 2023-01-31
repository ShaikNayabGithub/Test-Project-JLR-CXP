@isTest
public class Batch_Delete_ServiceData_TEST {

    @isTest
    static void Test_Execute_Batch_Delete_ServiceData(){
        
        //Set Containing the created Data IDs
        Set<ID> createdServiceDataIDs = new Set<ID>();
        
        //Set Containing the created Data IDs with modifiedDate = today() - 30
        Set<ID> createdServiceDataMinus30IDs = new Set<ID>();
        
        //Create a Brand
        Vehicle_Specification__c  vs = new Vehicle_Specification__c ();
        vs.Name = 'Land Rover';
        insert vs;
        
        //Create an Account
        Account a = new Account();
        a.firstName = 'Test';
        a.LastName = 'Lastname';
        a.PersonEmail = 'test@test.com';
        insert a;
        
        //Create the Asset
        Asset vehicle = new Asset();
        vehicle.Name = 'Test Car';
        vehicle.AccountId = a.ID;
        vehicle.Brand__c = vs.Id;
        Vehicle.Mileage__c = 200;
        insert vehicle;
        
        //List for the records to add that have modifiedDate < today - 30 days
        List<Service_Data__c> listServiceDataMinus30 = new List<Service_Data__c>();
        
        //List for the records to add with normal created date
        List<Service_Data__c> listServiceData = new List<Service_Data__c>();
        
        Service_Data__c sd;
        
        for(Integer i = 0;i<50;i++)
        {
            sd = new Service_Data__c();
            sd.Service_Repair_Date__c  = Date.newInstance(2019, 03, 03);
            sd.Asset__c = vehicle.ID;
            sd.DMS_Repair_Order_ID__c = '123xa'+i;
            sd.Mileage_Out__c  = 879000;
            sd.Error__c = true;
            listServiceData.add(sd);
        }      
        
        insert listServiceData;
        
        for(Integer i = 0;i<50;i++)
        {
            sd = new Service_Data__c();
            sd.Service_Repair_Date__c  = Date.newInstance(2019, 03, 03);
            sd.Asset__c = vehicle.ID;
            sd.DMS_Repair_Order_ID__c = '123xa'+i;
            sd.Mileage_Out__c  = 879000;
            sd.CreatedDate = Date.newInstance(2019, 03, 03);
            sd.LastModifiedDate = Date.newInstance(2019, 03, 03);
            sd.Error__c = true;
            listServiceDataMinus30.add(sd);
        }      
        
        insert listServiceDataMinus30;
        
        
        
        //Inserting the IDs of the created records with Today's date (modifiedDate) in the Set
        for(Service_Data__c s : listServiceData){
            
            createdServiceDataIds.add(s.ID);
        }
        
        //Inserting the IDs of the created records with modifiedDate = Today() - 30 days in the Set
        for(Service_Data__c s : listServiceDataMinus30){
            
            createdServiceDataMinus30IDs.add(s.ID);
        }
        
        
        test.startTest();
        Batch_Delete_ServiceData b = new Batch_Delete_ServiceData();
        Database.executeBatch(b);
        test.stopTest();
        
        listServiceDataMinus30.clear();
        listServiceData.clear();
        
        //get the created records where IDs in the Set
        listServiceDataMinus30 = [Select ID from Service_Data__c where ID in : createdServiceDataMinus30IDs];
        
        //size of new list must be 0 to verify that all records with modified date < Today() - 30 in the list were deleted
        System.assertEquals(0,listServiceDataMinus30.size());
        
        
        //get the created records where IDs in the Set
        listServiceData = [Select ID from Service_Data__c where ID in : createdServiceDataIDs];
        
        //size of new list must be intact to verify that all records with today's date were not deleted
        System.assertEquals(createdServiceDataIDs.size(),listServiceData.size());
    }
   

}