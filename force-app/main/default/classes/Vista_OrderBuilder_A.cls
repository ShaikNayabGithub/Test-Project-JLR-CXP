public abstract class Vista_OrderBuilder_A {
    public final String EventCode;

    private final Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
    Public final String MISSING_PRODUCT='Missing Product';
    public final String HANDOVEREVENT='HANDOVER';
    public final String REGISTRATIEVENT='REGISTRATI';
    public final String CANHDOVER='CANHDOVER';

     public void Build(Vista_RecordGroup request, Vista_RequestCollection requestCollection)
    {
        
        Order order = requestCollection.Orders.get(request.VistaVehicleOrder.MetaOrderNumber);
        OpportunityLineItem opportunityLineItem = requestCollection.OpportunityLineItems.get(request.VistaVehicleOrder.MetaOrderNumber);
        Account retailer;
        Account migratedVehicleAcc;
        
        //check if DescriptionGroupID is missing
        
        if(request.VistaVehicleOrder!=null)
        {    if(request.VistaVehicleOrder.Specification!=null)
                if(String.isBlank(request.VistaVehicleOrder.Specification.DescriptionGroupId))
                {
                     request.request.Missing_data__c=true;
                     request.request.Error_Log__c = request.request.Error_Log__c + '\n'+DateTime.now()+' Missing data: DescriptionGroupId';
                }
                
                if(String.isBlank(request.VistaVehicleOrder.MetaOrderNumber))
                {
                    request.request.Missing_data__c=true;
                    request.request.Error_Log__c = request.request.Error_Log__c + '\n'+DateTime.now()+' Missing data: MetaOrderNumber';
                
                }
                
                if(request.VistaVehicleOrder.Registration!=null &&( request.VistaVehicleOrder.Eventcode == HANDOVEREVENT || request.VistaVehicleOrder.Eventcode == REGISTRATIEVENT))
                
                
                     if(String.isBlank(request.VistaVehicleOrder.Registration.RegistrationDate) || request.VistaVehicleOrder.Registration.RegistrationDate==null ) {
                     
                        request.request.Missing_data__c=true;
                        request.request.Error_Log__c = request.request.Error_Log__c + '\n'+DateTime.now()+' Missing data: Registration Date';
                         
                     }
                     
                if(request.VistaVehicleOrder.Customer!=null &&( request.VistaVehicleOrder.Eventcode == HANDOVEREVENT || request.VistaVehicleOrder.Eventcode == REGISTRATIEVENT || request.VistaVehicleOrder.Eventcode == CANHDOVER))
                    if(String.isBlank(request.VistaVehicleOrder.Customer.CustomerHandoverDate))
                    {
                    
                        request.request.Missing_data__c=true;
                        request.request.Error_Log__c = request.request.Error_Log__c + '\n'+DateTime.now()+' Missing data: CustomerHandoverDate';
                    
                    }    
                     
                if(request.VistaVehicleOrder.Distribution!=null)
                    if(request.VistaVehicleOrder.Distribution.DistributionChannel!=null)
                        if(String.isBlank(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID))
                        {
                            request.request.Missing_data__c=true;
                            request.request.Error_Log__c = request.request.Error_Log__c + '\n'+DateTime.now()+' Missing data: PartnerUniqueID';
                        }
                        
         }   
        
        String pbeKey = Vista_PricebookEntryKeyBuilder.Build(request.VistaVehicleOrder.Specification.DescriptionGroupId, 
                request.Request.Market_Description__c);
        PricebookEntry pricebookEntry = requestCollection.PriceBookEntries.get(pbeKey);
        String retailerCode;
        
        if(String.IsNotEmpty(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID) && request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID.length() == 12)
            if(Dealer_Code_Override__c.getInstance(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID)!=null)
                retailerCode=Dealer_Code_Override__c.getInstance(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID).New_Dealer_Code__c;
        
        if(retailerCode!=null && retailerCode!='')
            retailer=requestCollection.Retailers.get(retailerCode);        
        else
            retailer=requestCollection.Retailers.get(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID);
            
        //if we cannot find the retailer we will assign the asset to the migrated vehicles account according the assets country code
         if(retailer==null)
            if(request.Request!=null)
                if(request.Request.Market__c!=null)
                    migratedVehicleAcc=requestCollection.migratedVehicles.get(getCountryFromIsoCode(request.Request.Market__c)+' Migrated Vehicles');
                    
        if(order == null) {
            order = new Order();
            requestCollection.Orders.put(request.VistaVehicleOrder.MetaOrderNumber, order);

            order.Vista_Order_Number__c = request.VistaVehicleOrder.MetaOrderNumber;
            order.Status = System.label.Order_DraftStatus;
            order.EffectiveDate = this.dateAdapter.Parse(request.VistaVehicleOrder.EventDateTime);
           
            if(opportunityLineItem != null) {
                order.Status = System.label.Order_ActivatedStatus;
                order.OpportunityId = opportunityLineItem.Opportunity.Id;
                order.OwnerId = opportunityLineItem.Opportunity.OwnerId;
            }
         
        }
       
         if(pricebookEntry != null) {
          
                if ((order.has_products__c!=null && order.has_products__c==0) || order.has_products__c==null  )
                    if((order.Pricebook2Id==null && order.CurrencyIsoCode==null) || pricebookEntry.CurrencyIsoCode!=order.CurrencyIsoCode)
                {
                    order.Pricebook2Id = pricebookEntry.Pricebook2Id;
                    order.CurrencyIsoCode = pricebookEntry.CurrencyIsoCode;
                }
                
         if(request.request.Warning_Information__c==MISSING_PRODUCT)
             request.request.Warning_Information__c='';       
         }
         else{
         
         Map<String, BRS_Market_Settings__c> byMap = BRS_Market_Settings__c.getAll();
         String currencyIsoCode;
         
         if(request.Request.Market__c!=null)
             if(byMap.get(request.Request.Market__c)!=null)
                 if(byMap.get(request.Request.Market__c).Currency__c!=null)
                     currencyIsoCode=byMap.get(request.Request.Market__c).Currency__c;
                     
             if (order.Pricebook2Id==null && order.CurrencyIsoCode==null)
             {
                 String pricebookName= Vista_PricebookEntryKeyBuilder.getPriceBookNameFromLabel(request.Request.Market_Description__c);
                 order.Pricebook2Id = Vista_BatchProcessor.mapPriceBookNameToId.get(pricebookName);
                 order.CurrencyIsoCode = currencyIsoCode;
             }
             
             request.request.Warning_Information__c= 'Missing Product';     
         }
         
         if(retailer != null && (order.Account == null || order.Account.RecordType == null || 
                order.Account.RecordType.DeveloperName == 'Retailer')) {
            if(retailer.Record_Sub_Type__c == system.Label.Account_Sub_Type_Branded && 
                    String.isNotBlank(retailer.ParentId)) {
                order.AccountId = retailer.ParentId;
            } else {
                order.AccountId = retailer.Id;
            }
        }
         else
        if(migratedVehicleAcc!=null)
            order.accountId=migratedVehicleAcc.id;
       
        if(opportunityLineItem != null) {
            order.AccountId = opportunityLineItem.Opportunity.AccountId;
        }
        
        
        //check if there is some missing data in the request
             
        if(request.VistaVehicleOrder!=null)
            if(String.isBlank(request.VistaVehicleOrder.EventCode))
                 request.request.Missing_data__c=true;
                 
            if(request.VistaVehicleOrder.Misc != null) {
                 
                 if(String.isBlank(request.VistaVehicleOrder.Misc.CommonStatusPoint)){
                     request.request.Missing_data__c=true;
                     request.request.Error_Log__c = request.request.Error_Log__c + '\n'+DateTime.now()+' Missing data: CommonStatusPoint';
                     
                 }                 
             }     
            
            order.Last_Event__c = request.VistaVehicleOrder.EventCode;
            order.Last_Event_Date__c = Date.today();
            
        this.Build(order, request);
        
    }

 public String getCountryFromIsoCode(String isoCode){
    String countryName;
    for (aop_NationalityToISOCode__c  item : aop_NationalityToISOCode__c.getAll().values()) {
        if(item.aop_ISO_Code__c  ==isoCode)
            countryName=item.name;
    }

    return countryName;
 }

    protected abstract void Build(Order order, Vista_RecordGroup request);
}