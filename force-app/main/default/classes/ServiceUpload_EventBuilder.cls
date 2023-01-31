public class ServiceUpload_EventBuilder implements FinanceUpload_SObjectBuilder_I{

    public final STRING SR_TYPE='SR Type';
    public final STRING PRICE_TOTAL='Price (Total)';
    public final STRING REPAIR='repair';
    public final STRING PRICE_PARTS='Price (Parts)';
    public final STRING PRICE_LABOUR='Price (Labour)';
    public final STRING MILEAGE_UOM='Mileage UOM';
    public final STRING SERVICE_REPAIR_DATE='Service Repair Date';
 
    private  String srType;
    Decimal priceParts;
    String pricePartsSt;
    String priceTotal;
    Decimal priceTotalDec;
    Decimal priceLabour;
    String priceLabourSt;
    String uom;
    String serviceRepairDate;
    String message;
    String vin;
   
    public Sobject Build(Integer csvRowIndex, FinanceUpload_RecordCollection recordCollection,Map<String,Id>mapIdAccountToIdUser,Map<String,account>mapStringtoAccount,Map<String,Service_Data__c> mapStringToService)
    {
        final String SERVICE_APPOINTMENT='Service Appointment';
        Account account;
        String brandName;
        boolean assetFromDB=false;
        Service_Data__c serviceData;
        Id serviceDataId;
        Service_Data_Item__c serviceDataItem;
        boolean repairOrderExists;
        Id accountid;
        
        List<String> rowData;
        String phone;
        String registration;
        String repairOrder;
        String description;
        String remarks;
        String mobilePhone;
        String email;
       
          if(recordCollection!=null)
            if(recordCollection.CSVDataCollection!=null)
                if(recordCollection.CSVDataCollection.LinesByRowIndex!=null)
                {
        
                 rowData = recordCollection.CSVDataCollection.LinesByRowIndex.get(csvRowIndex);
                 phone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Phone', rowData));
                
                 if(phone==null || String.isblank(phone))
                     phone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Home Phone', rowData));
                        
                 if(phone==null || String.isblank(phone))
                     phone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Business Phone', rowData));
                        
                 mobilePhone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Mobile Number', rowData));  
                 
                 email= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Email', rowData));   
                    
                 vin = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection, 
                 FinanceUpload_Constants.VIN_COLUMN_HEADER, rowData);
                 registration = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                 FinanceUpload_Constants.REGISTRATION_COLUMN_HEADER, rowData);       
                 repairOrder=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                 'Repair Order Number', rowData);
                 serviceRepairDate=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                 'Service Repair Date', rowData);
    
                 if(String.isBlank(repairOrder)){
                     repairOrder=(vin+serviceRepairDate);
                     repairOrder=repairorder.replaceAll( '\\s+', '');
                 }    
                 
                 description=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                 'Description', rowData);
                 remarks=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                 'Remarks', rowData);
                
                }
                
        if(String.isEmpty(vin) && String.isEmpty(registration)) return null;
            
        Asset asset = recordCollection.AssetsByRowId.get(csvRowIndex);
        account=recordCollection.AccountsByRowId.get(csvRowIndex);
        
        if(account==null)
            account=FinanceUpload_Processor.mapPhoneToIdAccount.get(phone);
        
        if(account==null)
            account=FinanceUpload_Processor.mapPhoneToIdAccount.get(email); 
            
        if(account==null)
            account=FinanceUpload_Processor.mapPhoneToIdAccount.get(mobilePhone); 
            
       if(account!=null)
           accountId=account.id;         
      
       if(repairOrder!=null && !String.isBlank(repairOrder))
           serviceData = mapStringToService.get(repairOrder);
            
           return returnServiceDataObject(serviceData ,accountId,asset,repairOrder,csvrowindex,recordCollection,description,remarks);
        
    }
    
    public sobject returnServiceDataObject(Service_data__c serviceData,Id accountid,Asset asset,String repairOrder,Integer csvRowIndex,FinanceUpload_RecordCollection recordCollection,String description,String remarks){
    
    Service_Data_Item__c serviceDataItem;
    DateTime servRepairDate;
    List<String> rowData;
    rowData = recordCollection.CSVDataCollection.LinesByRowIndex.get(csvRowIndex);
    srType=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,SR_TYPE, rowData);
    pricePartsSt =CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                 PRICE_PARTS, rowData);
    priceLabourSt =CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                PRICE_LABOUR, rowData);
    priceTotal =CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                PRICE_TOTAL, rowData);
    uom=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                MILEAGE_UOM, rowData);
    serviceRepairDate=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                SERVICE_REPAIR_DATE, rowData);
                
     if(!String.isBlank(serviceRepairDate))
     {           
          if(Pattern.matches('[0-9]{2}-[A-z]{3}-[0-9]{2}', serviceRepairDate) ){
    
                servRepairDate= SobjectUtilities.returnCorrectDateFormat(serviceRepairDate);
                
            }
            else
            if(Pattern.matches('[0-9]{2}/[0-9]{2}/[0-9]{4}',serviceRepairDate))
            {
                String day =   serviceRepairDate.split('/')[0];
                String month = serviceRepairDate.split('/')[1];
                String year =  serviceRepairDate.split('/')[2];

                servRepairDate=Date.parse(day+'/'+month+'/'+year); 

            }
            else
            {
                servRepairDate= DateTime.parse(serviceRepairDate);
            }          
     }
     else
     if(String.isBlank(serviceRepairDate))
         message='No service date provided';  

     
     if(recordCollection.isServiceItem==null && serviceData==null)
        {
                   
           serviceData=new Service_Data__c ();
           serviceData.account__c=accountId;
           if(asset!=null)
               serviceData.asset__c=asset.id;
               
           serviceData.Service_Status__c='Completed';
           serviceData.Unique_Repair_Order_Number__c=repairOrder;
           serviceData.Service_Source__c='Service Upload';
           
           if(uom!=null){
                if(uom.toLowerCase()=='kms' || uom.toLowerCase()=='km' || uom.toLowerCase()=='kilometers' || uom.toLowerCase()=='k')
                   serviceData.Units_Mileage_Out__c='Kilometers';
               else
               if(uom.toLowerCase()=='miles' || uom.toLowerCase()=='mile' ||  uom.toLowerCase()=='m')  
                   serviceData.Units_Mileage_Out__c='Miles';
            }
                
            serviceData.Mileage_Date__c=servRepairDate;
            serviceData.Service_Repair_Date__c=servRepairDate;
            
            if(!String.isBlank(message)){
                serviceData.message__c=message;
                serviceData.asset__c=null;   
            }    
            
                recordCollection.ServiceByRowId.put(csvRowIndex, serviceData);
                return serviceData;
            
        }
        
        else
      if(serviceData!=null && servicedata.asset__r.name!=vin){
          
          serviceData=new service_Data__c();
          servicedata.asset__c=null;
          serviceData.message__c='Service record already exists on another asset';    
            recordCollection.ServiceByRowId.put(csvRowIndex, serviceData);
          return serviceData;
      }
      else       
        if(recordCollection.isServiceItem==true && serviceData!=null && recordCollection.repairOrdersToProcess.contains(repairOrder))
        {
            serviceDataItem= new Service_Data_Item__c();
            serviceDataItem.serviceData__C=serviceData.id;
            serviceDataItem.Unique_Repair_Order_Number__c=repairOrder;
            serviceDataItem.description__c=description+' '+remarks;
            serviceDataItem.Mileage_Date__c=servRepairDate;
            
            if(pricePartsSt!=null)
            {  
                if(!String.isBlank(pricePartsSt))
                    priceParts=Decimal.valueOf(pricePartsSt);
                    
                serviceDataItem.Price_Parts__c=priceParts;
                
            }
            if(priceLabourSt!=null)
            {
                if(!String.isBlank(priceLabourST) && priceLabourST.isNumeric())
                    priceLabour=Decimal.valueOf(priceLabourST);
                    
                serviceDataItem.Price_Labour__c=priceLabour;
            
            }
            
            if(serviceDataItem.Price_Labour__c==null)
                serviceDataItem.Price_Labour__c=0;
                
             if(serviceDataItem.Price_Parts__c==null)
                    serviceDataItem.Price_Parts__c=0;       
            
            if(priceTotal!=null)
            {
                if(!String.isBlank(priceTotal) && priceTotal.isNumeric())
                    serviceDataItem.price_total__c=Decimal.valueOf(priceTotal);
            }
            
            if(serviceDataItem.price_total__c==null ||serviceDataItem.price_total__c==0)
            {
                serviceDataItem.price_total__c=serviceDataItem.Price_Labour__c+serviceDataItem.Price_Parts__c;
            }
            serviceDataItem.Service_Type__c=srType; 
            
            If(servRepairDate!=null)
            {
                recordCollection.ServiceDataItemsByRowId.put(csvrowindex,serviceDataItem); 
                return serviceDataItem;
            }
            else
            return null;
        }
        else{
           serviceData.Service_Repair_Date__c=servRepairDate;
           return serviceData;
        
        } 
    }
   
}