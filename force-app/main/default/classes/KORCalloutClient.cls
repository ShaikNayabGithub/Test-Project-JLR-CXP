/**
 * @description       : callout abstract class
 * @author            : HK
 * @group             : 
 * @last modified on  : 2022. 06. 09
 * @last modified by  : HK
**/
public abstract with sharing class KORCalloutClient {
    protected final String HEADER_CONTENT_TYPE = 'Content-Type';
    protected final String HEADER_CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    protected final string GRAND_TYPE_CLIENT_CREDENTIALS = 'client_credentials';
    protected final String CHARSET = 'charset=UTF-8';
    protected final String HEADER_AUTHORIZATION = 'Authorization';
    protected final String HEADER_BEARER_AUTHORIZATION = 'Bearer';
    protected final String HEADER_ACCEPT = 'Accept';
    protected final String HTTP_METHOD_GET = 'GET';
    protected final String HTTP_METHOD_POST = 'POST';
    protected final String HTTP_METHOD_PUT = 'PUT';
    protected final Integer DEFAULT_TIMEOUT = 120000;
    protected HttpRequest request;
    protected HttpResponse response;
    protected void doCallout() {
        this.response = new Http().send(request);
    }
    protected Boolean isStatusCodeOk() {
        return response.getStatusCode() == 200 || response.getStatusCode() == 201 || response.getStatusCode() == 202;
    }
    protected Integer getResponseStatusCode() {
        return response.getStatusCode();
    }
    protected String getResponseBody() {
        return response.getBody();
    }
    protected virtual HttpRequest createRequest(String method) {
        request = new HttpRequest();
        request.setMethod(method);
        return request;
    }
    protected abstract Object getResponseObject();
    public class CalloutClientException extends Exception {}
}