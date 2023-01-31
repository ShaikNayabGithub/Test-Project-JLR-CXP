/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/09/2019.
 */
public with sharing class BaseMulesoftConnector {

    private String varMethod;
    private String varEndpoint;
    private String varAuth;
    private String varBody;

    private void init(String calloutEndpointSettingsDeveloperName){
        Callout_Endpoint__mdt settings = getSettings(calloutEndpointSettingsDeveloperName);
        this.varEndpoint = settings.URL__c;
        buildAuth(settings.Username__c, settings.Password__c, settings.Encoded_Header__c);
        //buildAuth('uat.cxp.mule', 'j&hcsJchd)wwdfj$68');
    }


    public BaseMulesoftConnector(String calloutEndpointSettingsDeveloperName){
        init(calloutEndpointSettingsDeveloperName);
    }

    private Callout_Endpoint__mdt getSettings(String calloutEndpointSettingsDeveloperName){
        return [
                SELECT Id, URL__c, Username__c, Password__c, Encoded_Header__c
                FROM  Callout_Endpoint__mdt
                WHERE DeveloperName = :calloutEndpointSettingsDeveloperName
                LIMIT 1
        ];
    }


    private void buildAuth(String username, String password, string encodedHeader) {
        if(string.isBlank(encodedHeader)){
            Blob headerValue = Blob.valueOf(username + ':' + password);
            this.varAuth = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        }
        else
            this.varAuth = 'Basic ' + encodedHeader;
    }

    private HttpRequest buildHttpRequest(String endpoint, HttpMethods method){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setHeader(Constants.HTTP_HEADER_KEYS_AUTHORIZATION, this.varAuth);
        System.debug('AuthHeader: ' + httpReq.getHeader(Constants.HTTP_HEADER_KEYS_AUTHORIZATION));
        httpReq.setEndpoint(endpoint);
        System.debug('Endpoint: ' + httpReq.getEndpoint());
        httpReq.setMethod(method.name().toUpperCase());
        System.debug('Method: ' + httpReq.getMethod());
        return httpReq;
    }

    public String doCallout(HttpMethods method, String body){
        System.debug('>> doCallout');
        System.debug('Body: ' + body);
        Http http = new Http();
        HttpRequest httpReq = buildHttpRequest(this.varEndpoint, method);
        HttpResponse httpRes = new HttpResponse();

        String errorMessage = '';
        if (method == HttpMethods.POST || method == HttpMethods.PUT || method == HttpMethods.PATCH){
            httpReq.setBody(body);
            httpReq.setHeader(Constants.HTTP_HEADER_KEYS_CONTENT_TYPE, Constants.MIME_TYPES_JSON);
        }
        try{

            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                String retBody = httpRes.getBody();
                System.debug('Response: ' + retBody);
                return retBody;
            }else{
                errorMessage = 'Unexpected Error while communicating with Mulesoft  API. '
                        +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
            }

        }catch(System.Exception e){

            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorized endpoint: An Administrator must go to Setup -> Administer -> Security Control ->'
                        +' Remote Site Setting and add '+' '+ this.varEndpoint +' Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with Mulesoft API. '
                        +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
            }
        }
        System.debug('Errors: ' + errorMessage);
        return errorMessage;
    }

}