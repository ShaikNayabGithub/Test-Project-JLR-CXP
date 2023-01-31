@isTest
public class Vista_OpportunityOrderCancelledLogic_T {
    @isTest
    static void Vista_OpportunityOrderCancelledLogic_TestSetsEventDateTimeWhenCancelled()
    {
		DateTime nowtesttime =  DateTime.now();  
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
        Map<String, List<Vista_RecordGroup>> vistaGroupMap  = new Map<String, List<Vista_RecordGroup>>(); 
        List<Vista_RecordGroup> rgroup = new List<Vista_RecordGroup>();
        Vista_RecordGroup regroup = new Vista_RecordGroup();
       // select id, VIN__c, MetaOrderNumber__c
       Vista_Request__c request = new Vista_Request__c();
        request.VIN__C = 'saj123';
        request.MetaOrderNumber__c = '12345';
        request.CreatedDate =nowtesttime;
        request.CommonStatusPoint__c = 'Order Cancelled';
        request.EventDateTime__c = nowtesttime;
       system.debug('Request '+JSON.serializePretty(request));
        
        regroup.Request =request;
        rgroup.add(regroup);
        vistaGroupMap.put('12345',rgroup);

        requestCollection.RecordGroups = vistaGroupMap;
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
        //OpportunityLineItem oppLineitem = new OpportunityLineItem(opportunity=opp,opportunityId=opp.id,Vista_Order_Number__c='12345', Quantity = 1, TotalPrice = 100);
       OpportunityLineItem oppLineitem = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, null, null);
        oppLineitem.Vista_Order_Number__c = '12345';
        
        insert oppLineitem;
        Test.startTest();
        OpportunityLineItem newoppLineitem = [SELECT Id, Vista_Order_Number__c, Opportunity.AccountId, 
                Opportunity.OwnerId,opportunity.stageName,opportunity.IsWon, asset__c,has_vin__c FROM OpportunityLineItem
                WHERE Vista_Order_Number__c = '12345' limit 1];
        requestCollection.OpportunityLineItems.put('12345', newoppLineitem);
        
        requestCollection.orders.put('12345',new Order(Vista_Order_Number__c='12345',Last_Event__c='Cancelled'));
        requestCollection.PriceBookEntries = new Map<String, PriceBookEntry>();    
        
        Vista_OpportunityOrderCancelledLogic vocl = new Vista_OpportunityOrderCancelledLogic();
        Opportunity opppppp = vocl.setCancelledDateAndStageIfCancelled(oppLineItem, requestCollection);
        system.debug('Its NOW'+opppppp);
            
     
        Test.stopTest();      
        

        system.assertEquals(opppppp.Date_Cancelled_Time__c,nowtesttime );
      }   
    
    @isTest
    static void Vista_OpportunityOrderCancelledLogic_TestSetsStageBackToNegotiationWhenCancelled()
    {
		DateTime nowtesttime =  DateTime.now();  
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
        Map<String, List<Vista_RecordGroup>> vistaGroupMap  = new Map<String, List<Vista_RecordGroup>>(); 
        List<Vista_RecordGroup> rgroup = new List<Vista_RecordGroup>();
        Vista_RecordGroup regroup = new Vista_RecordGroup();
       // select id, VIN__c, MetaOrderNumber__c
       Vista_Request__c request = new Vista_Request__c();
        request.VIN__C = 'saj123';
        request.MetaOrderNumber__c = '12345';
        request.CreatedDate =nowtesttime;
        request.CommonStatusPoint__c = 'Order Cancelled';
        request.EventDateTime__c = nowtesttime;
       system.debug('Request '+JSON.serializePretty(request));
        
        regroup.Request =request;
        rgroup.add(regroup);
        vistaGroupMap.put('12345',rgroup);

        requestCollection.RecordGroups = vistaGroupMap;
        requestCollection.OrderItemsForDelete = new Map<String, OrderItem>();
        requestCollection.OrderItemsForInsert = new Map<String, OrderItem>();
        requestCollection.Derivatives = new Map<String, Product2>();
        requestCollection.Orders = new Map<String, Order>();
        requestCollection.OpportunityLineItems= new Map<String,opportunityLineItem>();
        Opportunity opp= new Opportunity();
        opp.name='test1';
        opp.stageName='Handover';
        opp.closedate=Date.TODAY();
        insert opp;
        //OpportunityLineItem oppLineitem = new OpportunityLineItem(opportunity=opp,opportunityId=opp.id,Vista_Order_Number__c='12345', Quantity = 1, TotalPrice = 100);
       OpportunityLineItem oppLineitem = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, null, null);
        oppLineitem.Vista_Order_Number__c = '12345';
        
        insert oppLineitem;
        Test.startTest();
        OpportunityLineItem newoppLineitem = [SELECT Id, Vista_Order_Number__c, Opportunity.AccountId, 
                Opportunity.OwnerId,opportunity.stageName,opportunity.IsWon, asset__c,has_vin__c FROM OpportunityLineItem
                WHERE Vista_Order_Number__c = '12345' limit 1];
        system.debug('New Opp Line Item '+JSON.serializePretty(newoppLineitem));
        requestCollection.OpportunityLineItems.put('12345', newoppLineitem);
        
        requestCollection.orders.put('12345',new Order(Vista_Order_Number__c='12345',Last_Event__c='Cancelled'));
        requestCollection.PriceBookEntries = new Map<String, PriceBookEntry>();    
        
        Vista_OpportunityOrderCancelledLogic vocl = new Vista_OpportunityOrderCancelledLogic();
        Opportunity opFinal = vocl.setCancelledDateAndStageIfCancelled(oppLineItem, requestCollection);
        system.debug('Its NOW'+opFinal);           
     
        Test.stopTest();      
        

        system.assertEquals('Negotiation',opFinal.StageName );
      }            

    

}