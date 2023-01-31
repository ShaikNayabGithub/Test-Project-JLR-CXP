public class OpportunityProductLookupSetter {
    public void SetMakeAndModel(List<OpportunityLineItem> opportunityLineItems)
    {
        Set<Id> productIds = new Set<Id>();
        
        for (OpportunityLineItem oli : opportunityLineItems) {
            productIds.add(oli.Product2Id);
        }
        
        List<Product2> products = [Select Id,Make__c, Model__c, RecordType.Name From Product2 Where Id in :productIds];
        Map<Id, Product2> productMap = new Map<Id, Product2>(products);
        
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            
            if(opportunityLineItem!=null)
                if(opportunityLineItem.product2id!=null)
                if(productMap.get(opportunityLineItem.Product2Id)!=null)
            {
                Product2 prod = productMap.get(opportunityLineItem.Product2Id); 
                opportunityLineItem.Brand__c = prod.Make__c;
                if(prod.Model__c != null){
                    opportunityLineItem.Model__c = prod.Model__c;
                }
                if(prod.Model__c == null && prod.RecordType.Name == 'Model'){
                    opportunityLineItem.Model__c  = prod.Id;
                }
                
            }    
            
        }
    }
    
}