/**
 * Created by caleb@argologic.com.au on 6/10/2020.
 */

@IsTest
public with sharing class ServiceErrorLoggerTest
{
    @IsTest
    public static void test1()
    {
        // ACT
        Test.startTest();
        ServiceErrorLogger.logError(new List<string> {'/v1/test'}, new List<string> {'{"test":""}'});
        Test.stopTest();

        // ASSERT
        System.assertEquals(1, [SELECT Id FROM Jlr_Service_Error__c].size());
    }
}