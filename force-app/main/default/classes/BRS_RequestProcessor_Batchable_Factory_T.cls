@isTest
public class BRS_RequestProcessor_Batchable_Factory_T {
    //largely usesless, class under test is just instanciates objects but is not covered by other unit tests due to callout to creation of class responsible for making callouts 
	//to the metadata API
    static testmethod void Build_ReturnsBRSRequestProcessorBatchable_WhenCalled()
    {
    	BRS_RequestProcessor_Batchable_Factory factory = new BRS_RequestProcessor_Batchable_Factory();
    	
    	BRS_RequestProcessor_Batchable result = factory.Build();
    	
    	System.AssertNotEquals(null, result);
    }
}