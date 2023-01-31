@isTest
public class DMSUpdater_Factory_Test {
	static testMethod void Create_ReturnsDMSUpdater_WhenCalled() {
		insert TestClass_ValidDMSConnectionBuilder.Build();
    	DMSUpdater_Factory factory = new DMSUpdater_Factory();
    	    	
    	DMSUpdater result = factory.Create();
    	
    	System.assertNotEquals(null, result);
    }
}