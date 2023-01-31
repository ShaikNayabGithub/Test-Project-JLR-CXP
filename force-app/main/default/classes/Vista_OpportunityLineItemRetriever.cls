public class Vista_OpportunityLineItemRetriever implements Vista_EntityRetriever_I {
    public void Retrieve(Vista_RequestCollection requestCollection)
    {
        if(requestCollection.OpportunityLineItems == null) {
            requestCollection.OpportunityLineItems = new Map<String, OpportunityLineItem>();
        }

        for(OpportunityLineItem opportunityLineItem : [SELECT Id, Vista_Order_Number__c,OpportunityId, Opportunity.AccountId, 
                Opportunity.OwnerId,opportunity.stageName,opportunity.IsWon, asset__c,has_vin__c FROM OpportunityLineItem
                WHERE Vista_Order_Number__c IN: requestCollection.RecordGroups.keySet()]){
            requestCollection.OpportunityLineItems.put(opportunityLineItem.Vista_Order_Number__c, opportunityLineItem);
        }
    }
}