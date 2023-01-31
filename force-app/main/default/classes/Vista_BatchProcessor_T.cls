@isTest
 public class Vista_BatchProcessor_T {
    static testmethod void updateOpportunitiesWithCancelOroHandoverOrders()
    {
  
        final string HANDOVER='Handover';
        Vista_ExistingRecordRetriever_F recordRetrieverFactory = new Vista_ExistingRecordRetriever_F();
        Vista_EnhancedDbActor_Handler_F dbActorHandlerFactory = new Vista_EnhancedDbActor_Handler_F();
        Vista_OrderBuilder_F orderBuilderFactory = new Vista_OrderBuilder_F();
        Vista_AssetBuilder_F assetBuilderFactory = new Vista_AssetBuilder_F();
     
        Vista_EntityRetriever_I existingRecordRetriever = recordRetrieverFactory.Create();
        Vista_EnhancedDbActor_Handler enhancedDbActorHandler = dbActorHandlerFactory.Create();
        Vista_OrderBuilder orderBuilder = orderBuilderFactory.Create();
        Vista_AssetBuilder assetBuilder = assetBuilderFactory.Create();
        Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();
    
        Vista_BatchProcessor vistaBatchProcessor=new Vista_BatchProcessor(existingRecordRetriever, enhancedDbActorHandler, orderBuilder, assetBuilder, orderItemBuilder);
            
        Vista_RequestCollection requestCollection = new Vista_RequestCollection();

        requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
        requestCollection.OrderItemsForDelete = new Map<String, OrderItem>();
        requestCollection.OrderItemsForInsert = new Map<String, OrderItem>();
        requestCollection.Derivatives = new Map<String, Product2>();
        requestCollection.Orders = new Map<String, Order>();
        requestCollection.OpportunityLineItems= new Map<String,opportunityLineItem>();
        Opportunity opp= new Opportunity();
        opp.name='test1';
        opp.stageName='Negotiation';
        opp.closedate=Date.TODAY();
        insert opp;
        requestCollection.OpportunityLineItems.put('1', new OpportunityLineItem(opportunity=opp,opportunityId=opp.id,Vista_Order_Number__c='12345'));
        
        requestCollection.orders.put('12345',new Order(Vista_Order_Number__c='12345',Last_Event__c='Handover'));
        requestCollection.PriceBookEntries = new Map<String, PriceBookEntry>();    
            
        vistaBatchProcessor.updateOpportunitiesWithCancelOroHandoverOrders(requestCollection);
        
        List<Opportunity> listOpportunities= [select id,stagename from opportunity where id=:opp.id];
        String stageName;
        
        if (listOpportunities.isEmpty()==false)
            stageName=listOpportunities[0].stageName;

        system.assertNotEquals(stageName, HANDOVER);
      }            
}