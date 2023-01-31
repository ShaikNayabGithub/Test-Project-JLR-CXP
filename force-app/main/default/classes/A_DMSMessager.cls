public abstract class A_DMSMessager implements I_HttpMessager{
	private final HttpRequestFactory httpRequestFactory;
	protected final DMS_Connection__c connectionDetails;
	
	protected A_DMSMessager(HttpRequestFactory httpRequestFactory, DMS_Connection__c connectionDetails)
	{
		this.httpRequestFactory = httpRequestFactory;
		this.connectionDetails = connectionDetails;
	}
	
    
    public HttpResponse SendRequest(string soapBody, boolean isOutbound)
    {
    	string namespaces = GetNamespaces(isOutbound);
    	string soapAction = GetSOAPAction(isOutbound);

    	Http h = new Http();
		HttpRequest request = httpRequestFactory.BuildEmptyRequest(soapAction, connectionDetails.Endpoint_Address__c);
		
		String requestString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" '+ namespaces +'>'+
		       '<soapenv:Header>'+this.BuildSOAPHeaders()+'</soapenv:Header>'+
		       '<soapenv:Body>'+
		       		soapBody+
		       '</soapenv:Body></soapenv:Envelope>';
		request.setHeader('Content-Length', String.valueOf(requestString.length()));
		request.setBody(requestString);

		return h.send(request);
    }


    private string GetNamespaces(boolean isOutbound)
    {
    	if(isOutbound){ return this.connectionDetails.Outbound_SOAP_Namespaces__c; }
    	return this.connectionDetails.Response_SOAP_Namespaces__c;
    }
    
    private string GetSOAPAction(boolean isOutbound)
    {
    	if(isOutbound){ return this.connectionDetails.Outbound_Action__c; }
    	return this.connectionDetails.Response_Action__c;
    }

    protected abstract string BuildSOAPHeaders();
}