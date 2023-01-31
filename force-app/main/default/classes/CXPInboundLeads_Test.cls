@isTest
public class CXPInboundLeads_Test {
    
    @testSetup
    static void dataSetup() {
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'Generic' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
    }
    
    @isTest
    static void testMethod1() {
        Lead lId = [Select id from Lead];
        string JsonMsg = '[ { "External Oem Reference ID": "' + lId.id + '", "Lead Hub ID": "14cf4e52-5f77-4a14-a76b-a1cf823be98d", "First Name": "Nourddine", "Surname": "AITBENDRA", "Status": "Converted", "Enquiry Type": "GENERAL_SALES_INQUIRY", "Mobile": "", "Phone": 567196063, "Email": "bidaya.trade@gmail.com", "Task Action Owner": "", "Date Lead Assigned": "--/--/----", "CRM agent": "", "Lost Lead Comments": "<jlrsama 22/06/2021 11:11:50>Duplicate------------------", "Edited On": "22/06/21", "Edited At": "11:11:51" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Leads/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundLeads.create();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() {
        Lead lId = [Select id from Lead];
        string JsonMsg = '[ { "External Oem Reference ID": "' + lId.id + '", "Lead Hub ID": "14cf4e52-5f77-4a14-a76b-a1cf823be98d", "First Name": "Nourddine", "Surname": "AITBENDRA", "Status": "Rejected", "Enquiry Type": "GENERAL_SALES_INQUIRY", "Mobile": "", "Phone": 567196063, "Email": "bidaya.trade@gmail.com", "Task Action Owner": "", "Date Lead Assigned": "--/--/----", "CRM agent": "", "Lost Lead Comments": "<jlrsama 22/06/2021 11:11:50>Duplicate------------------", "Edited On": "22/06/21", "Edited At": "11:11:51" } ]';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/Leads/';
        req.requestBody = Blob.valueof(JsonMsg);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        String acctId = CXPInboundLeads.create();
        Test.stopTest();
    }

}