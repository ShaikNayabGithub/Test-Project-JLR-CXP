@IsTest (SeeAllData=false)
public class EventDetailsBatchExport_TEST {

    @TestSetup
    static void initialize() {
        
        //List of event details to add:
        List<Event_Details__c> eventsToAdd = new List<Event_Details__c>();
        
        //Create a Brand
        Vehicle_Specification__c  vs = new Vehicle_Specification__c ();
        vs.Name = 'Land Rover';
        insert vs;
        
        //Create an Account
        Account a = new Account();
        a.FirstName = 'Test';
        a.LastName = 'Lastname';
        a.PersonEmail = 'test@test.com';
        insert a;
        
        //Create the Asset
        Asset vehicle = new Asset();
        vehicle.Name = 'Test Car';
        vehicle.AccountId = a.Id;
        vehicle.Brand__c = vs.Id;
        vehicle.Mileage__c = 200;
        vehicle.Handover_Date__c = Date.newInstance(2019, 03, 03);
        vehicle.Last_Registration_Date__c = Date.newInstance(2019, 03, 03);
        vehicle.Delivered_Date__c = Date.newInstance(2019, 03, 03);
        vehicle.Dealer_Code__c = '1az3';
        vehicle.Model_Year__c = '2013';
        insert vehicle;
        
        //Insert the Event Detail record that would be copied - created date > today - 7
        Event_Details__c event1 = new Event_Details__c();
        event1.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event1.CreatedDate = Date.today();
        event1.VIN__c = vehicle.Id;
        event1.Roadside_Event_ID__c = '123xa';
        event1.Current_Vehicle_Mileage__c = 879000;
        
        event1.Brand__c = 'Jaguar';
        event1.Incident_Country_Code__c = 'LB';
        event1.Event_Type__c = 'Roadside';
        event1.Title__c = 'Eng';
        event1.First_Name__c ='Test';
        event1.Last_Name__c = 'Test';
        event1.Country__c = 'Lebanon';
        event1.Phone__c = '009611123123';
        event1.Model__c = 'LX';
        event1.Licence_Plate__c = 'G123123';
        event1.Email__c ='test@email.com';
        event1.Language_Code__c = 'EN';
        event1.Survey_Suppression_Flag__c = true;
        event1.Consumer_Reference__c = 'Total Care';
        eventsToAdd.add(event1);
        
        
        //Insert the Event Detail record that would NOT be copied - created date = today - 7
        Event_Details__c event2 = new Event_Details__c();
        event2.Event_DateTime__c = Date.newInstance(2019, 03, 03);
        event2.CreatedDate = Date.today() - 7;
        event2.VIN__c = vehicle.Id;
        event2.Roadside_Event_ID__c = '123xa456';
        event2.Current_Vehicle_Mileage__c = 879000;
        
        event2.Brand__c = 'Jaguar';
        event2.Incident_Country_Code__c = 'LB';
        event2.Event_Type__c = 'Roadside';
        event2.Title__c = 'Eng';
        event2.First_Name__c ='Test';
        event2.Last_Name__c = 'Test';
        event2.Country__c = 'Lebanon';
        event2.Phone__c = '009611123123';
        event2.Model__c = 'LX';
        event2.Licence_Plate__c = 'G123123';
        event2.Email__c ='test@email.com';
        event2.Language_Code__c = 'EN';
        event2.Survey_Suppression_Flag__c = true;
        event2.Consumer_Reference__c = 'Total Care';
        eventsToAdd.add(event2);
        
        insert eventsToAdd;
    }
    
    @IsTest
    static void Test_Copy_EventDetails_to_GFKRoadside(){
        
        //get the event that should be copied
        Event_Details__c Event1 = [SELECT Brand__c,Incident_Country_Code__c,Event_Type__c,Event_DateTime__c,
                                  Title__c,First_Name__c,Last_Name__c,Country__c,Phone__c,Model__c,Licence_Plate__c,Email__c,
                                  Language_Code__c,Survey_Suppression_Flag__c,Roadside_Event_ID__c,Source__c,
                                  VIN__r.Last_Registration_Date__c,VIN__r.Handover_Date__c,VIN__r.Delivered_Date__c,
                                  VIN__r.Dealer_Code__c,VIN__r.AccountId,VIN__r.Model_Year__c,VIN__r.Name, Consumer_Reference__c
                                  FROM Event_Details__c WHERE Roadside_Event_ID__c ='123xa'];
        
        System.assertNotEquals(null,Event1.Id);
        Asset vehicle = Event1.VIN__r;
        
        //Database.executeBatch(new EventDetailsBatchExport());
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 0 0 3 9 ? 2022';//'0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        
        Test.startTest();
        
        EventDetailsBatchExport b = new EventDetailsBatchExport();
        String jobId = System.schedule('TestSchedule', CRON_EXP,b);
        b.execute(null);
        
        // Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
        					NextFireTime
        					FROM CronTrigger WHERE Id = :jobId];

