/**
 * Created by Ethan Sargent on 24/2/20.
 */
@IsTest
public with sharing class InvocableSMSControllerTestMock implements HttpCalloutMock
{
    public static String BODY_SUCCESS = '{"data":[{"Id":"<replace>","Type":"Opportunity","Attributes":{"IsSuccess":true}}]}';

    public HttpResponse respond(HttpRequest req)
    {

        //JSON.deserialize(req.getBody(), GetNidasuOpportunitiesResponseDto.class);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        System.assertEquals('POST', req.getMethod());
        System.debug('HTTP Request Body: ' + req.getBody());
        Object deserializedJSON = JSON.deserializeUntyped(req.getBody());
        Map<String, Object> requestDto = (Map<String, Object>) deserializedJSON;

        if (isRequestValid(requestDto))
        {
            res.setStatusCode(200);
            res.setBody('{"Success":"Mock SMS Success"}');
        }
        else
        {
            res.setStatusCode(400);
            res.setBody('{"ErrorMessage":"Invalid Request."}');
        }

        return res;
    }

    private Boolean isRequestValid(Map<String, Object> req)
    {
        System.debug('>> isRequestValid('+req+')');
        if (req.get('To') == null || req.get('From') == null || req.get('Text') == null)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
}