public abstract class Vista_AssetBuilder_A { 
    private final Vista_AssetNonSpecSetter nonSpecSetter;
    private final Vista_AssetSpecSetter specSetter;
    
    public final String EventCode;
    public final String HANDOVER='Handover';
    public final String MISING_RETAILER_NEW_ASSET='Missing Retailer - New Asset';
    public final String MISING_RETAILER_EXISTING_ASSET='Missing Retailer - Existing Asset';
    public final String JAGUAR='jaguar';
    public final String LAND_ROVER='land rover';
    
    public Vista_AssetBuilder_A(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter)
    {
        this.nonSpecSetter = nonSpecSetter;
        this.specSetter = specSetter;
    }
    
    public void Build(Vista_RecordGroup request, Vista_RequestCollection requestCollection, Map<String, Sales_Person_CI_Code_Mapping__c> SalesCICodeMap)
    {
        Asset asset = requestCollection.Assets.get(request.VistaVehicleOrder.MetaOrderNumber);
        OpportunityLineItem opportunityLineItem = requestCollection.OpportunityLineItems.get(request.VistaVehicleOrder.MetaOrderNumber);
        Account retailer;
        Account migratedVehicleAcc;
        Order order = requestCollection.Orders.get(request.VistaVehicleOrder.MetaOrderNumber);
        String retailerCode;
        
        if(SalesCICodeMap == null) {
            SalesCICodeMap = new Map<String, Sales_Person_CI_Code_Mapping__c>();
        }
        
        if(String.IsNotEmpty(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID) && request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID.length() == 12)
            if(Dealer_Code_Override__c.getInstance(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID)!=null)
            retailerCode=Dealer_Code_Override__c.getInstance(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID).New_Dealer_Code__c;
        
        if(retailerCode!=null && retailerCode!='')
            retailer=requestCollection.Retailers.get(retailerCode);        
        else
            retailer=requestCollection.Retailers.get(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID);
        
        //if we cannot find the retailer we will assign the asset to the migrated vehicles account according the assets country code
        if(retailer==null && request.Request!=null && request.Request.Market__c!=null)
            migratedVehicleAcc=requestCollection.migratedVehicles.get(getCountryFromIsoCode(request.Request.Market__c)+' Migrated Vehicles');     
        
        if(asset == null) {
            system.debug('executing 0');
            asset = new Asset();
            requestCollection.Assets.put(request.VistaVehicleOrder.MetaOrderNumber, asset);
            
            asset.Name = request.VistaVehicleOrder.MetaOrderNumber;
            // CXPD-1715 >> MENA Vehicle Selection - Criteria for Assets to Display
            // asset.Status = System.label.Asset_CreatedStatus;
            asset.Status = System.label.Asset_ForSaleStatus;
            asset.Order_Number__c = request.VistaVehicleOrder.MetaOrderNumber;
            String brandFromReq;   
            
            if(request.Request.Brand__c!=null){
                if(VehicleSpecificationUtilities.brands.get(request.Request.Brand__c.toLowerCase())!=null)
                    asset.brand__c=VehicleSpecificationUtilities.brands.get(request.Request.Brand__c.toLowerCase()).id;
                else if(request.Request.Brand__c.equals('j') || request.Request.Brand__c.equals('J') || request.Request.Brand__c.equals('SAJ')|| request.Request.Brand__c.equals('saj'))
                    asset.brand__c=VehicleSpecificationUtilities.brands.get(JAGUAR).id;  
                else if(request.Request.Brand__c.equals('lr') || request.Request.Brand__c.equals('LR') || request.Request.Brand__c.equals('SAL') || request.Request.Brand__c.equals('sal'))
                    asset.brand__c=VehicleSpecificationUtilities.brands.get(LAND_ROVER).id;
            }
            
            if(migratedVehicleAcc!=null){
                request.request.Warning_Information__c= MISING_RETAILER_NEW_ASSET;
                update request.request;
            }
            else if(request.request.Warning_Information__c== MISING_RETAILER_NEW_ASSET)
                request.request.Warning_Information__c='';
            
            //this.specSetter.Set(asset, request, requestCollection);
            this.nonSpecSetter.Set(asset, request);
            
        }else if(migratedVehicleAcc!=null){
            request.request.Warning_Information__c= MISING_RETAILER_EXISTING_ASSET;
            update request.request;
        }else if(request.request.Warning_Information__c== MISING_RETAILER_EXISTING_ASSET)
            request.request.Warning_Information__c='';    
        
        this.specSetter.Set(asset, request, requestCollection);
        if(order != null) { asset.Order__c = order.Id; }
        
        if(request.VistaVehicleOrder.Vehicle != null) {
            if(String.isNotBlank(request.VistaVehicleOrder.Vehicle.VIN)) {
                asset.VIN__c = request.VistaVehicleOrder.Vehicle.VIN;
                asset.Name = request.VistaVehicleOrder.Vehicle.VIN;
            }
            SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Short_VIN__c, 
                                           request.VistaVehicleOrder.Vehicle.ShortVIN);
            SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Engine_Number__c, 
                                           request.VistaVehicleOrder.Vehicle.EngineNumber);
            SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Chassis_Number__c, 
                                           request.VistaVehicleOrder.Vehicle.ChassisNumber);
        }
        
        if(request.VistaVehicleOrder.Specification != null) {
            SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Description_Group_Id__c, 
                                           request.VistaVehicleOrder.Specification.DescriptionGroupId);
        }
        
        if(request.VistaVehicleOrder.Misc != null) {
            SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Vista_Status__c, 
                                           request.VistaVehicleOrder.Misc.CommonStatusPoint);
        }
        
        if(request.VistaVehicleOrder.Distribution != null && 
           request.VistaVehicleOrder.Distribution.DistributionChannel != null) {
               SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Sale_Type_Code__c, 
                                              request.VistaVehicleOrder.Distribution.DistributionChannel.BrandOrderType);
           }
        
        if(request.VistaVehicleOrder.Customer != null) {
            SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Common_Sale_Type__c, 
                                           request.VistaVehicleOrder.Customer.CommonTypeOfSale);
            system.debug('executing 2'+request.VistaVehicleOrder.Customer.CustomerHandoverDate);
            system.debug('executing 2'+asset.Original_Handover_Date__c);    
            system.debug('executing 2'+request.VistaVehicleOrder.Eventcode);
            if(request.VistaVehicleOrder.Customer.CustomerHandoverDate!=null && request.VistaVehicleOrder.Customer.CustomerHandoverDate!='')
                if(request.VistaVehicleOrder.Eventcode == 'HANDOVER' || (request.VistaVehicleOrder.Eventcode == 'CANHDOVER' && request.VistaVehicleOrder.Misc.CommonStatusPoint == 'Customer Handover')){
                    system.debug('executing 3');
                    
                    if (asset.Original_Handover_Date__c==null) {
                        object dateReg = SobjectUtilities.CastFieldData(request.VistaVehicleOrder.Customer.CustomerHandoverDate,Schema.sObjectType.Asset.fields.Original_Handover_Date__c);
                        asset.Original_Handover_Date__c=(Date)dateReg;
                    }
                    
                    if(request.VistaVehicleOrder.Contract.Salesman != null){
                        if(SalesCICodeMap.containsKey(request.Request.Market__c + request.VistaVehicleOrder.Contract.Salesman)) {
                            Sales_Person_CI_Code_Mapping__c salesPeronDetails = SalesCICodeMap.get(request.Request.Market__c+request.VistaVehicleOrder.Contract.Salesman);
                            asset.SalesPersonName__c = salesPeronDetails.Sales_Employee_Name__c;
                            asset.SalesPersonCode__c = salesPeronDetails.Name;
                            asset.Salesperson_Dealer_Code__c = salesPeronDetails.Jaguar_Code__c;
                            asset.Salesperson_Dealer_Code2__c = salesPeronDetails.LandRover_Code__c;
                            //asset.Initial_Sales_Person_Code__c = request.VistaVehicleOrder.Contract.Salesman ;
                        } else {
                            asset.SalesPersonCode__c=request.VistaVehicleOrder.Contract.Salesman; 
                        }
                    } 
                    
                    if(asset.Original_Handover_Date__c!=null){
                        asset.Warranty_Start_Date__c=asset.Original_Handover_Date__c;
                        if (asset.Product2.Warranty_Length__c > 0 ){
                        asset.Warranty_End_Date__c= asset.Original_Handover_Date__c.addMonths(Integer.valueof(asset.Product2.Warranty_Length__c)).addDays(-1);
                        } else {
                        asset.Warranty_End_Date__c= asset.Original_Handover_Date__c.addYears(3).addDays(-1);
                        }    
                    }        
                }                    
        }
        //CXPD-1775 Starts
        if(request.VistaVehicleOrder.Manufacture != null
           && request.VistaVehicleOrder.Manufacture.Scheduling != null
           && request.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate != null) {
                   asset.Current_Planned_Delivery_Date__c = Date.valueOf(request.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate);
           }
        
        if(request.VistaVehicleOrder.Contract != null){
            if(request.VistaVehicleOrder.Contract.ContractDate != null) {
                asset.Sold_Date_Vista__c = Date.valueOf(request.VistaVehicleOrder.Contract.ContractDate);
            } else if(request.VistaVehicleOrder.Contract.ContractDate == null) {
                asset.Sold_Date_Vista__c = null; 
            }
        }
        //CXPD-1775 Ends
        
        If(request.VistaVehicleOrder.Registration!=null) {
            if(request.VistaVehicleOrder.Registration.RegistrationDate!=null && request.VistaVehicleOrder.Registration.RegistrationDate!='' && asset.Vehicle_Initial_Registration_Date__c==null){
                object dateReg=  SobjectUtilities.CastFieldData(request.VistaVehicleOrder.Registration.RegistrationDate,Schema.sObjectType.Asset.fields.Vehicle_Initial_Registration_Date__c);
                asset.Vehicle_Initial_Registration_Date__c=(Date)dateReg;
            }
        }
        
        if(retailer != null && (asset.Account == null || asset.Account.RecordType == null || asset.Account.RecordType.DeveloperName == 'Retailer')) 
        {
            if(retailer.Record_Sub_Type__c == system.Label.Account_Sub_Type_Branded && String.isNotBlank(retailer.ParentId)) {
                asset.AccountId = retailer.ParentId;
            } else {
                asset.AccountId = retailer.Id;
            }
        }else if(migratedVehicleAcc!=null) {asset.accountId=migratedVehicleAcc.id;}
        
        if(opportunityLineItem != null && (opportunityLineItem.opportunity != null && (request.VistaVehicleOrder.EventCode==Vista_EventCodes.HANDOVER || request.VistaVehicleOrder.EventCode==Vista_EventCodes.SECONDHDOVER) || opportunityLineItem.opportunity.stageName==HANDOVER)) {
            asset.AccountId = opportunityLineItem.Opportunity.AccountId;
        }
        
        if(String.IsNotEmpty(request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID) &&
           request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID.length() == 12) {
               if(retailerCode!=null && retailerCode!='')
                   asset.Dealer_Code__c=retailerCode.substring(7);
               else
                   asset.Dealer_Code__c = request.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID.substring(7);
           }
        
        this.Build(asset, request, requestCollection); 
    }
    
    private String getCountryFromIsoCode(String isoCode){
        String countryName;
        for (aop_NationalityToISOCode__c  item : aop_NationalityToISOCode__c.getAll().values()) {
            countryName = item.aop_ISO_Code__c == isoCode ? item.name : countryName; //if(item.aop_ISO_Code__c  ==isoCode) {countryName=item.name;}
        }
        return countryName;
    }
    
    protected abstract void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection);
}