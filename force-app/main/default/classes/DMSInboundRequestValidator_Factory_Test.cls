@isTest
public with sharing class DMSInboundRequestValidator_Factory_Test {
	static testMethod void Create_ReturnsDMSInboundRequestValidator_GivenEmptyList() {
    	DMSInboundRequestValidator_Factory factory = new DMSInboundRequestValidator_Factory();
    	
    	List<Id> input = new List<Id>();
    	
    	DMSInboundRequestValidator result = factory.Create(input);
    	
    	System.assertNotEquals(null, result);
    }
}