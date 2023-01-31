@isTest
public class Batch_Delete_EventDetails_TEST {

    @isTest
    static void Test_Execute_Batch_Delete_RoadsideEvent(){
        
        //Set Containing the created Data IDs
        Set<ID> createdEventDetailsIDs = new Set<ID>();
        
        //Set Containing the created Data IDs with modifiedDate = today() - 30
        Set<ID> createdEventDetailsMinus30IDs = new Set<ID>();
        
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
        
        //List for the events to add that have modifiedDate < today - 30 days
        List<Event_Details__c> listEventDetailsMinus30 = new List<Event_Details__c>();
        
        //List for the events to add with normal created date
        List<Event_Details__c> listEventDetails = new List<Event_Details__c>();
        
        Event_Details__c event1;
        Event_Details__c event2;
        
        for(Integer i = 0;i<50;i++)
        {
            event1 = new Event_Details__c();
            event1.Event_DateTime__c = Date.newInstance(2019, 03, 03);
            event1.VIN__c = vehicle.ID;
            event1.Roadside_Event_ID__c = '123xa'+i;
            event1.Current_Vehicle_Mileage__c = 879000;
            event1.CreatedDate = Date.newInstance(2019, 03, 03);
            event1.LastModifiedDate = Date.newInstance(2019, 03, 03);
            event1.Error__c = true;
            listEventDetailsMinus30.add(event1);
        }      
        
        insert listEventDetailsMinus30;
        
        for(Integer i = 0;i<50;i++)
        {
            event2 = new Event_Details__c();
            event2.Event_DateTime__c = Date.newInstance(2019, 03, 03);
            event2.VIN__c = vehicle.ID;
            event2.Roadside_Event_ID__c = '123xbna'+i;
            event2.Current_Vehicle_Mileage__c = 879000;
            event2.Error__c = true;
            listEventDetails.add(event2);
        }      
        
        insert listEventDetails;
        
        //Inserting the IDs of the created records with Today's date (modifiedDate) in the Set
        for(Event_Details__c e : listEventDetails){
            
            createdEventDetailsIDs.add(e.ID);
        }
        
        //Inserting the IDs of the created records with modifiedDate = Today() - 30 days in the Set
        for(Event_Details__c e : listEventDetailsMinus30){
            
            createdEventDetailsMinus30IDs.add(e.ID);
        }
        
        test.startTest();
        Batch_Delete_EventDetails b = new Batch_Delete_EventDetails();
        Database.executeBatch(b);
        test.stopTest();
        
        
        
        listEventDetailsMinus30.clear();
        listEventDetails.clear();
        
        //get the created records where IDs in the Set
        listEventDetailsMinus30 = [Select ID from Event_Details__c where ID in : createdEventDetailsMinus30IDs];
        
        //size of new list must be 0 to verify that all records with modified date < Today() - 30 in the list were deleted
        System.assertEquals(0,listEventDetailsMinus30.size());
        
        
        //get the created records where IDs in the Set
        listEventDetails = [Select ID from Event_Details__c where ID in : createdEventDetailsIDs];
        
        //size of new list must be intact to verify that all records with today's date were not deleted
        System.assertEquals(createdEventDetailsIDs.size(),listEventDetails.size());
    }
   

}