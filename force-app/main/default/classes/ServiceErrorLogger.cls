/**
 * Created by caleb@argologic.com.au on 6/10/2020.
 */

public with sharing class ServiceErrorLogger
{
    public static void logError(List<string> endpoints, List<string> bodys)
    {
        List<Jlr_Service_Error__c> serviceErrors = new List<Jlr_Service_Error__c>();
        for (Integer i = 0; i < endpoints.size(); i++)
        {
            Jlr_Service_Error__c serviceError = new Jlr_Service_Error__c();
            serviceError.Body__c = bodys[i];
            serviceError.Endpoint__c = endpoints[i];
            serviceErrors.add(serviceError);
        }
        insert serviceErrors;
    }

    public static void logError(string endpoint, string body, Exception ex)
    {
        Jlr_Service_Error__c serviceError = new Jlr_Service_Error__c();
        serviceError.Body__c = body;
        serviceError.Endpoint__c = endpoint;
        serviceError.Error_Message__c = exceptionToString(ex);

        insert serviceError;
    }

    public static string exceptionToString(Exception ex)
    {
        return ex.getStackTraceString() + ' ' + ex.getTypeName() + ': ' + ex.getMessage();
    }

}