/**
 * Created by caleb on 03/06/2022.
 */

public with sharing class BookworksVehicleRecallController
{
    public class BookworksRecallDto
    {
        public String RecallCampaignId {get; set;}
    }

    // username pword
    // cxp
    // D8u#q1&pxXIVs0vDQv%6f@

    @InvocableMethod(Label='Send Recalled Vehicles To Bookworks')
    public static void sendRecalledVehiclesToBookworks(List<String> recallCampaignIds)
    {
        for (String recallCampaignId : recallCampaignIds)
        {
            BookworksRecallDto bookworksRecallDto = new BookworksRecallDto();
            bookworksRecallDto.RecallCampaignId = recallCampaignId;

            HttpRequest req = new HttpRequest();
            req.setBody(JSON.serialize(bookworksRecallDto));
            req.setEndpoint('callout:Mule4/v1/send-recall-to-bookworks');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('api-key', '{!$Credential.Password}');
            HttpResponse res = (new Http()).send(req);

            if (200 <= res.getStatusCode() && res.getStatusCode() < 300)
            {
                return;
            }
            else
            {
                throw new JlrCustomException('Unable to write file to bookworks please contact your system admin: ' + req.getEndpoint() + ':' + res.getBody());
            }
        }
    }
}