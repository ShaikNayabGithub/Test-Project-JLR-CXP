@IsTest
public class APSurveyUtilitytest {
    @IsTest
    static void Test_updateLastRepairDateCheckBox(){
        //Create a Brand
        Vehicle_Specification__c  vs = new Vehicle_Specification__c ();
        vs.Name = 'Land Rover';
        insert vs;
        
        //Create an Account
        Account a = new Account();
        a.firstName = 'Test';
        a.LastName = 'Lastname';
        a.PersonEmail = 'test@test.com';
        a.Select_Country_ISO_Code__c = 'SG';
        insert a;
        
        List<Asset> vehicleList = new List<Asset>();
        
        //Create the Asset
        Asset vehicle = new Asset();
        vehicle.Name = 'Test Car';
        vehicle.AccountId = a.ID;
        vehicle.Brand__c = vs.Id;
        Vehicle.Mileage__c = 200;
        vehicleList.add(vehicle);
        //insert vehicle;
        
        //Create the second Asset
        Asset vehicle2 = new Asset();
        vehicle2.Name = 'Test Car 2';
        vehicle2.AccountId = a.ID;
        vehicle2.Brand__c = vs.Id;
        Vehicle2.Mileage__c = 200000;
        vehicleList.add(vehicle2);
        //insert vehicle2;
        
        //Create the third Asset
        Asset vehicle3 = new Asset();
        vehicle3.Name = 'Test Car 3';
        vehicle3.AccountId = a.ID;
        vehicle3.Brand__c = vs.Id;
        Vehicle3.Mileage__c = 120000;
        vehicleList.add(vehicle3);
        //insert vehicle3;
        
        insert vehicleList;
        
        
        Test.startTest();
        //Create ServiceData
        
        //1 with no errors:
        Service_Data__c serviceData1 = new Service_Data__c();
        serviceData1.Service_Repair_Date__c =system.today();
        serviceData1.Asset__c = vehicle.ID;
        serviceData1.DMS_Repair_Order_ID__c = '123xa';
        serviceData1.Mileage_Out__c = 24000;
        serviceData1.Account__c = a.Id;
        insert serviceData1;
        
        //2 with added Service_Repair_Date__c less then 45 days
        Service_Data__c serviceData2 = new Service_Data__c();
        serviceData2.Asset__c = vehicle.ID;
        serviceData2.DMS_Repair_Order_ID__c = '123xra';
        serviceData2.Service_Repair_Date__c =system.today().Adddays(1);
        serviceData2.Account__c = a.Id;
        insert serviceData2;
        
        //2 with added Service_Repair_Date__c greater then 45 days
        Service_Data__c serviceData3 = new Service_Data__c();
        serviceData3.Service_Repair_Date__c= system.today().addDays(50);
        serviceData3.Asset__c = vehicle.ID;
        serviceData3.Account__c = a.Id;
        insert serviceData3;
        
        
        Test.stopTest();
    }
    
    @IsTest
    static void Test_createSurveyResponseShareRecords(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Id p = [select id from profile where name='Partner Community User'].id;
            Account ac = new Account(name ='Grazitti') ;
            insert ac; 
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,Email='tester@noemail.com');
            insert con;  
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = con.Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com' + System.now().millisecond());
            
            insert user;
            Account ac2 = new Account(name ='Grazittitest2') ;
            ac2.Select_Country_ISO_Code__c = 'SG';
            insert ac2; 
            AP_Survey__c objAP_Survey = new AP_Survey__c(Active__c = true,Survey_Type__c='Purchase');
            insert objAP_Survey;
            AP_Survey_Response__c objectSurvey_Response = new  AP_Survey_Response__c();
            objectSurvey_Response.Customer__c = ac2.id;
            objectSurvey_Response.Survey__c = objAP_Survey.id;
            objectSurvey_Response.Retailer__c = ac.id;
            insert objectSurvey_Response;
        }
    }
    
    @IsTest
    static void Test_PopulateAPSurveyContact(){
        System.runAs (new User(Id = UserInfo.getUserId())) {
            Id p = [select id from profile where name='Partner Community User'].id;
            Account ac = new Account(name ='Grazitti') ;
            ac.Country_ISO_Code__c = 'KH';
            insert ac;
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,Email='tester@noemail.com');
            insert con;  
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                 ContactId = con.Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com' + System.now().millisecond());
            
            insert user;
            
            Account testAccount = new Account();
            testAccount.Name = 'Testrec Account Name';
            testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Corporate' AND SobjectType = 'Account' LIMIT 1];
            //testAccount.PersonEmail = 'testrec@test.test';
            testAccount.Customer_Journey_Stage__c = 'Take the Keys';
            insert testAccount;
            Contact testcontact = new Contact(LastName ='testCon1',AccountId = testAccount.Id,Email='tester1@noemail.com');
            insert testcontact;
            
            Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
            vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
            vehicleSpec1.Name = 'Jaguar';
            insert vehicleSpec1;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'test';
            opp.StageName = 'Handover';
            opp.Brand__c = vehicleSpec1.Id;
            opp.AccountId = testAccount.Id;
            opp.CloseDate = Date.parse('12/12/2016');
            opp.OwnerId=user.id;
            insert opp;
            
            
        }
        
    }
}