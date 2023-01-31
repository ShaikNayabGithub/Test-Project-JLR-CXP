@isTest
public class ServiceUpload_Processor_T {
    static testMethod void testServiceUpload_Processor()
  {

        ServiceUpload_Processor_F processorFactory = new ServiceUpload_Processor_F();
        CSVUpload_DataCollection_FF dataCollectionFactoryFactory = new CSVUpload_DataCollection_FF();
        CSVUpload_RowValidator_F validatorFactory = new CSVUpload_RowValidator_F();

        CSVUpload_Processor_I processorI = processorFactory.Create();
        CSVUpload_DataCollection_F dataCollectionFactory = dataCollectionFactoryFactory.Create();
        CSVUpload_RowValidator validator = validatorFactory.Create('Service');
        
       Attachment attachment = new attachment();
       
        String csvFileString ='Address1,Address2,Post Code,Country,Email,Phone,First Name,Last Name ,VIN,Registration Number,Service Repair Date,DMS Invoice Ref ID,Repairing Retailer Name,Dealer Code JLR,Brand,Model,Repair Order Number,SR Type,Description,Mileage,Mileage Date,Job Booked Date,Mileage UOM,Remarks'+
        +'The White House,17 Uppingham Rd,LE4 6HG,Uk,d154hhh1@11test.com,99999555,newacc3333o34funt1313,newacc3fdaount273lastname,VIN93343,rn44440334,5/12/18 10:24,ABC123,JLR Kohoku - 50141 - 13859,50141,Jaguar,XE,9343222,Warranty,Front Brake Pads replaced,600000,1/2/18,2/2/18 10:29,Miles,front break left';
    
        CSVIterator csvIterator = new CSVIterator('csvFileString', CSVParser.LF);
   
              String headerString = csvIterator.next();
     
            Apex_Job__c apexJob = new Apex_Job__c(
            Status__c = ApexJobUtilities.PROCESSING_STATUS,
            File_Header__c = headerString
        );
        insert apexJob;
        
        CSVUpload_DataCollection csvdatacollection=new CSVUpload_DataCollection ();
       // FinanceUpload_ExistingRecordRetriever existingRecordRetriever=new FinanceUpload_ExistingRecordRetriever();
       // List<FinanceUpload_SObjectCreator > recordCreators;
        
        CSVUpload_BatchProcessor_Batch batch=new CSVUpload_BatchProcessor_Batch(processorI, dataCollectionFactory, validator, attachment.Id, 
                apexJob.Id);
        CSVUpload_DataCollection  csvData;
        
        
        ServiceUpload_BatchProcessor_F batchPROCESSOR= new ServiceUpload_BatchProcessor_F();
        batchPROCESSOR.create(attachment.id,apexjob.id);
        batchPROCESSOR.getTemplate();

        System.assertNotEquals(validator,null);
        
        System.assertNotEquals(batchPROCESSOR.getLabel(),null);
        System.assertNotEquals(batchPROCESSOR.getName(),null);
        
        
        
        CSVUpload_SObjectUpserter_F sObjectUpserterFactory = new CSVUpload_SObjectUpserter_F();
        CSVUpload_SimpleFieldSetter_F fieldSetterFactory = new CSVUpload_SimpleFieldSetter_F();

        FinanceUpload_ExistingRecordRetriever_F existingRecordRetrieverFactory = new FinanceUpload_ExistingRecordRetriever_F();
        CSVUpload_SimpleFieldSetter fieldSetter = fieldSetterFactory.Create('Service');
        CSVUpload_SObjectUpserter sObjectUpserter = sObjectUpserterFactory.Create();

        FinanceUpload_SObjectBuilder_I accountBuilder = new FinanceUpload_AccountBuilder();
        FinanceUpload_SObjectBuilder_I assetBuilder = new FinanceUpload_AssetBuilder();
        FinanceUpload_SObjectBuilder_I eventBuilder = new ServiceUpload_EventBuilder ();
        FinanceUpload_SObjectBuilder_I serviceItemsBuilder = new ServiceUpload_EventBuilder ();

        FinanceUpload_SObjectCreator accountCreator = new FinanceUpload_SObjectCreator (fieldSetter, 
                accountBuilder, sObjectUpserter);
        FinanceUpload_SObjectCreator assetCreator = new FinanceUpload_SObjectCreator (fieldSetter, 
                assetBuilder, sObjectUpserter);
        FinanceUpload_SObjectCreator servicesCreator = new FinanceUpload_SObjectCreator (fieldSetter, 
                eventBuilder, sObjectUpserter);

        FinanceUpload_ExistingRecordRetriever existingRecordRetriever = existingRecordRetrieverFactory.Create();
        //List is order dependent, be careful with dependencies:
        List<FinanceUpload_SObjectCreator > recordCreators = new List<FinanceUpload_SObjectCreator > { accountCreator,
                assetCreator, servicesCreator};
                
        
         Map<Integer,asset> mapIntToAsset= new Map<Integer,asset>();
        
        Asset asset1= TestClass_AssetBuilder.buildvehicle();
        insert asset1;
        
        mapIntToAsset.put(1,asset1);
                
        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        recordcollection.AssetsByRowId=mapIntToAsset;
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();
        Map<String,service_data__c> mapStringToService=new Map<String,service_Data__c>();
        
        mapStringToService.put('074343',new Service_data__c());

        Integer rowIndex1 = 1;
        String initialStatus = 'start status';

         Service_data__c service;
        service = new Service_data__c(Unique_Repair_Order_Number__c='034343',asset__c=asset1.id);
        
        
        
        recordCollection.ServiceByRowId.put(rowIndex1, service);
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
        Map<String,id> mapIdAccountToIdUser;
        Map<String,account>mapPhoneToIdAccount= new Map<String,account>();
        Map<String,service_data__c> serviceDataByRepairOrder = new Map<String,service_data__c>();
        Set<String> repairOrders=new Set<String>();
       
        insert service;
        Service_Data_Item__c sdi= new Service_Data_Item__c();
        sdi.ServiceData__c=service.id;
        sdi.Unique_Repair_Order_Number__c='034343';
        insert sdi;
        
        repairOrders.add('034343');
        serviceDataByRepairOrder.put('034343',new Service_data__c(Unique_Repair_Order_Number__c='034343'));
        Account acc= new account();
        acc.lastname='test11';
        acc.phone='033344333';
        insert acc;
        
        Map<id,service_data__c> mapIdToService =new Map<id,service_data__c>([select id,Unique_Repair_Order_Number__c,Description__c from service_data__c]);
        
        mapPhoneToIdAccount.put('03434',acc);
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        mapIdAccountToIdUser=new Map<String,id>();
        mapIdaccounttoiduser.put(acc.id,u.id);      
        
        recordCollection.csvdatacollection=  csvdatacollection ;
         recordCollection.csvdatacollection.LineStatusesByRowIndex=  new Map<Integer, CSVRowStatus>();
        recordCollection.csvdatacollection.linesbyrowindex=LinesByRowIndex;
        recordCollection.csvdatacollection.ColumnIndexesByFieldName =ColumnIndexesByFieldName ;
   
        ServiceUpload_Processor svProcessor= new ServiceUpload_Processor(existingRecordRetriever, recordCreators);
        svProcessor.process(csvdatacollection);
        svProcessor.createServiceDataItems(recordCreators[0] ,recordCollection, mapIdAccountToIdUser,mapPhoneToIdAccount,
       serviceDataByRepairOrder,repairOrders,mapIdToService);
        
  }

 
}