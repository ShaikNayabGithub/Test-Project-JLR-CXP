public class MMIT_OpportunityLineItemRetriever {
    public List<OpportunityLineItem> Retrieve(Set<String> opportunityIds)
    {
        if(opportunityIds == null || opportunityIds.isEmpty()){
            return new List<OpportunityLineItem>();
        }
        return [SELECT Id, Brand__c, Model__c, Product2Id, Vista_Order_Number__c, OpportunityId
                 FROM OpportunityLineItem WHERE OpportunityId IN: opportunityIds];
    }
}