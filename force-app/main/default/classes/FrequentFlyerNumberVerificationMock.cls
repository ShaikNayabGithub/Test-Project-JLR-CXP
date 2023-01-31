/**
 * Created by caleb@argologic.com.au on 4/12/2019.
 */

public with sharing class FrequentFlyerNumberVerificationMock implements HttpCalloutMock
{
    public HTTPResponse respond(HTTPRequest req)
    {
        System.debug('mockResponse( requestBody = ' + req.getBody() + ')');
        try
        {
            JSON.deserialize(req.getBody(), GetContactsLoyaltyStatusRequestWrapper.class);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(JSON.serialize(new GetContactsLoyaltyStatusRequestWrapper()));
            res.setStatusCode(200);
            System.assertEquals('POST', req.getMethod());

            return res;
        }
        catch (Exception e)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(JSON.serialize(new GetContactsLoyaltyStatusRequestWrapper()));
            res.setStatusCode(400);
            System.assertEquals('POST', req.getMethod());

            return res;
        }
    }
}