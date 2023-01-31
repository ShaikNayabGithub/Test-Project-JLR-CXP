public class Vista_DataMapRetriever {
    /*
    public List<PriceBookEntry> retrievePriceBookEntries(List<Vista_RecordGroup> requests)
    {
        List<PriceBookEntry> priceBooks = new List<PriceBookEntry>();
        string priceBookEntryQuery = 'SELECT Id, ProductCode, Product2Id, CurrencyISOCode, PriceBook2.Name, UnitPrice FROM PriceBookEntry WHERE ';
        List<string> WhereClauses = new List<string>();
        String WhereClauseFormat = '(Product2.ProductCode = \'\'{0}\'\' AND PriceBook2.Name = \'\'{1}\'\')';
		for(Vista_RecordGroup recGroup : requests)
        {
            WhereClauses.add(String.format(WhereClauseFormat, new List<String>{ recGroup.VistaVehicleOrder.Specification.DescriptionGroupId, recGroup.request.Market_Description__c}));
        }
        if(!WhereClauses.isEmpty())
        {
            priceBookEntryQuery += String.join(WhereClauses, 'OR');
            system.debug(priceBookEntryQuery);
            priceBooks = database.query(priceBookEntryQuery);  
        }
        
        return priceBooks;
    }
    
    public Map<String, Order> populateOrderToOrderNumberMap(set<string> orderNumbers)
    {
        Map<String, Order> OrdersMappedToOrderNumber = new Map<String, Order>();
        for (Order order : [SELECT Id, Vista_Order_Number__c FROM Order WHERE Vista_Order_Number__c IN :orderNumbers])
        {
            OrdersMappedToOrderNumber.put(order.Vista_Order_Number__c, order);
        }
        
        return OrdersMappedToOrderNumber;
    }
    
    public Map<string, string> populateEventCodesMappedToOrderNumbers(List<Vista_RecordGroup> requests)
    {
        Map<string, string> eventCodesMappedToOrderNumbers = new Map<string, string>();
        for(Vista_RecordGroup recGroup : requests)
        {
            if(!eventCodesMappedToOrderNumbers.containsKey(recGroup.VistaVehicleOrder.MetaOrderNumber))
            {
                eventCodesMappedToOrderNumbers.put(recGroup.VistaVehicleOrder.MetaOrderNumber, recGroup.VistaVehicleOrder.EventCode);
            }            
        }
        return eventCodesMappedToOrderNumbers;
    }
    
    public string getOrderNumberFromSObject(sObject genericObject)
    {
        string orderNumber;
        if(genericObject.getSObjectType() == Order.sObjectType)
        {
            orderNumber = (string)genericObject.get('Vista_Order_Number__c');
        }
        else if(genericObject.getSObjectType() == Asset.sObjectType)
        {
            orderNumber = (string)genericObject.get('Order_Number__c');
        }
        else if(genericObject.getSObjectType() == OrderItem.sObjectType)
        {
            OrderItem item = (OrderItem)genericObject;
            orderNumber = item.Order.Vista_Order_Number__c;
        }
        return orderNumber;
    }
    
    public Map<string, Product2> retrieveProducts(List<Vista_RecordGroup> requests)
    {
        List<string> productIds = new List<string>();
       	Map<string, Product2> productsMappedToProductCode = new Map<string, Product2>();
		for(Vista_RecordGroup recGroup : requests)
        {
            productIds.add(recGroup.VistaVehicleOrder.Specification.DescriptionGroupId);
        }
        system.debug('prodIDs ' + productIds);
        for(Product2 prod : [SELECT ProductCode, Description, Make__c, Model__c, Body_style__c, Engine__c, Wheel_Base__c, 
                             		Wheel_Driven__c, Exterior_Colour__c, Transmission__c
                             FROM Product2 WHERE ProductCode in :productIds])
        {
            productsMappedToProductCode.put(prod.ProductCode, prod);
        }
        
        return productsMappedToProductCode;
        
    }
    
    public Map<String, Opportunity> populateOpportunitiesMappedToOrderNumber(Map<String, List<Id>> OrdersMappedToOrderNumber)
    {
        System.debug('keyset' + OrdersMappedToOrderNumber.keySet());
        Map<String, Opportunity> OpportunitiesMappedToOrderNumber = new Map<String, Opportunity>();
        Map<string,Id> opportunityIds = new Map<string,Id>();
        for(OpportunityLineItem lineItem : [SELECT OpportunityId, Vista_Order_Number__c FROM OpportunityLineItem 
                                            WHERE Vista_Order_Number__c IN : OrdersMappedToOrderNumber.keySet()])
        {
            opportunityIds.put(lineItem.Vista_Order_Number__c, lineItem.OpportunityId);
        }
        
        List<Opportunity> oppAccounts = [SELECT AccountId, OwnerId FROM Opportunity WHERE Id In : opportunityIds.values()];
        
        for(string orderNumber : opportunityIds.keySet())
        {
            for(Opportunity opp : oppAccounts)
            {
                if(opp.Id == opportunityIds.get(orderNumber))
                {
                    OpportunitiesMappedToOrderNumber.put(orderNumber, opp);
                }
            }
        }
        return OpportunitiesMappedToOrderNumber;
    }
    
    public Map<String, Asset> retrieveAssetsMappedToOrderNumber(Set<String> orderNumbers)
    {
        Map<String, Asset> assetsMappedToOrderNumber = new Map<String, Asset>();
        for(Asset existingAsset : [SELECT Order_Number__c, Description_Group_Id__c FROM Asset WHERE Order_Number__c IN :orderNumbers])
        {
            assetsMappedToOrderNumber.put(existingAsset.Order_Number__c,  existingAsset);
        }
        return assetsMappedToOrderNumber;
    }
*/
}