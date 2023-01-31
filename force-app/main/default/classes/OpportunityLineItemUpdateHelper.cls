public class OpportunityLineItemUpdateHelper {
    
    @future
    public Static void removeOrderNumberFromLineItemAndStampOnOpp(String oppStr){
        if(oppStr != null){
            List<Opportunity> lostOpps = (List<Opportunity>)json.deserialize(oppStr, List<Opportunity>.class);
            System.debug('removeOrderNumberFromLineItemAndStampOnOpp ' + lostOpps);
            if (!lostOpps.isEmpty()) {
                System.debug('lost opp not empty');
                List<OpportunityLineItem> lineItemsRemove = new List<OpportunityLineItem>();
                //create map OppId to oppLineItems
                List<OpportunityLineItem> opportunityLineItems = [
                    SELECT Id, OpportunityId, Vista_Order_Number__c
                    FROM OpportunityLineItem
                    WHERE Vista_Order_Number__c != ''
                    AND Opportunity.Id IN:lostOpps
                ];
                map<Id,Opportunity> oppUpdateMap = new map<Id,Opportunity>();
                for (Opportunity opp : lostOpps) {
                    for (OpportunityLineItem item : opportunityLineItems) {
                        if (item.OpportunityId == opp.Id) {
                            opp.Vista_Order_Number__c = item.Vista_Order_Number__c;
                            item.Vista_Order_Number__c = '';
                            lineItemsRemove.add(item);
                            oppUpdateMap.put(opp.Id,opp);
                        }
                    }
                }
                
                OpportunityProductTriggerHandler.skipLogic = true;
                if(lineItemsRemove != null
                   && !lineItemsRemove.isEmpty()){
                       update lineItemsRemove;
                   }
                if(oppUpdateMap != null
                   && !oppUpdateMap.isEmpty()){
                       update oppUpdateMap.values();
                   }
                OpportunityProductTriggerHandler.skipLogic = false;
            }
        }
    }
}