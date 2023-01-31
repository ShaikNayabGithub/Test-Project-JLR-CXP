/**
 * Created by caleb@argologic.com.au on 30/10/2019.
 */
@isTest
public class NidasuOpportunityToMulesoftMockImpl implements HttpCalloutMock
{
    public static String BODY_SUCCESS = '{"data":[{"Id":"<replace>","Type":"Opportunity","Attributes":{"IsSuccess":true}}]}';

    public HTTPResponse respond(HTTPRequest req)
    {
        JSON.deserialize(req.getBody(), GetNidasuOpportunitiesResponseDto.class);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(BODY_SUCCESS.replace('<replace>', [SELECT Id FROM Opportunity][0].Id));
        res.setStatusCode(200);
        System.assertEquals('POST', req.getMethod());

        return res;
    }
}