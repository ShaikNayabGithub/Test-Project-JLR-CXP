/**
 * Created by caleb on 30/09/2022.
 */

global with sharing class BookworksVehicleRecallMock implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        return res;
    }
}