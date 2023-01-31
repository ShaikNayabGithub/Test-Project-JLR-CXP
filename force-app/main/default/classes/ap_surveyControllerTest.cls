@IsTest
public class ap_surveyControllerTest {
    @IsTest
    static void Test_getSUrveyDataOppId(){
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
            testAccount.LastName = 'Testrec Account Name';
            testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Corporate' AND SobjectType = 'Account' LIMIT 1];
            testAccount.PersonEmail = 'testrec@test.test';
            testAccount.Customer_Journey_Stage__c = 'Take Ownership';
            insert testAccount;
            
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
            AP_Survey__c objAP_Survey = new AP_Survey__c(Active__c = true,Survey_Type__c='Purchase');
            insert objAP_Survey;
            AP_Survey_Question__c objAP_Survey_Question = new AP_Survey_Question__c(AP_Survey__c = objAP_Survey.id,Survey_Form_Page_No__c='1');
            insert objAP_Survey_Question;
            ap_surveyController.getSUrveyData(opp.id);
            opp.AP_Purchase_Survey_Completed__c = true;
            update opp;
            ap_surveyController.getSUrveyData(opp.id);
        }
    }
    
    @IsTest
    static void Test_getSUrveyData_ServiceDataid(){
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
        
        Test.startTest();
        //Create ServiceData
        
        //1 with no errors:
        Service_Data__c serviceData1 = new Service_Data__c();
        serviceData1.Service_Repair_Date__c =system.today();
        serviceData1.Asset__c = vehicle.ID;
        serviceData1.DMS_Repair_Order_ID__c = '123xa';
        serviceData1.Mileage_Out__c = 24000;
        insert serviceData1;
        
        ap_surveyController.getSUrveyData(serviceData1.id);
        Test.stopTest();
    }
    
    @IsTest
    static void Test_saveSurveyResponses_oppId(){
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
            testAccount.LastName = 'Testrec Account Name';
            testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Corporate' AND SobjectType = 'Account' LIMIT 1];
            testAccount.PersonEmail = 'testrec@test.test';
            testAccount.Customer_Journey_Stage__c = 'Take Ownership';
            insert testAccount;
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
            Account ac2 = new Account(name ='Grazittitest2') ;
            insert ac2; 
            AP_Survey__c objAP_Survey = new AP_Survey__c(Active__c = true,Survey_Type__c='Purchase');
            insert objAP_Survey;
            test.startTest();
            List < ap_surveyController.responseWrapper >  listOfresponseWrapper = new List < ap_surveyController.responseWrapper >();
            listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,opp.id,'Star Rating','Making You Feel Welcome','1'));
            listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,opp.id,'Radio','Sales Consultant Recommendation','1'));
            listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,opp.id,'Star Rating','Test Drive Experience','1'));
            listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,opp.id,'Radio','Handover Experience','1'));
            listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,opp.id,'Star Rating','Understanding Needs','1'));
            listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,opp.id,'Radio','Fulfilment of Commitments','1'));
            string strResponses = JSON.serialize(listOfresponseWrapper);
            ap_surveyController.saveSurveyResponses(strResponses);
            
            test.stopTest();
        }
    }
    
    
    @IsTest
    static void Test_saveSurveyResponses_servicedataId(){
        Account ac = new Account(name ='Grazitti') ;
        ac.Country_ISO_Code__c = 'KH';
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,Email='tester@noemail.com');
        insert con;  
        
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        
        Account ac2 = new Account(name ='Grazittitest2') ;
        insert ac2; 
        AP_Survey__c objAP_Survey = new AP_Survey__c(Active__c = true,Survey_Type__c='Purchase');
        insert objAP_Survey;
        
        Asset vehicle3 = new Asset();
        vehicle3.Name = 'Test Car 3';
        vehicle3.AccountId = ac2.ID;
        vehicle3.Brand__c = vehicleSpec1.Id;
        Vehicle3.Mileage__c = 120000;
        insert vehicle3;
        Service_Data__c serviceData1 = new Service_Data__c();
        serviceData1.Service_Repair_Date__c =system.today();
        serviceData1.Asset__c = vehicle3.ID;
        serviceData1.DMS_Repair_Order_ID__c = '123xa';
        serviceData1.Mileage_Out__c = 24000;
        insert serviceData1;
        test.startTest();
        
        
        List < ap_surveyController.responseWrapper > listOfresponseWrapper = new List < ap_surveyController.responseWrapper >();
        listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,serviceData1.id,'Star Rating','How Quickly Vehicle was Seen','1'));
        listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,serviceData1.id,'Radio','Service Advisor Recommendation','1'));
        listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,serviceData1.id,'Star Rating','Post Work Explanation','1'));
        listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,serviceData1.id,'Radio','Vehicle Cleanliness and Condition','1'));
        listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,serviceData1.id,'Star Rating','Value for Money','1'));
        listOfresponseWrapper.add(createSurveyResponse(ac2.id,ac.id,objAP_Survey.id,serviceData1.id,'Radio','Fixed Right First Time','1'));
        string strResponses = JSON.serialize(listOfresponseWrapper);
        ap_surveyController.saveSurveyResponses(strResponses);
        test.stopTest();
        
    }
    
    private static ap_surveyController.responseWrapper createSurveyResponse(string customerId,string retailerId,string surveyId,string objectId,string answerType,string qTYpe,string scoreRating){
        ap_surveyController.responseWrapper objresponseWrapper= new ap_surveyController.responseWrapper();
        objresponseWrapper.customerId = customerId;
        objresponseWrapper.retailerId = retailerId;
        objresponseWrapper.surveyId = surveyId;
        objresponseWrapper.objectId = objectId;
        objresponseWrapper.language ='English';
        objresponseWrapper.questionId= null;
        objresponseWrapper.selectedRadioAnswer='';
        objresponseWrapper.selectedTextAnswer='';
        objresponseWrapper.selectedStarAnswer='';
        objresponseWrapper.answerType=answerType;
        objresponseWrapper.qTYpe=qTYpe;
        objresponseWrapper.scoreRating=scoreRating;
        objresponseWrapper.scoreText='1';
        objresponseWrapper.isUnanswered=false;
        objresponseWrapper.npsRating=1;
       objresponseWrapper.medalliaValue='1,';
        return objresponseWrapper;
    }
}