public class ServiceUpload_Processor implements CSVUpload_Processor_I,Service_I {
    private final FinanceUpload_ExistingRecordRetriever existingRecordRetriever;
    private final List<FinanceUpload_SObjectCreator > recordCreators;
    public static Map<String,account> mapPhoneToIdAccount=new Map<String,account>();
    final String RETAILER_CI_CODE='Dealer Code JLR';
    final String accountLabel=Schema.SObjectType.Account.Label;
    public static Map<string,service_data__c> serviceDataByRepairOrder=new Map<String,service_data__c>();
    Id recordTypeId = Schema.SObjectType.ROLE__C.getRecordTypeInfosByName().get(accountLabel).getRecordTypeId();
    public final static String REPAIR_ORDER_NUMBER='Repair Order Number';
    public final static String VIN='VIN';
    public final static String SERVICE_REPAIR_DATE='Service Repair Date';
     
        public ServiceUpload_Processor (FinanceUpload_ExistingRecordRetriever existingRecordRetriever,
                List<FinanceUpload_SObjectCreator > recordCreators)
        {
                this.existingRecordRetriever = existingRecordRetriever;
                this.recordCreators = recordCreators;
        }
                       
    public void Process(CSVUpload_DataCollection csvData)
    {        
           FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
           recordCollection.CSVDataCollection = csvData;
           recordCollection.isFileUploadService=true;

            this.existingRecordRetriever.Retrieve(recordCollection);
             
            Map<ID, Account> accountsFromDealerCode;
            Map<String,Id> mapIdAccountToIdUser=new Map<String,Id>();
            List<user> users=new List<User>();
            Set<String> dealerCodes= CSVDataCollectionUtilities.GetUniqueValues(RETAILER_CI_CODE ,
            recordCollection.CSVDataCollection);
             Set<String> repairOrders= CSVDataCollectionUtilities.GetUniqueValues(REPAIR_ORDER_NUMBER,
            recordCollection.CSVDataCollection);
            Account account;
            Map<Id,Set<String>> mapIdAccountToSetVehicles=new Map<Id,Set<String>>();         
            Set<Id> accountIds=new Set<Id>();
            Set<String> vehicles;
            Map<Id,service_data__c> mapIdToService;         
            
            //create a map to store the asset roles with the account id and the asset id.
            
            recordCollection.AccountsByRowId=new Map<Integer,Account>();//ignore account processing stages
                          
            List<Account> listAccounts=recordCollection.AccountsByRowId.values();     
            
            for(Account acc:listAccounts){
            
            if(acc!=null)
                accountIds.add(acc.id);
            
            }
                                               
            List <Role__c> assetRoles=[select id,vehicle__c,account__c from role__c where role__c ='Service Holder' and account__c in:accountIds];
            
            for(Role__c role: assetRoles)
            {
                
                vehicles=mapIdAccountToSetVehicles.get(role.account__c);
                if(vehicles==null){
                    vehicles=new Set<String>();
                    vehicles.add(role.vehicle__c);
                    mapIdAccountToSetVehicles.put(role.account__c,vehicles);    
                }    
               else     
                {
                    mapIdAccountToSetVehicles.get(role.account__c).add(role.vehicle__c);
                
                }                   
            
            }
            
            recordCollection.mapIdAccountToSetVehicles=mapIdAccountToSetVehicles;
       
       //Check already existing repair orders in the system.
       recordCollection.repairOrdersToProcess=removeAlreadyExistingRepairOrdersFromSet(repairOrders);
               
               FinanceUpload_SObjectCreator serviceItemsCreator;
                
               //Creates accounts,assets,sevice_data objects
               for(FinanceUpload_SObjectCreator recordCreator : recordCreators) {
                     
                   recordCreator.Create(recordCollection,mapIdAccountToIdUser,mapPhoneToIdAccount,serviceDataByRepairOrder);
                          if(recordCreator.sObjectBuilder!=null)
                              if(recordCreator.sObjectBuilder instanceof ServiceUpload_EventBuilder )                         
                                  serviceItemsCreator= recordCreator;                         
               
               }
               
               //creates service data items using the previous map as the parents.
               //createServiceDataItems(serviceItemsCreator,recordCollection, mapIdAccountToIdUser,mapPhoneToIdAccount,
              //serviceDataByRepairOrder,repairOrders,mapIdToService);
                                
    }
    
