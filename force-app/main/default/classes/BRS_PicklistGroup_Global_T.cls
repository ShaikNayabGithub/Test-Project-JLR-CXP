@isTest
public class BRS_PicklistGroup_Global_T {
	static testmethod void AddPicklistValueStringRequest_AddsPicklistValueOne_GivenPicklistOneAndRequest()
    {
    	String picklistValue = 'picklistValue1';
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	picklistGroup.AddPicklistValue(picklistValue, request);
    	
    	System.Assert(picklistGroup.GetValues().Contains(picklistValue));
    }
    
    static testmethod void AddPicklistValueStringRequest_AddsRequest_GivenPicklistOneAndRequest()
    {
    	String picklistValue = 'picklistValue1';
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	picklistGroup.AddPicklistValue(picklistValue, request);
    	
    	System.AssertEquals(request, picklistGroup.Requests.get(request.Id));
    }
    
    static testmethod void AddPicklistValueStringRequest_AddsPicklistValueOne_GivenPicklistOneAndRequestTwice()
    {
    	String picklistValue = 'picklistValue1';
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	picklistGroup.AddPicklistValue(picklistValue, request);
    	picklistGroup.AddPicklistValue(picklistValue, request);
    	
    	System.AssertEquals(1, picklistGroup.GetValues().Size());
    }
    
    static testmethod void AddPicklistValueStringRequest_AddsPicklistValueOne_GivenPicklistOneTwiceAndRequestOneAndTwo()
    {
    	String picklistValue = 'picklistValue1';
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	BRS_Request__c request2 = TestClass_BRSRequestCreator.Create();
    	
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	picklistGroup.AddPicklistValue(picklistValue, request);
    	picklistGroup.AddPicklistValue(picklistValue, request2);
    	
    	System.AssertEquals(2, picklistGroup.Requests.Size());
    }
    
    
    static testmethod void AddPicklistValueString_AddsPicklistValueOne_GivenPicklistOne()
    {
    	String picklistValue = 'picklistValue1';
    	
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	picklistGroup.AddPicklistValue(picklistValue);
    	
    	System.Assert(picklistGroup.GetValues().Contains(picklistValue));
    }
    
    static testmethod void AddPicklistValueString_AddsOnePicklistValue_GivenPicklistOneTwice()
    {
    	String picklistValue = 'picklistValue1';
    	
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	picklistGroup.AddPicklistValue(picklistValue);
    	picklistGroup.AddPicklistValue(picklistValue);
    	
    	System.AssertEquals(1, picklistGroup.GetValues().Size());
    }
}