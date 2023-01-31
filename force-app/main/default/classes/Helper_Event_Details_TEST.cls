@isTest
public class Helper_Event_Details_TEST {
    
    static testMethod void onRoadsideEventCreationTEST(){
        
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
        
        
        List<Event_Details__c> eventsToInsert = new List<Event_Details__c>();
        //Create Roadside Events
        
        //1 with no errors:
        Event_Details__c event1 = new Event_Details__c();
        event1.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event1.VIN__c = vehicle.ID;
        event1.Roadside_Event_ID__c = '123xa';
        event1.Current_Vehicle_Mileage__c = 879000;
        eventsToInsert.add(event1);
        
        //2 with no date:
        Event_Details__c event2 = new Event_Details__c();
        event2.VIN__c = vehicle.ID;
        event2.Roadside_Event_ID__c = '123xra';
        eventsToInsert.add(event2);
        
        //3 with no event ID:
        Event_Details__c event3 = new Event_Details__c();
        event3.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event3.VIN__c = vehicle.ID;
        eventsToInsert.add(event3);
        
        //4 insert 2 roadside events with the same ID and same asset
        Event_Details__c event4 = new Event_Details__c();
        event4.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event4.VIN__c = vehicle.ID;
        event4.Roadside_Event_ID__c = '123xatv';
        eventsToInsert.add(event4);
        
        Event_Details__c event5 = new Event_Details__c();
        event5.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event5.VIN__c = vehicle.ID;
        event5.Roadside_Event_ID__c = '123xatv';
        eventsToInsert.add(event5);
        
        //5 event with same Event ID but different vehicle
        Event_Details__c event6 = new Event_Details__c();
        event6.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event6.VIN__c = vehicle2.ID;
        event6.Roadside_Event_ID__c = '123xatv';
        eventsToInsert.add(event6);
        
        //6 event with no vehicle
        Event_Details__c event7 = new Event_Details__c();
        event7.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event7.Roadside_Event_ID__c = '123xatv';
        //eventsToInsert.add(event7);
        
        ////7  record with no errors: Asset mileage not affected
        Event_Details__c event8 = new Event_Details__c();
        event8.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event8.VIN__c = vehicle3.ID;
        event8.Roadside_Event_ID__c = '123xacxb';
        event8.Current_Vehicle_Mileage__c = 200;
        eventsToInsert.add(event8);
        
        
        Test.startTest();
        insert eventsToInsert;
        Test.stopTest();
        
        //No Errors
        Event_Details__c singleEvent1 = [Select ID,Account__c,Error__c,Error_Type__c from Event_Details__c where ID =: event1.Id];
        System.assertEquals(a.ID,singleEvent1.Account__c);
        System.assertEquals(false,singleEvent1.Error__c);//new assertion
        System.assertEquals(null,singleEvent1.Error_Type__c);//new assertion
        
        //Test if the asset Mileage has been changed
        Asset singleAsset = [Select ID,Mileage__c from Asset where ID =: Vehicle.ID];
        System.assertEquals(879000,singleAsset.Mileage__c);
        
        //No Date
        Event_Details__c singleEvent2 = [Select ID,Account__c,Error__c,Error_Type__c from Event_Details__c where ID =: event2.Id];
        System.assertEquals(true,singleEvent2.Error__c);
        System.assertEquals('No Roadside event date provided',singleEvent2.Error_Type__c);
        
        //Event ID missing
        Event_Details__c singleEvent3 = [Select ID,Account__c,Error__c,Error_Type__c from Event_Details__c where ID =: event3.Id];
        System.assertEquals(true,singleEvent3.Error__c);
        System.assertEquals('Missing Roadside Event Data',singleEvent3.Error_Type__c);
        
        //Event with same ID and vehicle
        Event_Details__c singleEvent4 = [Select ID,Account__c,Error__c,Error_Type__c from Event_Details__c where ID =: event5.Id];
        System.assertEquals(true,singleEvent4.Error__c);
        System.assertEquals('Roadside Event already exists on asset with previous date',singleEvent4.Error_Type__c);
        
        
        //Event mileage lower then vehicle mileage - > mileage intact
        Event_details__c singleEvent5 = [Select ID,Account__c,Error__c,Error_Type__c,VIN__c from Event_details__c where ID =: event8.Id];
        Asset singleAsset2 = [Select ID,Mileage__c from Asset where ID =: singleEvent5.VIN__c];
        System.assertEquals(Vehicle3.Mileage__c,singleAsset2.Mileage__c);//new assertion
        System.assertEquals(false,singleEvent5.Error__c);//new assertion
        System.assertEquals(null,singleEvent5.Error_Type__c);//new assertion
        
      
    }
	
}