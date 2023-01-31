@isTest
public class TestClass_ValidDMSConnectionBuilder {
	public static DMS_Connection__c Build()
    {
    	DMS_Connection__c connectionDetails = new DMS_Connection__c();
    	connectionDetails.Name = 'India';
    	return connectionDetails;
    }
}