@isTest
//testing
public class A_DMSMessager_Siebel_Test {    
    static testmethod void GetSiebelDMLAction_ReturnsInsert_GivenEmptyString()
    {
    	A_DMSMessager_Siebel dmsMessager_Siebel = BuildDMSMessager();
    	string result = dmsMessager_Siebel.GetSiebelDMLAction('');
    	System.assertEquals('Insert', result);
    }
    
    static testmethod void GetSiebelDMLAction_ReturnsUpdate_GivenNonEmptyString()
    {
    	A_DMSMessager_Siebel dmsMessager_Siebel = BuildDMSMessager();
    	string result = dmsMessager_Siebel.GetSiebelDMLAction('NonEmptyString');
    	System.assertEquals('Update', result);
    }
    
    
    private static A_DMSMessager_Siebel BuildDMSMessager()
	{
		HttpRequestFactory httpRequestFactory = new HttpRequestFactory();
        DMS_Connection__c connectionDetails = new DMS_Connection__c();
		return new A_DMSMessager_Siebel(httpRequestFactory, connectionDetails);
	}
}