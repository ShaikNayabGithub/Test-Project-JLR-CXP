public class FinanceUpload_AssetBuilder implements FinanceUpload_SObjectBuilder_I {
    public Asset Build(Integer csvRowIndex, FinanceUpload_RecordCollection recordCollection,Map<String,Id>mapIdAccountToIdUser,Map<String,Account>mapStringtoAccount,Map<String,Service_Data__c> mapStringToService)
    {
        List<String> rowData = recordCollection.CSVDataCollection.LinesByRowIndex.get(csvRowIndex);
        boolean assetFromDB=false;
        String mileageUom= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Mileage UOM', rowData));
        String phone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Phone', rowData));
        String email= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Email', rowData));      
        String customerId= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Customer ID', rowData));
        String mobilePhone;
        
         //for the service uploader
        if (phone==null || String.isBlank(phone))
            phone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Home Phone', rowData));
        else 
        if (phone==null || String.isBlank(phone))    
            phone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Business Phone', rowData));
            
        mobilePhone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Mobile Number', rowData)); 
  
        String vin = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection, 
                FinanceUpload_Constants.VIN_COLUMN_HEADER, rowData);
        String registration = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,  
                FinanceUpload_Constants.REGISTRATION_COLUMN_HEADER, rowData);
        String mileageString=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Mileage', rowData);
        String serviceRepairDate=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Service Repair Date', rowData);
        String motDate=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'MOT Date', rowData);
        String srvType=CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'SR Type', rowData);
        Integer mileageFromFile;
        DateTime servRepairDate;
        DateTime motDatetime;
        Date datepa;
        Datetime dt;
        
        String SERVICE='Service'; 
        String SERVICE1='1st Service'; 
        String SERVICE2='2nd Service';
        String SERVICE3='3rd Service';
        String SERVICE4='4th Service';
        String SERVICE5='5th Service';
               
        if(mileageString!=null && mileageString.isNumeric())
            mileageFromFile=Integer.valueOf(mileageString);   
            
       if(serviceRepairDate !=null && !String.isBlank(serviceRepairDate))
       {
            if(Pattern.matches('[0-9]{2}-[A-z]{3}-[0-9]{2}', serviceRepairDate) && serviceRepairDate!=null){
            
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
            if(serviceRepairDate!=null)
            {
                servRepairDate= DateTime.parse(serviceRepairDate);
            }    
       }     
                              
        if(String.isEmpty(vin) && String.isEmpty(registration)) return null;
        
        Asset asset = recordCollection.AssetsByRowId.get(csvRowIndex);
        
         //Finance Uploader 1.2
         if(asset==null)
            return null;
       
        else
        assetFromDB=true;

        if(asset.vin__c.equalsIgnoreCase(vin) && assetFromDB==true && String.isBlank(asset.Registration_Number__c) && !String.isBlank(registration)){  //if the asset comes from the db and it has not reg number we update the asset with values from the csv file.
          
            asset.registration_number__c=registration;
        }
        
        if((assetFromDB==true && asset.Mileage__c <mileageFromFile) || (asset.Mileage__c==null && mileageFromFile>0) ){  //if the asset comes from the db and it has not reg number we update the asset with values from the csv file.
          
           asset.Mileage__c=mileageFromFile;
        }
        
        if(assetFromDB==true && servRepairDate!=null && ((srvType.equalsIgnoreCase(SERVICE)) || (srvType.equalsIgnoreCase(SERVICE1)) || (srvType.equalsIgnoreCase(SERVICE2)) || (srvType.equalsIgnoreCase(SERVICE3)) || (srvType.equalsIgnoreCase(SERVICE4)) || (srvType.equalsIgnoreCase(SERVICE5))))// updates last service date of the asset
        {
          
            asset.Vehicle_Last_Service_Date__c= Date.newinstance(servRepairDate.year(), servRepairDate.month(), servRepairDate.day());
          
        }
        else
        if(assetFromDB==true && servRepairDate!=null && ( (srvType!=SERVICE1) && (srvType!=SERVICE2) && (srvType!=SERVICE3) && (srvType!=SERVICE4) && (srvType!=SERVICE5)))//update last repaired date of the asset
        {
            
            asset.Last_Repaired_Date__c= Date.newinstance(servRepairDate.year(), servRepairDate.month(), servRepairDate.day());
          
        }      
        
        if(asset!=null && asset.vin__c.equalsIgnoreCase(vin))
          {
       
            recordCollection.AssetsByRowId.put(csvRowIndex, asset);
            return asset;
          
          }
        else
        return null;          
    }
}