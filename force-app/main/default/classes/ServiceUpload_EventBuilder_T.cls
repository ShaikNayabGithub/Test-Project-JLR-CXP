@isTest
public class ServiceUpload_EventBuilder_T {
    static testMethod void Build_ServiceDataAndServiceDataItem_GivenAsset()
    {
        ServiceUpload_EventBuilder eventBuilder = new ServiceUpload_EventBuilder();
        Map<Integer,asset> mapIntToAsset= new Map<Integer,asset>();
        
        Asset asset1= TestClass_AssetBuilder.buildvehicle();
        insert asset1;
        
        mapIntToAsset.put(1,asset1);
        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        recordcollection.AssetsByRowId=mapIntToAsset;
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();
        Map<String,service_data__c> mapStringToService=new Map<String,service_Data__c>();
        
        //mapStringToService.put('074343',new Service_data__c());

        Integer rowIndex1 = 1;
        String initialStatus = 'start status';

        Service_Data__c service= new Service_Data__c();
       // recordCollection.ServiceByRowId.put(rowIndex1, service);
        recordCollection.isFileUploadService=true;
        String headers='Address1,Address2,Post Code,Country,Email,Phone,First Name,Last Name ,VIN,Registration Number,Service Repair Date,DMS Invoice Ref ID,Repairing Retailer Name,Dealer Code JLR,Brand,Model,Repair Order Number,SR Type,Description,Mileage,Mileage Date,Job Booked Date,Mileage UOM,Remarks';
        String test1='The White House,17 Uppingham Rd,LE4 6HG,Uk,dddddddd111@11test.com,33445544433,newaccount13131,newaccount273lastname,VIN93893334344343,rn4444433334,5/12/18 10:24,ABC123,JLR Kohoku - 50141 - 13859,50141,Jaguar,XE,4343333333,Warranty,Front Brake Pads replaced,600000,1/2/18,2/2/18 10:29,Miles,front break left';
       
        
        List<String> listString= new List<String>();
        liststring.add(headers);
        List<String> listStringValues= new List<String>();
        liststringvalues.add(test1);
        Map<Integer, List<String>> LinesByRowIndex=new  Map<Integer, List<String>>();
        LinesByRowIndex.put(1,liststring);
        LinesByRowIndex.put(2,liststringvalues);
        Map<String, Integer> ColumnIndexesByFieldName= new Map<String, Integer>();
        
        
      //  ColumnIndexesByFieldName.put('VIN',0);
      //  ColumnIndexesByFieldName.put('Phone',1);
        
        CSVUpload_DataCollection csvdatacollection = new CSVUpload_DataCollection ();
        recordCollection.csvdatacollection=  csvdatacollection ;
        recordCollection.csvdatacollection.linesbyrowindex=LinesByRowIndex;
        recordCollection.csvdatacollection.ColumnIndexesByFieldName =ColumnIndexesByFieldName ;
        
        Account account= new  account();
        account.phone='074343';
        account.lastname='testfdfsd';
        insert account;
        
        Sobject sobj;
        
        sobj=eventBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),mapStringToService);
       
        //sobj=eventbuilder.returnServiceDataObject(new service_data__c(),account.id,asset1,'34343',1,recordCollection,'description','remarks');
       // System.AssertNotEquals(sobj, null);
        
        sobj=eventbuilder.returnServiceDataObject(null,account.id,asset1,'34343',1,recordCollection,'description','remarks');
        System.AssertNotEquals(sobj, null);
    }

   
}