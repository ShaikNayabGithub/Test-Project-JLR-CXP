public class MMIT_OpportunityInfoSetter_OppLineItem {
    private final MMIT_OpportunityRetriever opportunityRetriever;
    private final MMIT_AssetRetriever assetRetriever;
    private final MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter;

    private static final Schema.DescribeFieldResult OPPORTUNITY_ID_FIELD = Schema.OpportunityLineItem.OpportunityId.getDescribe();
    

    public MMIT_OpportunityInfoSetter_OppLineItem(MMIT_OpportunityRetriever opportunityRetriever,
            MMIT_AssetRetriever assetRetriever,
            MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter)
    {
        this.opportunityRetriever = opportunityRetriever;
        this.assetRetriever = assetRetriever;
        this.opportunityHandoverInfoSetter = opportunityHandoverInfoSetter;
    }


    public void SetVehicleInfo(List<OpportunityLineItem> opportuntyLineItems, Map<Id, OpportunityLineItem> oldMap)
    {
        //only process where Product or Order No changed
        List<OpportunityLineItem> opportuntyLineItemsToProcess = new List<OpportunityLineItem>();
        for(OpportunityLineItem opportuntyLineItem : opportuntyLineItems) {
            OpportunityLineItem oldItem = oldMap.get(opportuntyLineItem.Id);
            if(opportuntyLineItem.Vista_Order_Number__c != oldItem.Vista_Order_Number__c || 
                        opportuntyLineItem.Product2Id != oldItem.Product2Id) {
                opportuntyLineItemsToProcess.add(opportuntyLineItem);
            }
        }
        this.SetVehicleInfo(opportuntyLineItemsToProcess);
    }

    public void SetVehicleInfo(List<OpportunityLineItem> opportuntyLineItems)
    {
        Set<String> opportunityIds = SObjectUtilities.GetFieldValues(opportuntyLineItems, OPPORTUNITY_ID_FIELD.getName());
        List<Opportunity> opportunties = opportunityRetriever.Retrieve(opportunityIds);
        Map<String, List<Asset>> assetsByOpportunityId = assetRetriever.RetrieveByOpportunityId(opportunityIds);

        opportunityHandoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportuntyLineItems, opportunties);
        update opportunties;
    }
}