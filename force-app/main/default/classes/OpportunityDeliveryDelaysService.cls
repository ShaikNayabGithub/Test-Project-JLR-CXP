/**
 * Created by caleb@argologic.com.au on 17/06/2021.
 */

@RestResource(UrlMapping='/v1/DeliveryDelays/*')
global with sharing class OpportunityDeliveryDelaysService
{
    @HttpGet
    global static List<OpportunityDeliveryDelayAttributeDto> get()
    {
        return OpportunityDeliveryDelaysController.getOpportunitiesWithDeliveryDelays();
    }

    @HttpPost
    global static void post(List<String> opportunityIds)
    {
        OpportunityDeliveryDelaysController.updateSentOpportunities(opportunityIds);
    }
}