/**
 * @description       : message callout service
 * @author            : HK
 * @group             : 
 * @last modified on  : 2022. 06. 09
 * @last modified by  : HK
**/
public with sharing class KORSendMessageCallout extends KORCalloutClient {
    
    private String restEndPoint;
    private String token;
    private String bodyStr;

    private KORSendMessageCallout() {}
    public KORSendMessageCallout(String token, String restEndPoint) {
        this();
        this.token = token;
        this.restEndPoint = restEndPoint;
    }

    public ResponseWrapper send2Dataextension(String bodyStr) {
        this.bodyStr = bodyStr;
        createRequest();
        doCallout();
        return handleResponse();
    }


    public override Object getResponseObject() {
        try {
            return JSON.deserialize(getResponseBody(), ResponseWrapper.class);
        } catch (JSONException ex) {
            throw new JSONException('Response deserialization has failed.');
        }
    }

    private void createRequest() {
        request = super.createRequest(HTTP_METHOD_POST);
        request.setEndpoint(this.restEndPoint + '/interaction/v1/events');
        request.setHeader(HEADER_CONTENT_TYPE, HEADER_CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(HEADER_AUTHORIZATION, HEADER_BEARER_AUTHORIZATION + ' ' + TOKEN);
        request.setBody(bodyStr);
    }


    private ResponseWrapper handleResponse() {
        if (isStatusCodeOk()) {
            return (ResponseWrapper) getResponseObject();
        } else {
            throw new CalloutClientException('Invalid status code: ' + getResponseStatusCode());
        }
    }


    public class BodyWrapper {
        public String contactKey;
        public String EventDefinitionKey;
        public Data data;
        

        public BodyWrapper(){
            data = new Data();
        }
    }

    public class Data {
        public String recordId;
        public String toNumber;
        public String content;
        public String uuid;
        public String issuedDate;

        public Data(){
            recordId = '';
            toNumber = '';
            content = '';
            uuid = '';
            Datetime now = Datetime.now();
            issuedDate = now.format('yyyy-MM-dd HH:mm:ss', 'Asia/Seoul');
            // resTime = '';
        }
    }

    public class ResponseWrapper {
        String eventInstanceId;
    }
}