      	// Verify the expressions are the same
      	System.assertEquals(CRON_EXP,ct.CronExpression);

      	// Verify the job has not run
      	System.assertEquals(0, ct.TimesTriggered);

      	// Verify the next time the job will run
      	System.assertEquals('2022-09-03 00:00:00',String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
   
        //see if the event1 is the only record copied by checking the Breakdown_Case__Id by checking the roadside ID 
        //check all the fields if they are mapped correctly
        List<GFK_Roadside_Event_Export__c> gfkRoadsideList = [SELECT Id,Manufacturer__c,Country_Code__c,Event_Type__c,
                                          Vehicle_Purchase_Date__c,Vehicle_Registration_Date__c,Vehicle_Delivery_Date__c,
										  Service_Event_Date__c,Dealer_Code__c,Customer_Unique_Id__c,
                                          Title__c,Firstname__c,Surname_Field_1__c,Address_8_Country__c,Mobile_Telephone_Number__c,
                                          Model_Name__c,Model_Year__c,VIN__c,Registration_Number__c,Email_Address_1__c,
                                          Preferred_Language__c,Complete_Suppression__c,Breakdown_Date__c,
                                          Breakdown_Country__c,Breakdown_Case_Id__c,Data_Source__c FROM GFK_Roadside_Event_Export__c];
        
        //check if the list has only 1 record
        System.assertEquals(1, gfkRoadsideList.size());
        
        GFK_Roadside_Event_Export__c e = gfkRoadsideList[0];
        string dateis =  '03/03/2019';
        System.assertEquals(Event1.Brand__c, e.Manufacturer__c);
        System.assertEquals(Event1.Incident_Country_Code__c, e.Country_Code__c);
        System.assertEquals('4', e.Event_Type__c);
        System.assertEquals(dateis, e.Vehicle_Purchase_Date__c);
        System.assertEquals(dateis, e.Vehicle_Registration_Date__c);
        System.assertEquals(dateis, e.Vehicle_Delivery_Date__c);
        //System.assertEquals(String.valueOf(dateis), e.Service_Event_Date__c);
        System.assertEquals(vehicle.Dealer_Code__c, e.Dealer_Code__c);
        System.assertEquals(vehicle.AccountId, e.Customer_Unique_Id__c);
        System.assertEquals(Event1.Title__c, e.Title__c);
        System.assertEquals(Event1.First_Name__c, e.Firstname__c);
        System.assertEquals(Event1.Last_Name__c, e.Surname_Field_1__c);
        System.assertEquals(Event1.Country__c, e.Address_8_Country__c);
        System.assertEquals(Event1.Phone__c, e.Mobile_Telephone_Number__c);
        System.assertEquals(Event1.Model__c, e.Model_Name__c);
        System.assertEquals(vehicle.Model_Year__c, e.Model_Year__c);
        System.assertEquals(vehicle.Name, e.VIN__c);
        System.assertEquals(Event1.Licence_Plate__c, e.Registration_Number__c);
        System.assertEquals(Event1.Email__c, e.Email_Address_1__c);
        System.assertEquals(Event1.Language_Code__c, e.Preferred_Language__c);
        //System.assertEquals(String.valueOf(Event1.Survey_Suppression_Flag__c), e.Complete_Suppression__c);
        //System.assertEquals(dateis, e.Breakdown_Date__c);
        System.assertEquals(Event1.Incident_Country_Code__c, e.Breakdown_Country__c);
        System.assertEquals(Event1.Roadside_Event_ID__c, e.Breakdown_Case_Id__c);
        System.assertEquals(Event1.Consumer_Reference__c, e.Data_Source__c);
        
        //check if the list if there is 1 asyncjob
        List<AsyncApexJob> listScheduledApexJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, JobType, MethodName
												FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
        
        List<AsyncApexJob> listBatchApexJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, JobType, MethodName
												FROM AsyncApexJob WHERE JobType = 'BatchApex'];
       
 		//verify that there is 1 scheduled job
 		System.assertEquals(1,listScheduledApexJob.size());
 		System.assertEquals('Queued',listScheduledApexJob[0].Status);
 		
        //verify that there is 1 apex job
 		System.assertEquals(2,listBatchApexJob.size());
        System.assertEquals('Completed',listBatchApexJob[0].Status);
        
    }
}