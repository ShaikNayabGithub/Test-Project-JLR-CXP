@isTest
public class CXPInboundProspects_Test {
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
        opp.MENA_DMS_ID__c = '1ae96989-3993-4b7e-b8cf-41cb9eb3dfeb';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        
        Opportunity opp1 = new Opportunity();
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
        insert opp1;
    }
    
    @isTest
    static void testMethod1() {
        string JsonMsg = '[ { "Lead Hub ID": "1ae96989-3993-4b7e-b8cf-41cb9eb3dfeb", "Customer unique Number": 141180, "Salutation": "Fahad Alostad", "First Name": "Fahad", "Surname": "Alostad", "Company Name": "", "Gender": "Male", "Language": "en", "Employment Status": "", "Industry": "", "Occupation": "", "Lead Source": "", "Mobile": 66233515, "Phone": "", "Home Phone": "", "Email": "alostath@hotmail.com", "Email 2": "", "Address 1": ".", "Address 2": "", "Address 3": "", "Address 4": "", "Address 5": "", "Enquiry Source": "", "Nationality Code": "", "Account Owner": "Ziad Obeid", "Last Edit Date": "23/06/21", "Lead Owner": "Ahmad Abu Hawili", "Brand": "JAGUAR", "Model": "XJ", "Demo": "--/--/----", "Quote": "23/06/21", "Order": "--/--/----", "Lost": "--/--/----", "Event Type": "", "Lost Sale Ref": "", "Type (NEW/USED)": "UNQ", "Vehicle Identification Number": "SAJAA20N5GPV94032", "Price": "9490", "VAT": "0", "Delivery Date": "--/--/----", "Invoice Date": "--/--/----", "Registration Date": "--/--/----" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Prospects/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundProspects.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod11() {
        string JsonMsg = '[ { "Lead Hub ID": "1ae96989-3993-4b7e-b8cf-41cb9eb3dfeo", "Customer unique Number": 141180, "Salutation": "Fahad Alostad", "First Name": "Fahad", "Surname": "Alostad", "Company Name": "", "Gender": "Male", "Language": "en", "Employment Status": "", "Industry": "", "Occupation": "", "Lead Source": "", "Mobile": 66233515, "Phone": "", "Home Phone": "", "Email": "alostath@hotmail.com", "Email 2": "", "Address 1": ".", "Address 2": "", "Address 3": "", "Address 4": "", "Address 5": "", "Enquiry Source": "", "Nationality Code": "", "Account Owner": "Ziad Obeid", "Last Edit Date": "23/06/21", "Lead Owner": "Ahmad Abu Hawili", "Brand": "JAGUAR", "Model": "XJ", "Demo": "23/06/21", "Quote": "--/--/----", "Order": "--/--/----", "Lost": "--/--/----", "Event Type": "", "Lost Sale Ref": "", "Type (NEW/USED)": "UNQ", "Vehicle Identification Number": "SAJAA20N5GPV94032", "Price": "9490", "VAT": "0", "Delivery Date": "--/--/----", "Invoice Date": "--/--/----", "Registration Date": "--/--/----" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Prospects/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundProspects.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() {
        string JsonMsg = '[ { "Lead Hub ID": "0bdc823f-434b-432c-bbd2-80392c1b3be6", "Customer unique Number": 143761, "Salutation": "Kuwait House", "First Name": "Kuwait", "Surname": "House", "Company Name": "Kuwait Finance House", "Gender": "Female", "Language": "en", "Employment Status": "", "Industry": "", "Occupation": "", "Lead Source": "Jaguar_Approved_Campaign_June21_IG", "Mobile": 60998545, "Phone": "", "Home Phone": "", "Email": "s.aalshatti@hotmail.com", "Email 2": "", "Address 1": "Qurtabah , Block 2 Street 1", "Address 2": "RASHA ABDULLAH SULAIMAN ALMATAR", "Address 3": "", "Address 4": "", "Address 5": "", "Enquiry Source": "", "Nationality Code": "", "Account Owner": "Jordan Walker", "Last Edit Date": "23/06/21", "Lead Owner": "Mohamed Kamal Naba", "Brand": "JAGUAR", "Model": "F-Type", "Demo": "23/06/21", "Quote": "--/--/----", "Order": "--/--/----", "Lost": "--/--/----", "Event Type": "", "Lost Sale Ref": "", "Type (NEW/USED)": "NEW", "Vehicle Identification Number": "SAJDB1BXXMCK74999", "Price": "17850", "VAT": "0", "Delivery Date": "27/06/21", "Invoice Date": "--/--/----", "Registration Date": "--/--/----" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Prospects/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundProspects.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3() {
        string JsonMsg = '[ { "Lead Hub ID": "0bdc823f-434b-432c-bbd2-80392c1b3be6", "Customer unique Number": 143761, "Salutation": "Kuwait House", "First Name": "Kuwait", "Surname": "House", "Company Name": "Kuwait Finance House", "Gender": "Female", "Language": "en", "Employment Status": "", "Industry": "", "Occupation": "", "Lead Source": "Jaguar_Approved_Campaign_June21_IG", "Mobile": 60998545, "Phone": "", "Home Phone": "", "Email": "s.aalshatti@hotmail.com", "Email 2": "", "Address 1": "Qurtabah , Block 2 Street 1", "Address 2": "RASHA ABDULLAH SULAIMAN ALMATAR", "Address 3": "", "Address 4": "", "Address 5": "", "Enquiry Source": "", "Nationality Code": "", "Account Owner": "Jordan Walker", "Last Edit Date": "23/06/21", "Lead Owner": "Mohamed Kamal Naba", "Brand": "JAGUAR", "Model": "F-Type", "Demo": "--/--/----", "Quote": "23/06/21", "Order": "--/--/----", "Lost": "--/--/----", "Event Type": "", "Lost Sale Ref": "", "Type (NEW/USED)": "NEW", "Vehicle Identification Number": "SAJDB1BXXMCK74999", "Price": "17850", "VAT": "0", "Delivery Date": "27/06/21", "Invoice Date": "--/--/----", "Registration Date": "--/--/----" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Prospects/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundProspects.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod4() {
        string JsonMsg = '[ { "Lead Hub ID": "0bdc823f-434b-432c-bbd2-80392c1b3be6", "Customer unique Number": 143761, "Salutation": "Kuwait House", "First Name": "Kuwait", "Surname": "House", "Company Name": "Kuwait Finance House", "Gender": "Female", "Language": "en", "Employment Status": "", "Industry": "", "Occupation": "", "Lead Source": "Jaguar_Approved_Campaign_June21_IG", "Mobile": 60998545, "Phone": "", "Home Phone": "", "Email": "s.aalshatti@hotmail.com", "Email 2": "", "Address 1": "Qurtabah , Block 2 Street 1", "Address 2": "RASHA ABDULLAH SULAIMAN ALMATAR", "Address 3": "", "Address 4": "", "Address 5": "", "Enquiry Source": "", "Nationality Code": "", "Account Owner": "Jordan Walker", "Last Edit Date": "23/06/21", "Lead Owner": "Mohamed Kamal Naba", "Brand": "JAGUAR", "Model": "F-Type", "Demo": "--/--/----", "Quote": "--/--/----", "Order": "--/--/----", "Lost": "23/06/21", "Event Type": "", "Lost Sale Ref": "", "Type (NEW/USED)": "NEW", "Vehicle Identification Number": "SAJDB1BXXMCK74999", "Price": "17850", "VAT": "0", "Delivery Date": "27/06/21", "Invoice Date": "--/--/----", "Registration Date": "--/--/----" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Prospects/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundProspects.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod13() {
        string JsonMsg = '[ { "Lead Hub ID": "1ae96989-3993-4b7e-b8cf-41cb9eb3dfeo", "Customer unique Number": 141180, "Salutation": "Fahad Alostad", "First Name": "Fahad", "Surname": "Alostad", "Company Name": "", "Gender": "Male", "Language": "en", "Employment Status": "", "Industry": "", "Occupation": "", "Lead Source": "", "Mobile": 66233515, "Phone": "", "Home Phone": "", "Email": "alostath@hotmail.com", "Email 2": "", "Address 1": ".", "Address 2": "", "Address 3": "", "Address 4": "", "Address 5": "", "Enquiry Source": "", "Nationality Code": "", "Account Owner": "Ziad Obeid", "Last Edit Date": "23/06/21", "Lead Owner": "Ahmad Abu Hawili", "Brand": "JAGUAR", "Model": "XJ", "Demo": "23/06/21", "Quote": "--/--/----", "Order": "--/--/----", "Lost": "23/06/21", "Event Type": "", "Lost Sale Ref": "", "Type (NEW/USED)": "UNQ", "Vehicle Identification Number": "SAJAA20N5GPV94032", "Price": "9490", "VAT": "0", "Delivery Date": "--/--/----", "Invoice Date": "--/--/----", "Registration Date": "--/--/----" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Prospects/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundProspects.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod14() {
        string JsonMsg = '[ { "Lead Hub ID": "1ae96989-3993-4b7e-b8cf-41cb9eb3dfeo", "Customer unique Number": 141180, "Salutation": "Fahad Alostad", "First Name": "Fahad", "Surname": "Alostad", "Company Name": "", "Gender": "Male", "Language": "en", "Employment Status": "", "Industry": "", "Occupation": "", "Lead Source": "", "Mobile": 66233515, "Phone": "", "Home Phone": "", "Email": "alostath@hotmail.com", "Email 2": "", "Address 1": ".", "Address 2": "", "Address 3": "", "Address 4": "", "Address 5": "", "Enquiry Source": "", "Nationality Code": "", "Account Owner": "Ziad Obeid", "Last Edit Date": "23/06/21", "Lead Owner": "Ahmad Abu Hawili", "Brand": "JAGUAR", "Model": "XJ", "Demo": "23/06/21", "Quote": "--/--/----", "Order": "--/--/----", "Lost": "23/06/21", "Event Type": "", "Lost Sale Ref": "", "Type (NEW/USED)": "UNQ", "Vehicle Identification Number": "SAJAA20N5GPV94032", "Price": "9490", "VAT": "0", "Delivery Date": "23/06/21", "Invoice Date": "--/--/----", "Registration Date": "--/--/----" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Prospects/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundProspects.create();
        Test.stopTest();
    }


}