public class DMSMessager_Factory {    
    public I_DMSMessager_Update CreateOutboundUpdater_India(DMS_PrefixHandler prefixHandler)//in future make private and call/select from public method
    {
    	SOAPXMLAttributeConstructor soapXMLAttributeConstructor = new SOAPXMLAttributeConstructor();
    	I_HttpResponseAdapter responseAdapter = new HttpResponseAdapter_IndiaDMS();
    	DMSMessager_Siebel messager = this.BuildMessager_India();
    	return new DMSMessager_India_Update(messager, soapXMLAttributeConstructor, responseAdapter, prefixHandler);
    }
    
    public I_DMSMessager_Response CreateInboundResponseHandler_India()
    {
    	SOAPXMLAttributeConstructor soapXMLAttributeConstructor = new SOAPXMLAttributeConstructor();
    	DMSMessager_Siebel messager = this.BuildMessager_India();
    	return new DMSMessager_India_Response(messager, soapXMLAttributeConstructor);
    }
    
    private DMSMessager_Siebel BuildMessager_India()
    {
    	HttpRequestFactory httpRequestFactory = new HttpRequestFactory();
        DMS_Connection__c connectionDetails = [Select Endpoint_Address__c, Outbound_Action__c, Outbound_SOAP_Namespaces__c, Password__c, Response_Action__c, Response_SOAP_Namespaces__c,
            Username__c From DMS_Connection__c Where Name='India' Limit 1];
    	return new DMSMessager_Siebel(httpRequestFactory, connectionDetails);
    }
}