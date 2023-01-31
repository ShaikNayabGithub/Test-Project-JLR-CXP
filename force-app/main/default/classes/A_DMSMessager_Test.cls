@isTest
public class A_DMSMessager_Test {
	static testmethod void SendOpportunity_CallsBuildSOAPHeaders_Once()
	{
		RequestMock requestMock = new RequestMock();
		Test.setMock(HttpCalloutMock.class, requestMock);
		
		Dummy_A_DMSMessager dmsMessager = BuildDummyDMSMessager();
		dmsMessager.Call_SendRequest();
		System.assertEquals(1, dmsMessager.BuildSOAPHeadersCallCount);
	}	
	
	private static Dummy_A_DMSMessager BuildDummyDMSMessager()
	{
		HttpRequestFactory httpRequestFactory = new HttpRequestFactory();
		DMS_Connection__c connectionDetails = new DMS_Connection__c();
		connectionDetails.Endpoint_Address__c = 'dummy';
		connectionDetails.Outbound_Action__c = 'dummy';
		return new Dummy_A_DMSMessager(httpRequestFactory, connectionDetails);
	}
	
	
    private class Dummy_A_DMSMessager extends A_DMSMessager
    {
    	public integer BuildSOAPHeadersCallCount = 0;
    	
    	public Dummy_A_DMSMessager (HttpRequestFactory httpRequestFactory, DMS_Connection__c connectionDetails)
	    {
	        super(httpRequestFactory, connectionDetails);
	    }
	    
	    public void Call_SendRequest()
	    {
	    	this.SendRequest('', true);
	    }
	    
	    protected override string BuildSOAPHeaders(){BuildSOAPHeadersCallCount++; return '';}
    }
    
    
    private class RequestMock implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest req) { return new HttpResponse(); }
    }
}