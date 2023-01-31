public class Vista_RequestCollection {
    public Map<String, List<Vista_RecordGroup>> RecordGroups;
    public Map<String, Order> Orders;
    public Map<String, Asset> Assets;
    public Map<String, OrderItem> OrderItemsForDelete;
    public Map<String, OrderItem> OrderItemsForInsert;

    public Map<String, OpportunityLineItem> OpportunityLineItems;
    public Map<String, Product2> Derivatives;//by ProductCode 
    public Map<String, PriceBookEntry> PriceBookEntries;//by [5000code]_[Market]
    public Map<String, Account> Retailers;//by Primary_Dealer_Code__c
    public Map<String, Account> migratedVehicles;

}