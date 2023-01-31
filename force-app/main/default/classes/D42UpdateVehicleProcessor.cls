public class D42UpdateVehicleProcessor{
    
    public final String JAGUAR='jaguar';
    public final String LAND_ROVER='land rover';
    
    public D42_UpdateVehicle.Response process(D42_UpdateVehicle.exportDetails vehicleInfo){
        
        Integration_Log__c log=new Integration_log__c();
        D42_UpdateVehicle.Response response=new D42_UpdateVehicle.response();
        Asset asset;
        string statuspoint;
        String vin;
        String orderNumber;
        boolean duplicateSystemAssets = false;
        
        D42_UpdateVehicle.exportDetails vehicleInfotest=vehicleInfo;
        
        log.service__c='D42 Integration';
        log.request__c=String.valueof(vehicleInfo);
        if(vehicleInfo.VehicleOrders!=null)
            if(vehicleInfo.VehicleOrders[0].Vehicle!=null)
            vin=vehicleInfo.VehicleOrders[0].Vehicle.VIN;
        
        try{
            if(!String.isBlank(vin) || !String.isBlank(vehicleInfo.VehicleOrders[0].MetaOrderNumber) ){ 
                orderNumber=vehicleInfo.VehicleOrders[0].MetaOrderNumber;
                List<Asset> assetList =findAssetFromVinorOrderNumber(Vin,orderNumber);
               
                If(assetList != null && !assetList.isEmpty() && assetList.size() == 1){
                    asset = assetList[0];
                }
                if(assetList != null && !assetList.isEmpty() && assetList.size()>1){
                    duplicateSystemAssets = true;                    
                }
                
                
                System.debug('asset '+asset);
                
                System.debug('orderNumber '+orderNumber);
                if(asset==null && orderNumber!=null && !duplicateSystemAssets)
                    asset=createAsset(vin,orderNumber);
                
                if(asset!=null)
                {
                    if(asset.Order_Number__c == null && !String.isEmpty(orderNumber) ){
                        asset.Order_Number__c = orderNumber;
                    }
                    if(asset.Vin__c == null && !String.isEmpty(vin) ){
                        asset.Vin__c = vin;
                    }
                    if((String.isNotEmpty(orderNumber) && asset.Order_Number__c != orderNumber) || (String.isNotEmpty(vin) && asset.VIN__c != vin )){
                                       
                                       aop_AOPException mismatchException= new aop_AOPException();
                                       mismatchException.setMessage('Asset has Vin: '+asset.Vin__c +'and Order:'+asset.Order_Number__c+' does not match Requests');
                                       throw mismatchException;
                                       
                     }
                   statusPoint=vehicleInfo.VehicleOrders[0].Misc.CommonOrderType;
                    if(statusPoint != null){
                        updateStatusPoint(statusPoint,asset,vehicleInfo.VehicleOrders[0].EventDateTime); 
                    }
                    log.status__c='Success';
                    update asset;
                }
                else{
                    if(duplicateSystemAssets){
                        log.status__c='Error';
                        log.system_error__c='Duplicate Assets Found';
                        response.ResponseMessage='Error';
                        
                    }else{
                        log.status__c='Error';
                        log.system_error__c='No opportunity found';
                        response.ResponseMessage='Error'; 
                    }
                    
                }
            }   
            else 
            {
                log.status__c='Error';
                log.System_Error__c='No VIN';
                response.ResponseMessage='Error';
            }
            
        }
        catch(Exception e){
            response.ResponseMessage='Error';
             log.System_Error__c=e.getMessage();
            log.status__c='Error';
            
        }   
        Finally{
            insert log;
        }
        
        return response;   
    }
    
    private List<Asset> findAssetFromVinorOrderNumber(string vin, string orderNumber){
        
        list<Asset> Listasset;
        System.debug('findAssetFromVinorOrderNumber '+vin+orderNumber);
        
        if(!String.isBlank(vin) && String.isBlank(orderNumber))
            listasset= [select id,vin__c,Order_Number__c,vista_status__c,Into_Port_of_Entry_Date__c,Arrived_at_Dealer_Date__c,stockage__c from asset where vin__c=:vin ];
        
        if(!String.isBlank(vin) && !String.isBlank(orderNumber))
            listasset= [select id,vin__c,Order_Number__c,vista_status__c,Into_Port_of_Entry_Date__c,Arrived_at_Dealer_Date__c,stockage__c from asset where vin__c=:vin or order_number__c=:orderNumber];
        
        if(String.isBlank(vin) && !String.isBlank(orderNumber))
            listasset= [select id,vin__c,Order_Number__c,vista_status__c,Into_Port_of_Entry_Date__c,Arrived_at_Dealer_Date__c,stockage__c from asset where order_number__c=:orderNumber];
        
         System.debug('findAssetFromVinorOrderNumber lsit isEmpty '+listasset.isEmpty());
        if(!listasset.isempty())
            return  listasset;
        else
            return null;
        
    }
    
    public asset createAsset(String vin,string orderNumber)
    {
        System.debug('Entered CreateAsset');
        asset asset;        
        account acc;
        Id oppid;
        list<opportunityLineItem> listOppItem;
        Opportunity opp;
        id retailerid;
        account retailer;
        list<user> listusers;
        list<opportunity> listopp;
        
        listOppItem=[select id,opportunityid,product2.Make__c,product2.Model__c, opportunity.owner.accountId from OpportunityLineItem where Vista_Order_Number__c=:orderNumber];
        system.debug('LIST OF OPPLINES '+JSON.serializePretty(listOppItem));
        if(!listOppItem.isEmpty()){
            if(listOppItem[0].opportunity.Owner.accountId != null){
                asset=new asset();                
                asset.name=vin;
                asset.vin__c=vin;
                asset.accountid=listOppItem[0].opportunity.Owner.accountId;
                asset.new_or_used__c='New';
                if(listOppItem[0].product2.Make__c != null){
                    asset.brand__c=listOppItem[0].product2.Make__c;
                }else{
                    asset.brand__c=getbrandFromVin(vin);
                }
                if(listOppItem[0].product2.Model__c != null){
                    asset.Model__c=listOppItem[0].product2.Model__c;
                }
                
                asset.order_number__c=ordernumber;
                system.debug('ASSET '+JSON.serializePretty(asset));
                insert asset;   
                OpportunityLineItem oppline = new OpportunityLineItem();
                oppline.Id = listOppItem[0].Id;
                oppline.Asset__c = asset.id;
                update oppline;
                
            }  
            
            
            
        }
        
        return asset;
        
    }
    
    private id getBrandFromVin(string vin){
        
        id brandId;
        
        if(vin.substring(0,3)=='SAL')
            brandId=VehicleSpecificationUtilities.brands.get(LAND_ROVER).id;
        else
            if(vin.substring(0,3)=='SAJ')
            brandId=VehicleSpecificationUtilities.brands.get(JAGUAR).id;        
        
        return brandId;          
        
    }
    
    @testvisible
    private void updateStatusPoint(String statusPoint,asset asset,String eventDate){
        
        integer stockage;
        date today;
        CommonStatusPointValues__mdt[] values=[select cxpvalue__c,SVCRMvalue__c from CommonStatusPointValues__mdt where SVCRMvalue__c like:statusPoint];
        
        if(!values.isEmpty()){
            asset.vista_status__c=values[0].cxpvalue__c;
        }     
        
        if(statusPoint=='155'){
            
            String time1=eventDate;
            String time2=time1.SubStringBefore('T');
            Date data1;
            
            data1=date.valueof(time2);  
            asset.Into_Port_of_Entry_Date__c=data1;    
            
            if(asset.stockage__c==null){
                today= system.today();
                stockage=Math.abs(today.daysBetween(asset.Into_Port_of_Entry_Date__c));
                asset.stockage__c=stockage;  
            }              
            
        }
        /*else
            if(statusPoint=='165'){
                
                String time1=eventDate;
                String time2=time1.SubStringBefore('T');
                Date data1;
                data1=date.valueof(time2);        
                
        if(asset.Arrived_at_Dealer_Date__c==null)
                    asset.Arrived_at_Dealer_Date__c=data1;    
                
                if(asset.stockage__c==null){
                    
                    today= system.today();
                    stockage=Math.abs(today.daysBetween(asset.Arrived_at_Dealer_Date__c));
                    asset.stockage__c=stockage;  
                }
                
            }*/
        
        update asset;
    }
    
}