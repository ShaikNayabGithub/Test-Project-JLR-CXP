public class FinanceUpload_SObjectCreator{
    private final CSVUpload_SimpleFieldSetter simpleFieldSetter;
    public final FinanceUpload_SObjectBuilder_I sObjectBuilder;
    private final CSVUpload_SObjectUpserter sObjectUpserter;
    private set<String> phoneTracker=new Set<String>();
    private set<String> serviceTracker=new Set<String>();
    public Set<String> assetTracker=new Set<String>();
    Sobject sobj;
    Sobject sobj2;
    String type;
    Asset asset;
    Asset asset2;
     
    public FinanceUpload_SObjectCreator(CSVUpload_SimpleFieldSetter simpleFieldSetter,  
            FinanceUpload_SObjectBuilder_I sObjectBuilder,
            CSVUpload_SObjectUpserter sObjectUpserter)
    {
        this.simpleFieldSetter = simpleFieldSetter;
        this.sObjectBuilder = sObjectBuilder;
        this.sObjectUpserter = sObjectUpserter;
    }

    public void Create(FinanceUpload_RecordCollection recordCollection,Map<String,Id>mapIdAccountToIdUser,Map<String,account> mapPhoneToIdAccount,Map<String,service_data__c> mapStringToService)
    {
        Map<Integer, SObject> recordsForUpsertByRowId = new Map<Integer, SObject>();
        String type;
        Asset assetTemp;
        Role__c role;
        Contract contract;
        SObject record ;
        List<Role__c> listAssetRole=new List<role__c>();
        String accountLabel=Schema.SObjectType.Account.Label;
        Id recordTypeId = Schema.SObjectType.ROLE__C.getRecordTypeInfosByName().get(accountLabel).getRecordTypeId();
        Account account;
        Set<String> vehicles;
        Id accountId;
        Service_data__c service;
        Service_data__c serviceFromMap;
        String idTracker;

        if(recordCollection.CSVDataCollection!=null)
            if(recordCollection.CSVDataCollection.LinesByRowIndex!=null)
            {    for(Integer csvRowIndex : recordCollection.CSVDataCollection.LinesByRowIndex.keySet()) {
                
                    CSVRowStatus rowStatus = recordCollection.CSVDataCollection.LineStatusesByRowIndex.get(csvRowIndex);
                    if(rowStatus != null && rowStatus.HasErrored == true) continue;
                    
                    serviceFromMap=null;
                    service=null;
                    idTracker=null;
                    
                    record = this.sObjectBuilder.Build(csvRowIndex, recordCollection,mapIdAccountToIdUser,mapPhoneToIdAccount,mapStringToService);
                    
                    role=new Role__c();
                              
                    if(record!=null)
                        type=record.getSObjectType().getDescribe().getName();
                    
                     if(type=='Service_Data__c')
                     {
                   
                         //Now check if that assetrole does not exist in the system before creating a new one.
                          service=(Service_Data__c)record;
                          if(service!=null){
                              idTracker=service.Unique_Repair_Order_Number__c;
                         
                          }                    
                      
                     }
                     else
                     if(type=='Contract'){
                         contract=(Contract)record;
                         
                         if(contract!=null)
                             if(contract.asset__c!=null){
                                     
                                 //Now check if that assetrole does not exist in the system before creating a new one.
                                    List<String> rowData = null;
                                    rowdata=recordCollection.CSVDataCollection.LinesByRowIndex.get(csvRowIndex);
                                     String phone= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Phone', rowData));
                                   
                                     Account acc=mapPhoneToIdAccount.get(phone);
                                     if(acc==null)
                                         acc= recordCollection.AccountsByRowId.get(csvRowIndex);
                                     
                                     if(acc!=null)
                                         if(acc.id!=null){      
                                              vehicles=recordCollection.mapIdAccountToSetVehicles.get(acc.id);
                                                                                
                                           }
                            
                                  if((acc!=null && acc.recordtypeid!=SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id
                                 && acc.recordtypeid!= SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id
                                  && Acc.recordtypeid!= SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id) && contract!=null
                                  && contract.message__c==null &&((vehicles!=null && !vehicles.contains(contract.asset__c))  || vehicles==null ))
                                     {
                                         role=new Role__c(RecordTypeId=recordTypeId , Account__c=acc.id, Vehicle__c=contract.asset__c, Role__c='Finance Contract Holder');
                                         listAssetRole.add(role);
                                      }                              
                             }
                     }
                     
                   
                    if(record == null) continue;
                    
                   this.simpleFieldSetter.SetSimpleFields(record, csvRowIndex, recordCollection.CSVDataCollection);
                   
                   if((!serviceTracker.contains(idTracker) && idTracker!=null )|| idTracker==null){
                       
                       if(serviceTracker!=null)
                           serviceTracker.add(idTracker);
                           
                       recordsForUpsertByRowId.put(csvRowIndex, record);
                   }                      
                                   
                }//loop ends
      
              
                
                this.sObjectUpserter.UpsertRecords(recordsForUpsertByRowId, 
                recordCollection.CSVDataCollection.LineStatusesByRowIndex, 
                recordCollection.CSVDataCollection.ApexJob,mapPhoneToIdAccount);       
            }//ends if
                    
       
       //Insert assetroles for the finance uploader.
       
       insert listAssetRole;                           
      }

}