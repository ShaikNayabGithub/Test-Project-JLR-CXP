@isTest
public with sharing class ConvertLead_Tests {
    
    @isTest 
    public static void Test_execute() {
        String accountType = 'Private';
        Lead myLead = TestClass_LeadCreator.CreateConvertableLead(accountType);

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"leadId": "' + myLead.Id + '"}');
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConvertLead.execute();
        Test.stopTest();

        Assert.isNotNull(RestContext.response);
    }
}