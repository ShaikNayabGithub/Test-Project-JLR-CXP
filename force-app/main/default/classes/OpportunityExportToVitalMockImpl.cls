/**
 * Created by caleb@argologic.com.au on 6/01/2020.
 */

public with sharing class OpportunityExportToVitalMockImpl implements HttpCalloutMock
{
    public static String BODY_SUCCESS = 'Success';
    public static String BODY_FAILURE = 'Failure';

    public HTTPResponse respond(HTTPRequest req)
    {
        System.debug('mockResponse( requestBody = ' + req.getBody() + ')');

        JSON.deserialize(req.getBody(), VitalExportRequest.class);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(BODY_SUCCESS);
        res.setStatusCode(200);
        System.assertEquals('POST', req.getMethod());

        return res;
    }
}