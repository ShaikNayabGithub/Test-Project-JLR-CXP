@isTest
public class CXPInboundOpps_Test {
    @testSetup
    static void testsetupmethod(){
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Qualified';
        Account testAccount = new Account();
        testAccount.LastName = 'Testrec Account Name';
        //testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'testrec@test.test';
        testAccount.Customer_Journey_Stage__c = 'Take Ownership';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        opp.MENA_DMS_ID__c = 'PROS200600354';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        
        /*Opportunity opp1 = new Opportunity();
        opp1.Name = 'test1';
        opp1.StageName = 'Qualified';
        Account testAccount1 = new Account();
        testAccount1.name = 'Testrec Account Name1';
        testAccount1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Retailer' AND SobjectType = 'Account' LIMIT 1];
        insert testAccount1;
        Contact con =  new Contact(firstname = 'abc', lastname = 'def', accountId = testAccount1.id, email = 'abc@def.com');
        insert con;
        opp1.AccountId = testAccount1.Id;
        Vehicle_Specification__c vehicleSpec11 = new Vehicle_Specification__c();
        vehicleSpec11.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec11.Name = 'Jaguar';
        opp1.MENA_DMS_ID__c = '1ae96989-3993-4b7e-b8cf-41cb9eb3dfeo';
        insert vehicleSpec11;
        opp1.Brand__c = vehicleSpec1.Id;
        opp1.CloseDate = Date.parse('12/12/2016');
        opp1.contactId = con.id;
        insert opp1;*/
    }
    
