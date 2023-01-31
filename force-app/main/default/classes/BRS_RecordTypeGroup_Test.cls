@isTest
public class BRS_RecordTypeGroup_Test {
    static testmethod void AddPicklistValues_AddsPicklistOne_GivenPicklistOneAndEmptySets()
    {
    	String picklistName = 'One';
    	BRS_RecordTypeGroup recordTypeGroup = new BRS_RecordTypeGroup(ProductUtilities.RecordTypes.get('Derivative'));
    	
    	Set<String> values = new Set<String>();
    	Map<Id, BRS_Request__c> requests = new Map<Id, BRS_Request__c>();
    	
    	recordTypeGroup.AddPicklistValues(picklistName, values, requests);
    	
    	System.AssertEquals(picklistName, recordTypeGroup.RecordType.picklistValues[0].picklist);
    }
    
    static testmethod void AddPicklistValues_AddsPicklistOneAndValueOne_GivenPicklistOneAndValueOne()
    {
    	String picklistName = 'One';
    	String value1 = 'ValueOne';
    	BRS_RecordTypeGroup recordTypeGroup = new BRS_RecordTypeGroup(ProductUtilities.RecordTypes.get('Derivative'));
    	
    	Set<String> values = new Set<String>();
    	values.Add(value1);
    	Map<Id, BRS_Request__c> requests = new Map<Id, BRS_Request__c>();
    	
    	recordTypeGroup.AddPicklistValues(picklistName, values, requests);
    	
    	System.AssertEquals(value1, recordTypeGroup.RecordType.picklistValues[0].values[0].fullName);
    }
    
    static testmethod void AddPicklistValues_AddsPicklistOneAndValueTwo_GivenPicklistOneAndValuesOneAndTwo()
    {
    	String picklistName = 'One';
    	String value1 = 'ValueOne';
    	String value2 = 'ValueTwo';
    	BRS_RecordTypeGroup recordTypeGroup = new BRS_RecordTypeGroup(ProductUtilities.RecordTypes.get('Derivative'));
    	
    	Set<String> values = new Set<String>();
    	values.Add(value1);
    	values.Add(value2);
    	Map<Id, BRS_Request__c> requests = new Map<Id, BRS_Request__c>();
    	
    	recordTypeGroup.AddPicklistValues(picklistName, values, requests);
    	
    	System.AssertEquals(value2, recordTypeGroup.RecordType.picklistValues[0].values[1].fullName);
    }
    
    static testmethod void AddPicklistValues_AddsRequestOne_GivenPicklistOneAndRequestOne()
    {
    	String picklistName = 'One';
    	BRS_RecordTypeGroup recordTypeGroup = new BRS_RecordTypeGroup(ProductUtilities.RecordTypes.get('Derivative'));
    	
    	Set<String> values = new Set<String>();
    	Map<Id, BRS_Request__c> requests = new Map<Id, BRS_Request__c>();
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	requests.Put(request.Id, request);
    	
    	recordTypeGroup.AddPicklistValues(picklistName, values, requests);
    	
    	System.AssertEquals(request, recordTypeGroup.Requests.get(request.Id));
    }
    
    static testmethod void AddPicklistValues_AddsRequestTwo_GivenPicklistOneAndRequestOneAndTwo()
    {
    	String picklistName = 'One';
    	BRS_RecordTypeGroup recordTypeGroup = new BRS_RecordTypeGroup(ProductUtilities.RecordTypes.get('Derivative'));
    	
    	Set<String> values = new Set<String>();
    	Map<Id, BRS_Request__c> requests = new Map<Id, BRS_Request__c>();
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	requests.Put(request.Id, request);
    	BRS_Request__c request2 = TestClass_BRSRequestCreator.Create();
    	requests.Put(request2.Id, request2);
    	
    	recordTypeGroup.AddPicklistValues(picklistName, values, requests);
    	
    	System.AssertEquals(request2, recordTypeGroup.Requests.get(request2.Id));
    }
}