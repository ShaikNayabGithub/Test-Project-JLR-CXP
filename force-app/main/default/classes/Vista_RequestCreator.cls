public class Vista_RequestCreator {
     private final JSONSerializer serializer = new JSONSerializer();

    private static final String VehicleOrderFieldName = Vista_Request__c.Vehicle_Orders__c.getDescribe().getName();
    private Vista_OrderValidator validatorClass = new Vista_OrderValidator();


    public void CreateRequests(List<Vista_OrderService.ExportDetails> exportDetails)
    {
        List<Vista_Request__c> requests = new List<Vista_Request__c>();

        for(Vista_OrderService.ExportDetails exportDetail : exportDetails) {
            List<Vista_Request__c> exportRequests = new List<Vista_Request__c>();
            this.validatorClass.ValidateRequest(exportDetail);
            List<String> serializedOrders = this.serializer.Serialize(exportDetail.VehicleOrders, 131072);
            this.AddRequestFieldData(exportDetail, exportRequests, serializedOrders, VehicleOrderFieldName);

            requests.addAll(exportRequests);
        }
        
        insert requests;
    }

    //it serializes each order, gets them in a list, then for each order in the list creates a vista request with the JSON in the Vehicle_Orders__c field and the 
    //header info (market, brand etc) onto each request
    private void AddRequestFieldData(Vista_OrderService.ExportDetails exportDetail, List<Vista_Request__c> requests,  List<String> fieldData, String fieldName)
    {
        for(Integer i = 0; i < fieldData.Size(); i++){
            if(requests.Size() <= i) {            
                requests.Add(this.BuildRequest(exportDetail)); 
            }
            //requests[i].put(fieldName, fieldData[i]);
        }
    }

    private Vista_Request__c BuildRequest(Vista_OrderService.ExportDetails exportDetail)
    {
        Vista_Request__c request = new Vista_Request__c();

        //request.Name = String.valueOf(exportDetail.Serial);
        request.Market__c = exportDetail.Market;
        request.Market_Description__c = exportDetail.MarketDescription;
        request.Brand__c = exportDetail.Brand;
        request.Short_Brand__c = exportDetail.ShortBrand;
        request.Status__c = 'Unprocessed';
        
        if(exportDetail.VehicleOrders.size() > 0)
        {
            Vista_OrderService.VehicleOrder vehicleOrder = exportDetail.VehicleOrders[0];
            request.Eventcode__c = vehicleOrder.Eventcode;
            request.MetaOrderNumber__c = vehicleOrder.MetaOrderNumber;
            
            if(vehicleOrder.Vehicle != null){
                request.Vin__c = vehicleOrder.Vehicle.Vin;
            }
			  if(vehicleOrder.EventDateTime != null )               
            { 
             Vista_Date_Adapter vsa = new Vista_Date_Adapter(); 
             request.EventDateTime__C = (DateTime)vsa.Parse(vehicleOrder.EventDateTime); 
            }
            
            if(vehicleOrder.Misc != null){
                request.CommonStatusPoint__c = vehicleOrder.Misc.CommonStatusPoint;
            }
            
            if( vehicleOrder.Contract !=null && vehicleOrder.Contract.Salesman != null && vehicleOrder.Misc != null && (vehicleOrder.EventCode=='Handover' || vehicleOrder.EventCode=='CANHDOVER')){
                request.Salesman__c = vehicleOrder.Contract.Salesman;
            }
            
            if(vehicleOrder.Customer != null){
                request.CommonTypeOfSale__c = vehicleOrder.Customer.CommonTypeOfSale;
            }
            
            if(vehicleOrder.Specification != null){
                request.DescriptionGroupID__c = vehicleOrder.Specification.DescriptionGroupID;
            }
            
            system.debug(' @@@ 1'+vehicleOrder.Distribution);
            
            if(vehicleOrder.Distribution != null)
            {
                if(vehicleOrder.Distribution.NSC != null){
                    request.NSCOrderNumber__c = vehicleOrder.Distribution.NSC.NSCOrderNumber;
                }
                
                if(vehicleOrder.Distribution.DistributionChannel != null){
                    request.BrandOrderType__c = vehicleOrder.Distribution.DistributionChannel.BrandOrderType;
                    request.Original_PartnerUniqueID__c = vehicleOrder.Distribution.DistributionChannel.PartnerUniqueID;

                    Vista_DealerCodeSetter dealerCodeSetter = new Vista_DealerCodeSetter(new List<Vista_OrderService.ExportDetails>{exportDetail});
                    exportDetail = dealerCodeSetter.updateDealerCodes()[0];
                    request.PartnerUniqueID__c = vehicleOrder.Distribution.DistributionChannel.PartnerUniqueID;
                }
            }    
        }
        
        request.put(VehicleOrderFieldName, this.serializer.Serialize(exportDetail.VehicleOrders, 131072)[0]);
        

        return request;
    }
}