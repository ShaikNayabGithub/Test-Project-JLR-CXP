public class SF_SessionIdRetriever {
	private final HttpRequestFactory HTTP_REQUEST_FACTORY = new HttpRequestFactory();
	
	
    public virtual String RetrieveSessionId()
    {
    	String sessionId = UserInfo.getSessionId();
    	if(String.isNotEmpty(sessionId)) { return sessionId; }
    	
    	DMS_Connection__c credentials = [SELECT Username__c, Password__c, Endpoint_Address__c FROM DMS_Connection__c WHERE Name='Metadata' LIMIT 1];//????
    	
    	return this.GetNewSessionIdFromSalesforce(credentials);
    }
    
    
    private String GetNewSessionIdFromSalesforce(DMS_Connection__c credentials)
    {
    	Http h = new Http();
    	HttpRequest request = this.HTTP_REQUEST_FACTORY.BuildEmptyRequest('""', credentials.Endpoint_Address__c);
    	
    	String requestString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
		       '<soapenv:Header><urn:LoginScopeHeader></urn:LoginScopeHeader></soapenv:Header>'+
		       '<soapenv:Body>'+
		       		'<urn:login>'+
         				'<urn:username>'+credentials.Username__c+'</urn:username>'+
         				'<urn:password>'+credentials.Password__c+'</urn:password>'+
      				'</urn:login>'+
		       '</soapenv:Body></soapenv:Envelope>';
		request.setHeader('Content-Length', String.valueOf(requestString.length()));
		request.setBody(requestString);
		
		HttpResponse response = h.send(request);
		String responseBody = response.getBody();
		
		List<String> splitResponse = responseBody.split('<sessionId>');
		splitResponse = splitResponse[1].split('</sessionId>');
		
		return splitResponse[0];
    }
}