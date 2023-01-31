public class Vista_OrderRetriever implements Vista_EntityRetriever_I {
    public void Retrieve(Vista_RequestCollection requestCollection)
    {
        if(requestCollection.Orders == null) {
            requestCollection.Orders = new Map<String, Order>();
        }

        for(Order order : [SELECT Id, Vista_Order_Number__c,Pricebook2Id,CurrencyIsoCode,Last_Event__c,has_products__c ,Account.RecordType.DeveloperName FROM Order 
                WHERE Vista_Order_Number__c IN: requestCollection.RecordGroups.keySet()]) {
            requestCollection.Orders.put(order.Vista_Order_Number__c, order);
        }
    }
}