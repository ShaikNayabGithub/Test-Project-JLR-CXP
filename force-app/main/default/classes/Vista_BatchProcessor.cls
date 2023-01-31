public class Vista_BatchProcessor {
    private final Vista_EntityRetriever_I existingRecordRetriever;
    private final Vista_EnhancedDbActor_Handler enhancedDbHandler;
    private final Vista_OrderBuilder orderBuilder;
    private final Vista_AssetBuilder assetBuilder;
    private final Vista_OrderItemBuilder orderItemBuilder;
    
    public final static string RETAILER_LOST='Retailer Lost';
    public final static string STANDARD_PRICE_BOOK='Standard Price Book';
    
    public Vista_BatchProcessor(Vista_EntityRetriever_I existingRecordRetriever, 
        Vista_EnhancedDbActor_Handler enhancedDbHandler, Vista_OrderBuilder orderBuilder, 
        Vista_AssetBuilder assetBuilder, Vista_OrderItemBuilder orderItemBuilder)
    {
        this.existingRecordRetriever = existingRecordRetriever;
        this.enhancedDbHandler = enhancedDbHandler;
        this.orderBuilder = orderBuilder;
        this.assetBuilder = assetBuilder;
        this.orderItemBuilder = orderItemBuilder;
    }

    public void ProcessRequestCollection(Vista_RequestCollection requestCollection)
    {
        this.existingRecordRetriever.Retrieve(requestCollection);
        
        //populate migrated vehicles map, this will be used if an asset coming from vista doesnt have an account 
        requestCollection.migratedVehicles=populateMigratedVehiclesAccount(requestCollection.migratedVehicles);
        
        //make sure the products coming from vista exist/add the products to the local price book
        configureProducts(requestCollection);
        
        this.existingRecordRetriever.Retrieve(requestCollection);
        
        this.orderBuilder.Build(requestCollection);
        this.enhancedDbHandler.UpsertRecords(requestCollection.Orders, requestCollection);
        
        this.assetBuilder.build(requestCollection);
        this.enhancedDbHandler.UpsertRecords(requestCollection.Assets, requestCollection);
        
        this.orderItemBuilder.Build(requestCollection);
        this.enhancedDbHandler.DeleteRecords(requestCollection.OrderItemsForDelete, requestCollection);
        this.enhancedDbHandler.UpsertRecords(requestCollection.OrderItemsForInsert, requestCollection);
        
        //Update opportunity to handover when orders coming from VISTA have the status HANDOVER or CANHDOVER
        
        updateOpportunitiesWithCancelOroHandoverOrders(requestCollection);
        
    }
    
    public void configureProducts(Vista_RequestCollection requestCollection){
    
      List<String> productsCodeList= new List<String>();
      Map<String,String> modelsToExcludeMap= new Map<String,String>();
      
      String pplValue;
        Models_to_exclude_from_activation__mdt[] customMeta;
            
         customMeta= [select Model_Name__c,id from Models_to_exclude_from_activation__mdt];  
        
         if(customMeta!=null)
             if(!customMeta.isEmpty())
                 {
                 for(integer i=0;i<customMeta.size();i++)
                     modelsToExcludeMap.put(custommeta[i].model_name__c,custommeta[i].model_name__c);
                 
                 }
      
      Map<String,product2> mapProducts=new Map<String,product2>();
       //get a list of all the product codes
       if(requestCollection.RecordGroups!=null)
       {
           for(List<Vista_RecordGroup> recordGroupList : requestCollection.RecordGroups.values()) {
                for(Vista_RecordGroup recordGroup : recordGroupList) {
                     
                     if(recordGroup.VistaVehicleOrder.Specification!=null)
                         if(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId!=null)        
                             if(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId!='')
                                 productsCodeList.add(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId);
                }          
            }
          
          //check if the product exists in CXP, it may exist but it may not be in the local pricebook
          Map<String,PricebookEntry> mapStandardPb=new Map<String,Pricebookentry>();
          List<Product2> listProducts=[SELECT id,ProductCode,isactive,Model__r.ProductCode FROM Product2 where productCode IN: productsCodeList];
          //List to update products that are inactive now.
          List<Product2> productsToActivate=new List<Product2>();
      
          List<PricebookEntry> listStandardPb=[SELECT Id, ProductCode, Product2Id, CurrencyISOCode, PriceBook2.Name, UnitPrice 
                                               FROM PriceBookEntry
                                               WHERE  PriceBook2.Name=:STANDARD_PRICE_BOOK
                                               AND    Product2.ProductCode IN:productsCodeList
                                               AND    isactive=true
                                               ];
          
          if(!listStandardPb.isEmpty())
              {
               for(pricebookentry pb:liststandardpb)
                   mapStandardPb.put(pb.ProductCode+pb.CurrencyISOCode,pb);
              }
          
          //create map product code to product id
          if(listProducts!=null)          
              for(Product2 prod: listProducts){
              
                  //if the product is not active we activate it.
                  if(prod.isactive==false && !modelsToExcludeMap.containsKey(prod.Model__r.ProductCode)){
                      prod.isactive=true;
                      productsToActivate.add(prod);
                  }    
                                
                  mapProducts.put(prod.ProductCode,prod);
              }
              
          if(!productsToActivate.isEmpty())
              update productsToActivate;        
              
          Map<String,Product2> productsWithNoLocalPrice= new Map<String,Product2>();
          PriceBookEntry pbEntry;
          List<PriceBookEntry> priceBookEntries=new List<PriceBookEntry>();
          List<PriceBookEntry> standardPriceBookEntries=new List<PriceBookEntry>();
          Map<String,PriceBookEntry> mapPriceBookEntries= new Map<String,PriceBookEntry>();
          String priceBookName;
          
           for(List<Vista_RecordGroup> recordGroupList : requestCollection.RecordGroups.values()) {
                for(Vista_RecordGroup recordGroup : recordGroupList) {
                     
                     if(recordGroup.Request!=null)
                         if(recordGroup.Request.Market_Description__c!=null) 
                             if(requestCollection.PriceBookEntries!=null){
                                 priceBookName=Vista_PricebookEntryKeyBuilder.getPriceBookNameFromLabel(recordGroup.Request.Market_Description__c);
                                 pbEntry= requestCollection.PriceBookEntries.get(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId+'_'+priceBookName);
                                 if(pbEntry==null)
                                     pbEntry=mapPriceBookEntries.get(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId+'_'+priceBookName);
                                 
                             }    
                                 
                     if(pbEntry==null)
                         if(recordGroup.VistaVehicleOrder!=null)
                             if(recordGroup.VistaVehicleOrder.Specification!=null)
                                 if(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId!=null)
                                     if(mapProducts.containsKey(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId))
                                         if(recordGroup.Request.Market_Description__c!=null)
                                          {
                
                                              Id pricebookId=mapPriceBookNameToId.get(priceBookName);
                                              Id standardPbID=mapPriceBookNameToId.get(STANDARD_PRICE_BOOK);
                                              Id productId;
                                              Product2 prod;
                                              PricebookEntry standardPBE;
                                              PricebookEntry pbe; 
                                              
                                              productId=mapProducts.get(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId).Id;
                                              prod=mapProducts.get(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId);
                                              
                                              ///Map<String, AvokaFormMapping_Local__c> byMap = AvokaFormMapping_Local__c.getAll();
                                              Map<String, BRS_Market_Settings__c> byMap = BRS_Market_Settings__c.getAll();
                                              String currencyIsoCode;
                                              
                                              if(recordGroup.Request.Market__c!=null)
                                                  if(byMap.get(recordGroup.Request.Market__c)!=null)
                                                      currencyIsoCode=byMap.get(recordGroup.Request.Market__c).Currency__c;
                                             
                                              //if there is a pricebookentry in the related with the standard pricebook we dont create one
                                              if(mapStandardPb!=null && currencyIsoCode!=null)
                                                  if(mapStandardPb.get(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId+currencyIsoCode)==null)
                                                  {
                                                      standardPBE = new PricebookEntry(Pricebook2Id = standardPBId, Product2Id = productId, UnitPrice = 0, IsActive = true,UseStandardPrice=false,currencyISOcode=currencyIsoCode);
                                                      standardPriceBookEntries.add(standardPBE);
                                                  }    
                                              //We create a pricebook entry for the local market
                                              if(currencyIsoCode!=null)
                                              {

                                                  pbe = new PricebookEntry (Pricebook2Id=pricebookId, Product2Id=productId, IsActive=true, UnitPrice=0,UseStandardPrice=false,currencyISOcode=currencyIsoCode);   
                                                  priceBookEntries.add(pbe);                                             
                                                  mapPriceBookEntries.put(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId+'_'+priceBookName,pbe);
                                              }
                                     
                                          }                      
                    }          
           }
      
              if(!standardPriceBookEntries.isEmpty())
              {
                  try{
                      upsert standardPriceBookEntries;
                  
                  }
                  catch(Exception e){
                  
                  }
              
              }
                  
                  if(!priceBookEntries.isEmpty()){
                  
                  try{
                      upsert priceBookEntries;
                  
                  }
                  catch(Exception e){
                  
                      System.debug('exception inserting this product'+e+' values are: '+priceBookEntries);
                  
                  }
              
              
              }
                  
             
       }          
    }
    
     public static Map<String, id> mapPriceBookNameToId{ get {
        if(mapPriceBookNameToId== null) {
            mapPriceBookNameToId= new Map<String, id>();
            List<pricebook2> recordTypeList = [SELECT Id,Name FROM Pricebook2];
            for(pricebook2 recordType : recordTypeList)
            {
                mapPriceBookNameToId.put(recordType.name, recordType.id);
            }
        }
        return mapPriceBookNameToId;
    } private set; }
    
    public Map<String,Account> populateMigratedVehiclesAccount(Map<String,account> mapMigratedVehicles)        
    {
    
    if(mapMigratedVehicles==null)
        mapMigratedVehicles= new Map<String,Account>();
    else    
        return mapMigratedVehicles;
    //account record type retailer and account like migrated 
    List<Account> listAccounts=[
                                SELECT id,name,Record_Sub_Type__c,parentid FROM ACCOUNT
                                WHERE name like '%Migrated Vehicles' 
                                AND RecordTypeId =: SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id];

    for(Account acc:listAccounts)
        mapMigratedVehicles.put(acc.name,acc);
        
    return mapMigratedVehicles; 
    }

	
    public void updateOpportunitiesWithCancelOroHandoverOrders(Vista_RequestCollection  requestCollection){
        
        Map<String,Order> ordersMap=requestCollection.orders;
		Vista_OpportunityOrderCancelledLogic opplogic = new Vista_OpportunityOrderCancelledLogic();
        List<Opportunity> oppsToUpdate=new List<Opportunity>();
        Opportunity opp;
		Opportunity opp1;
        Order orderFromMap;
        List<OpportunityLineItem> oppItemsToUpdate=new List<OpportunityLineItem>();
        
     
        //create a map between opportunityid to order
        for(OpportunityLineItem oppItem: requestCollection.OpportunityLineItems.values())
        {
            //get list of request records for that vista order
            //order requests by createddate or eventdatetime
            //if latest is 
            
            if(oppItem.asset__c!=null){
                    
                   oppItem.has_vin__c=1;
                   oppItemsToUpdate.add(oppItem);
            }       
            
            //get order id from the oppLineItem and check if that order is handover from ther ordersMap
            if(ordersMap!=null)
                orderFromMap=ordersMap.get(oppItem.Vista_Order_Number__c);
           
            if(orderFromMap!=null)
            {
                opp=oppItem.opportunity;
                if(opp!=null)
                {
                    if(orderFromMap.Last_event__c==Vista_EventCodes.CANHDOVER){
                        
                        if(opp.StageName!=RETAILER_LOST)
                        {
                            opp.vista_cancel__c=true; //this will trigger a workflow to send an email to the opportunity owner informing the cancelation of the order and 
                            oppsToUpdate.add(opp);   //a task will be also created under the opportunity.
                        }                      
                    }
					
					opp1= opplogic.setCancelledDateAndStageIfCancelled(oppItem, requestCollection);
                    if(opp1 != null){
                        oppsToUpdate.add(opp1);
                    }
                }
            }
        }
    
      if(!oppItemsToUpdate.isEmpty())
          update oppItemsToUpdate;
      if(!oppsToUpdate.isEmpty())
          update oppsToUpdate;
    }
    
}