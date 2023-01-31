public class MMIT_OpportunityHandoverInfoSetter {
    private static final Schema.DescribeFieldResult OLI_OPPORTUNITY_ID_FIELD = Schema.OpportunityLineItem.OpportunityId.getDescribe();
    private static final String HANDOVER_STAGE_NAME = 'Handover';
    private static final String RDA_STAGE_NAME = 'Handover & RDA';

    public void SetVehicleInfo(Map<String, List<Asset>> assetsByOpportunityId, 
            List<OpportunityLineItem> opportunityLineItems, List<Opportunity> opportunities)
    {
        Map<Id, List<SObject>> opportunityLineItemByOpportunityId = SObjectUtilities.MapByIdField(opportunityLineItems, 
                OLI_OPPORTUNITY_ID_FIELD);
        List<Asset> assets;        

        for(Opportunity opportunity : opportunities) {
            if(opportunity.StageName != HANDOVER_STAGE_NAME && opportunity.StageName != RDA_STAGE_NAME) { continue; }

            if(assetsByOpportunityId.size()>0)
                assets = assetsByOpportunityId.get(opportunity.Id);
                
            List<SObject> opportunityLineItemSubList = opportunityLineItemByOpportunityId.get(opportunity.Id);

            if(assets != null && assets.Size() > 0) {
                opportunity.Handover_Brand__c = assets[0].Brand__c;
                opportunity.Handover_Model__c = assets[0].Model__c;
                opportunity.Handover_Derivative__c = assets[0].Derivative__c;
                opportunity.VIN__c = assets[0].VIN__c;
                opportunity.Vista_Order_Number__c = assets[0].Order_Number__c;
            } else if(opportunityLineItemSubList != null && opportunityLineItemSubList.Size() > 0) {
                OpportunityLineItem opportunityLineItem = (OpportunityLineItem)opportunityLineItemSubList[0];
                opportunity.Handover_Brand__c = opportunityLineItem.Brand__c;
                opportunity.Handover_Model__c = opportunityLineItem.Model__c;
                opportunity.Handover_Derivative__c = opportunityLineItem.Product2Id;
                opportunity.Vista_Order_Number__c = opportunityLineItem.Vista_Order_Number__c;
            }
        }
    }
}