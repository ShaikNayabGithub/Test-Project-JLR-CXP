@isTest
public class DMSMessager_Siebel_Test {    
    static testmethod void GetSiebelDMLAction_ReturnsInsert_GivenEmptyString()
    {
        DMSMessager_Siebel dmsMessager_Siebel = BuildDMSMessager();
        string result = dmsMessager_Siebel.GetSiebelDMLAction('');
        System.assertEquals('Insert', result);
    }
    
    static testmethod void GetSiebelDMLAction_ReturnsUpdate_GivenNonEmptyString()
    {
        DMSMessager_Siebel dmsMessager_Siebel = BuildDMSMessager();
        string result = dmsMessager_Siebel.GetSiebelDMLAction('NonEmptyString');
        System.assertEquals('Update', result);
    }
    
    
    private static DMSMessager_Siebel BuildDMSMessager()
    {
        HttpRequestFactory httpRequestFactory = new HttpRequestFactory();
        DMS_Connection__c connectionDetails = new DMS_Connection__c();
        return new DMSMessager_Siebel(httpRequestFactory, connectionDetails);
    }
}