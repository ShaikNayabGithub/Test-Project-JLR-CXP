/**
 * @description       : Get authorised token for main connect
 * @author            : HK
 * @group             : 
 * @last modified on  : 2022. 06. 09
 * @last modified by  : HK
**/
public with sharing class KORGetTokenCallout extends KORCalloutClient {

    private String clientId;
    private String clientSecret;
    private String authEndPoint;

    public KORGetTokenCallout() {
    }

    public TokenResponseWrapper getAccessToken() {
        createRequest();
        doCallout();
        return handleResponse();
    }

    public TokenResponseWrapper getAccessToken(String clientId, String clientSecret, String authEndPoint) {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.authEndPoint = authEndPoint;
        return this.getAccessToken();
    }


    public override Object getResponseObject() {
        try {
            return JSON.deserialize(getResponseBody(), TokenResponseWrapper.class);
        } catch (JSONException ex) {
            throw new JSONException('Response deserialization has failed.');
        }
    }

    private TokenResponseWrapper handleResponse() {
        if (isStatusCodeOk()) {
            return (TokenResponseWrapper) getResponseObject();
        } else {
            throw new CalloutClientException('Invalid status code: ' + getResponseStatusCode());
        }
    }

    public class TokenResponseWrapper {
        public String access_token;
        public String token_type;
        public String expires_in;
        public String scope;
        public String rest_instance_url;

    }
    
    private void createRequest() {
        request = super.createRequest(HTTP_METHOD_POST);
        request.setEndpoint(this.authEndPoint + '/v2/token');
        request.setHeader(HEADER_CONTENT_TYPE, HEADER_CONTENT_TYPE_APPLICATION_JSON);
        Map<String, String> bodyMap = new Map<String, String>{
            'grant_type' => GRAND_TYPE_CLIENT_CREDENTIALS,
            'client_id' => this.clientId,
            'client_secret' => this.clientSecret
        };
        request.setBody(JSON.serialize(bodyMap));
    }



}