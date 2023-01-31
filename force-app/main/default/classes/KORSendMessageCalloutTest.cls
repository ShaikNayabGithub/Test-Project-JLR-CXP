@isTest
public with sharing class KORSendMessageCalloutTest {
    
    private class RestMock implements HttpCalloutMock {
        String fullJson = '{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJZN25mVzcweG5VdExNc2h5cjdnZXgwNjMiLCJjbGllbnRfaWQiOiI1ZzFvdm50NnpkdnFwNWJvZXd5MGJ0OWYiLCJlaWQiOjUxNDAwODYwMywic3RhY2tfa2V5IjoiUzExIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciIsInBpZCI6MTQzfQ.KSmXu8o9sGAig_ko-cQbwD7Lenj_LYOp5ClSTrJASRU.AW_bhqoi59HM1AmxUguNrW6kI7j3w5zXzhrlG2qieFN4M1kiTf4igkHGOvCxky3885DERjf3Az7SBLiPPcxnKVu2OB-ya19wgqB3MImrJjvt6Cja3TIcgTAbT0lFkkR0XxCV-1oOSocwVMSWf9K0J959olWkjUwpmrful","token_type":"Bearer","expires_in":1079,"scope":"offline journeys_read list_and_subscribers_read","soap_instance_url":"https://mc5h4pnqrqvddlywl4ywj37j55hq.soap.marketingcloudapis.com/","rest_instance_url":"https://mc5h4pnqrqvddlywl4ywj37j55hq.rest.marketingcloudapis.com/"}';
        Integer resCode = 200;
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(resCode);
            return res;
        }
    }

    @isTest
    public static void testCase1(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();

        KORSendMessageCallout sendMessage = new KORSendMessageCallout('token', 'url');
        KORSendMessageCallout.BodyWrapper bodyWrapper = new KORSendMessageCallout.BodyWrapper();

        sendMessage.send2Dataextension(JSON.serialize(bodyWrapper));
  
        Test.StopTest();
    }

    @isTest
    public static void testCase2(){
        RestMock errorMock = new RestMock();
        errorMock.fullJson = 'abcdef';

        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();
        try {
            KORSendMessageCallout sendMessage = new KORSendMessageCallout('token', 'url');
            KORSendMessageCallout.BodyWrapper bodyWrapper = new KORSendMessageCallout.BodyWrapper();
            sendMessage.send2Dataextension(JSON.serialize(bodyWrapper));
        } catch (Exception e) {
            System.assertEquals('System.JSONException', e.getTypeName());
        }
  
        Test.StopTest();
    }


    @isTest
    public static void testCase3(){
        RestMock errorMock = new RestMock();
        errorMock.resCode = 404;
        Test.setMock(HttpCalloutMock.class, errorMock);
        Test.startTest();
        try {
            KORSendMessageCallout sendMessage = new KORSendMessageCallout('token', 'url');
            KORSendMessageCallout.BodyWrapper bodyWrapper = new KORSendMessageCallout.BodyWrapper();
            sendMessage.send2Dataextension(JSON.serialize(bodyWrapper));
        } catch (Exception e) {
            System.assertEquals('KORCalloutClient.CalloutClientException', e.getTypeName());
        }


        
  
        Test.StopTest();
    }


}