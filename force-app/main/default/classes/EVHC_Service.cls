@RestResource(urlMapping='/evhc/snapon/v1/*')
global with sharing class EVHC_Service{
    
    @HttpPost
    global static String doPost(){
        
        String jsonStr = null;
        EVHC_processor processor;
        String result;
        Integration_Log__c log=new Integration_Log__c();
        
        System.debug('<<< Request >>> ' + RestContext.request);
        
        If (null != RestContext.request.requestBody) {
            jsonStr = RestContext.request.requestBody.toString();
        }
        
        Try{
            log.status__c = 'Success';
            processor = new EVHC_Processor();
            result=processor.processEVHCrecords(jsonStr);
            log.response__c = result;
        }
        Catch(Exception e){
            log.status__c = 'Error';
            log.System_Error__c = e.getMessage();
            log.Apex_Log__c = e.getStackTraceString();
            return  ('Failed: '+e);
        }
        Finally{
            log.request__c=jsonStr.abbreviate(131072);
            log.service__c='EVHC';
            log.headers__c = JSON.serialize(RestContext.request.Headers);
            log.Http_Method__c = RestContext.request.httpMethod;
            log.requestURI__c = RestContext.request.requestURI;
            log.Resource_Path__c = RestContext.request.resourcePath;
            log.ip_address__c = RestContext.request.remoteAddress;    
            insert log;
        }
        
        return  result;
    }
}