    @isTest
    static void testMethod11() {
        string JsonMsg = '[{"CXP ID":"","JobRouter ID":"PROS200600354","User":"conseiller soutra","Update Date":"17/06/21","First Name":"YOUSSEF","Last name":"AIT EL KADI","Mobile":672360529,"Phone":"","Email":"NO@GMAIL.COM","Brand":"Land Rover","Primary Model Interest":"Range Rover Evoque","Description":"2.0 180 PS","Budget":"400000-500000","Test Drive Date":"","Stage":"Bon de commande","Trade In":"","Trade in Value":"","Sales Price":"","Local Deposit Amount":"","Offer Applied":"","VAT %":"","VIN":"","Handover Date":"","Date Lost":"","Loss Category":"","Loss Reason":"","Loss Notes":"","Retarget Date":"","Copie de Loss Category":"","Copie de Loss Reason":""}]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Opportunities/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundOpps.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod12() {
        string JsonMsg = '[{"CXP ID":"","JobRouter ID":"PROS200600354","User":"conseiller soutra","Update Date":"17/06/21","First Name":"YOUSSEF","Last name":"AIT EL KADI","Mobile":672360529,"Phone":"","Email":"NO@GMAIL.COM","Brand":"Land Rover","Primary Model Interest":"Range Rover Evoque","Description":"2.0 180 PS","Budget":"400000-500000","Test Drive Date":"30/09/2021","Stage":"Test Drive","Trade In":"","Trade in Value":"3456","Sales Price":"87530","Local Deposit Amount":"400","Offer Applied":"456","VAT %":"7","VIN":"","Handover Date":"","Date Lost":"","Loss Category":"","Loss Reason":"","Loss Notes":"","Retarget Date":"","Copie de Loss Category":"","Copie de Loss Reason":""}]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Opportunities/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundOpps.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod16() {
        string JsonMsg = '[{"CXP ID":"","JobRouter ID":"PROS200600354","User":"conseiller soutra","Update Date":"17/06/21","First Name":"YOUSSEF","Last name":"AIT EL KADI","Mobile":672360529,"Phone":"","Email":"NO@GMAIL.COM","Brand":"Land Rover","Primary Model Interest":"Range Rover Evoque","Description":"2.0 180 PS","Budget":"400000-500000","Test Drive Date":"30/09/2021","Stage":"Offre commerciale","Trade In":"","Trade in Value":"3456","Sales Price":"87530","Local Deposit Amount":"400","Offer Applied":"456","VAT %":"","VIN":"","Handover Date":"","Date Lost":"","Loss Category":"","Loss Reason":"","Loss Notes":"","Retarget Date":"","Copie de Loss Category":"","Copie de Loss Reason":""}]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Opportunities/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundOpps.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod19() {
        string JsonMsg = '[{"CXP ID":"","JobRouter ID":"PROS220300133","User":"Hanae Idrissi Kaitouni","Update Date":"28/09/2021","First Name":"SOUAD","Last Name":"LAHMIDI","Mobile":"654261813","Phone":"654261813","Email":"souad.lahm1@gmail.com","Brand":"Land Rover","Primary Model Interest":"Range Rover Evoque","Description":"2.0L TD4 180Ch","Budget":"600000","Test Drive Date":"","Stage":"Perdue","Trade In":"","Trade in Value":"","Sales Price":"","Local Deposit Amount":"","Offer Applied":"","VAT %":"","VIN":"","Handover Date":"","Date Lost":"29/09/2021","Loss Category":"Autres","Loss Reason":"Autres","Loss Notes":"Autres","Retarget Date":""}]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Opportunities/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundOpps.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod122() {
        string JsonMsg = '[{"CXP ID":"","JobRouter ID":"PROS220300133","User":"Hanae Idrissi Kaitouni","Update Date":"28/09/2021","First Name":"SOUAD","Last Name":"LAHMIDI","Mobile":"654261813","Phone":"654261813","Email":"souad.lahm1@gmail.com","Brand":"Land Rover","Primary Model Interest":"Range Rover Evoque","Description":"2.0L TD4 180Ch","Budget":"600000","Test Drive Date":"","Stage":"Facturée","Trade In":"","Trade in Value":"","Sales Price":"","Local Deposit Amount":"","Offer Applied":"","VAT %":"","VIN":"","Handover Date":"","Date Lost":"29/09/2021","Loss Category":"Autres","Loss Reason":"Autres","Loss Notes":"Autres","Retarget Date":""}]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Opportunities/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundOpps.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod22() {
        string JsonMsg = '[{"CXP ID":"","JobRouter ID":"PROS220300133","User":"Hanae Idrissi Kaitouni","Update Date":"28/09/2021","First Name":"SOUAD","Last Name":"LAHMIDI","Mobile":"654261813","Phone":"654261813","Email":"souad.lahm1@gmail.com","Brand":"Land Rover","Primary Model Interest":"Range Rover Evoque","Description":"2.0L TD4 180Ch","Budget":"600000","Test Drive Date":"","Stage":"Nouveau","Trade In":"","Trade in Value":"","Sales Price":"","Local Deposit Amount":"","Offer Applied":"","VAT %":"","VIN":"","Handover Date":"","Date Lost":"29/09/2021","Loss Category":"Autres","Loss Reason":"Autres","Loss Notes":"Autres","Retarget Date":""}]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Opportunities/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundOpps.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod13() {
        string JsonMsg = '[{"CXP ID":"","JobRouter ID":"PROS220311224","User":"Hanae Idrissi Kaitouni","Update Date":"29/09/2021","First Name":"Michael","Last Name":"Mouse","Mobile":"181265427","Phone":"181265427","Email":"Michael.Mouse1@gmail.com","Brand":"Land Rover","Primary Model Interest":"Range Rover","Description":"2.0L TD4 180Ch","Budget":"850000","Test Drive Date":"30/09/2021","Stage":"Test Drive","Trade In":"","Trade in Value":"","Sales Price":"","Local Deposit Amount":"","Offer Applied":"","VAT %":"","VIN":"","Handover Date":"","Date Lost":"","Loss Category":"","Loss Reason":"","Loss Notes":"","Retarget Date":""}]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Opportunities/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundOpps.create();
        Test.stopTest();
    }

}