@isTest
public with sharing class DMSMessager_Factory_Test {
	static testMethod void CreateOutboundUpdaterIndia_ReturnsDMSMessagerUpdate_WhenCalled() {
        insert TestClass_ValidDMSConnectionBuilder.Build();
    	DMSMessager_Factory factory = new DMSMessager_Factory();
        DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('');
    	I_DMSMessager_Update result = factory.CreateOutboundUpdater_India(prefixHandler);
    	
    	System.assertNotEquals(null, result);
    }

    static testMethod void CreateInboundResponseHandlerIndia_ReturnsDMSMessagerUpdate_WhenCalled() {
        insert TestClass_ValidDMSConnectionBuilder.Build();
    	DMSMessager_Factory factory = new DMSMessager_Factory();
    	    	
    	I_DMSMessager_Response result = factory.CreateInboundResponseHandler_India();
    	
    	System.assertNotEquals(null, result);
    }
}