     private set<String>  removeAlreadyExistingRepairOrdersFromSet(Set<String> repairOrders){
     
     Map<Id,service_data__c> mapIdToService;
     mapIdToService=new Map<Id,service_data__c>([select id,licence_plate__c,Unique_Repair_Order_Number__c,description__c,account__c,asset__c,asset__r.name,Price_Total__c,derivative__c from service_data__c where Unique_Repair_Order_Number__c IN:repairOrders ]);
             
       for(Service_data__c sd:mapIdToService.values())
       {
          serviceDataByRepairOrder.put(sd.Unique_Repair_Order_Number__c ,sd);     
          
          if(repairOrders.contains(sd.Unique_Repair_Order_Number__c )){
             repairOrders.remove(sd.Unique_Repair_Order_Number__c );
             
          }
          
       }
     
     return repairOrders;
     }
   
  public void createServiceDataItems(FinanceUpload_SObjectCreator serviceItemsCreator,FinanceUpload_RecordCollection recordCollection,Map<String,Id> mapIdAccountToIdUser,Map<String,account> mapPhoneToIdAccount,
    Map<string,service_data__c> serviceDataByRepairOrder,Set<String> repairOrders,Map<Id,service_data__c> mapIdToService){
    
    
      Role__c roleToAdd;
      Set<String> vehicles;
      List<Role__c> listAssetRole=new List<role__c>();
      
      //Collect a map of service data objects
       mapIdToService=new Map<Id,service_data__c>([select id,Unique_Repair_Order_Number__c,description__c,account__c,asset__c,asset__r.name,Price_Total__c,derivative__c from service_data__c where Unique_Repair_Order_Number__c IN:repairOrders ]);
       
       for(Service_data__c serv:mapIdToService.values())
       {
          serviceDataByRepairOrder.put(serv.Unique_Repair_Order_Number__c ,serv);
       }
       
       //create asset roles
       //1)Check if the asset roles don't exist from the map created in the main method.
                   
        for(Service_Data__c sd:mapIdToService.values())
        {
            if(sd.account__c!=null && sd.asset__c!=null)
            {
               
                vehicles=recordCollection.mapIdAccountToSetVehicles.get(sd.account__c);
        
                if( (vehicles!=null && !vehicles.contains(sd.asset__c))  || vehicles==null ){
                  
                    roleToAdd=new Role__c(RecordTypeId=recordTypeId , Account__c=sd.account__c, Vehicle__c=sd.asset__c, Role__c='Service Holder');
                    listAssetRole.add(roleToAdd);
                }    
            }
        }
       
       insert listAssetRole;

     //create service data items 
     recordCollection.isServiceItem=true;
     serviceItemsCreator.create(recordCollection,mapIdAccountToIdUser,mapPhoneToIdAccount,serviceDataByRepairOrder);
      
      recordCollection.isServiceItem=false;  
      Map<Id,service_data_item__c>mapserviceDataItems=new Map<Id,Service_data_item__c>([select id,Unique_Repair_Order_Number__c,description__c,price_total__c from service_data_item__c where Unique_Repair_Order_Number__c IN:repairOrders ]); 
     
      //update description of service data with concatenation of children remarks and children description.
      //query children just created             

      List<Service_data__C> listToUpdate=new List<service_data__c>();
      for(Service_data__c serviceData:mapIdToService.values())
      {
          
          for(Service_data_item__c serviceDataItem:mapserviceDataItems.values())
          {
             
              if(servicedata.Unique_Repair_Order_Number__c==serviceDataItem.Unique_Repair_Order_Number__c)  
              {
                 String finalDescription=mapIdToService.get(serviceData.id).description__c;
                 Decimal total=mapIdToService.get(serviceData.id).price_total__c;
                 
                 if(finalDescription==null)
                     finalDescription=serviceDataItem.description__c; 
                 else
                 if(finalDescription!=serviceData.description__c)
                     finaldescription=serviceData.description__c+'\n'+serviceDataItem.description__c; 
                     
                 if(total==null || total==0)
                     total=serviceDataItem.price_total__c;
                 else
                     total=serviceData.price_total__c+serviceDataItem.price_total__c;        
             
                  mapIdToService.get(serviceData.id).description__c=finalDescription;
                  mapIdToService.get(serviceData.id).price_total__c=total;
              }
              
              
           }
                       
      }              

       update mapIdToService.values();     
    }      
       
}