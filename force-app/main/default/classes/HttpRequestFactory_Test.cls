@isTest
public class HttpRequestFactory_Test {
    static testMethod void BuildEmptyRequest_SetsSOAPActionToSOAPActionValue_StringSOAPActionValue() {
    	HttpRequestFactory httpRequestFactory = new HttpRequestFactory();
    	HttpRequest request = httpRequestFactory.BuildEmptyRequest('SOAPActionValue','');
    	
    	System.assertEquals('SOAPActionValue', request.getHeader('SOAPAction'));
    }
    
    static testMethod void BuildEmptyRequest_SetsEndpointToEndpointValue_StringEndpointValue() {
    	HttpRequestFactory httpRequestFactory = new HttpRequestFactory();
    	HttpRequest request = httpRequestFactory.BuildEmptyRequest('','EndpointValue');
    	
    	System.assertEquals('EndpointValue', request.getEndpoint());
    }
}