public class OpportunityCICodeClearer {
    public void Clear(List<OpportunityLineItem> opportunityLineItems)
    {
        String opportunityIdFieldName = OpportunityLineItem.OpportunityId.getDescribe().getName();
        Set<String> opportunityIds = SObjectUtilities.GetFieldValues(opportunityLineItems, opportunityIdFieldName);
        
        Map<Id, OpportunityLineItem> opportunityLineItemMap = new Map<Id, OpportunityLineItem>(opportunityLineItems);
        List<OpportunityLineItem> currentOpportunityLineItems = [Select OpportunityId, Brand__c From OpportunityLineItem Where OpportunityId IN: opportunityIds And Id Not IN: opportunityLineItemMap.KeySet()];
        
        List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
        
        for(OpportunityLineItem deletedOpportunityLineItem : opportunityLineItems){
            Boolean opportunityHasMatchingLineItems = this.MatchOpportunityLineItem(deletedOpportunityLineItem, currentOpportunityLineItems);
                        
            if(!opportunityHasMatchingLineItems){
                this.ClearOpportunityDealerCICodeForBrand(deletedOpportunityLineItem, opportunitiesForUpdate);
            }
        }
        
        // update opportunitiesForUpdate; 
        
        // Create a map that will hold the values of the list 
		Map < Id, Opportunity > opportunityMap = new Map < Id, Opportunity > ();

		// Put all the values from the list to map. 
        opportunityMap.putAll(opportunitiesForUpdate);
        if(opportunityMap.size() > 0) {
        	update opportunityMap.values();
        }
    }
    
    
    private Boolean MatchOpportunityLineItem(OpportunityLineItem opportunityLineItem, List<OpportunityLineItem> opportunityLineItems)
    {
        for(OpportunityLineItem currentOpportunityLineItem : opportunityLineItems){
            if(currentOpportunityLineItem.OpportunityId == opportunityLineItem.OpportunityId && currentOpportunityLineItem.Brand__c == opportunityLineItem.Brand__c){
                return true;
            }
        }
        return false;
    }
    
    private void ClearOpportunityDealerCICodeForBrand(OpportunityLineItem opportunityLineItem, List<Opportunity> opportunitiesForUpdate)
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Id = opportunityLineItem.OpportunityId;
        
        if(opportunityLineItem.Brand__c != null){
	        String brandId = ((String)(opportunityLineItem.Brand__c)).left(15);
	        BrandDealerCICodeMapping__c brandFieldInfo = BrandDealerCICodeMapping__c.getInstance(brandId);
	        if(brandFieldInfo != null && String.isNotEmpty(brandFieldInfo.FieldName__c)){
	            opportunity.put(brandFieldInfo.FieldName__c, '');
	            opportunitiesForUpdate.add(opportunity);
	        }
        }
        
    }
}