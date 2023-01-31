public class FinanceUpload_Processor implements CSVUpload_Processor_I {

    private final FinanceUpload_ExistingRecordRetriever existingRecordRetriever;
    private final List<FinanceUpload_SObjectCreator> recordCreators;
    public static Map<String,account> mapPhoneToIdAccount=new Map<String,account>();
    public static Map<String,service_data__c> serviceDataByRepairOrder=new Map<String,Service_data__c>();

    public FinanceUpload_Processor(FinanceUpload_ExistingRecordRetriever existingRecordRetriever,
           List<FinanceUpload_SObjectCreator> recordCreators)
    {
        this.existingRecordRetriever = existingRecordRetriever;
        this.recordCreators = recordCreators;
    }
        
    public void Process(CSVUpload_DataCollection csvData)
    {      
      
           FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
           recordCollection.CSVDataCollection = csvData;

            this.existingRecordRetriever.Retrieve(recordCollection);
             
            Map<ID, Account> accountsFromDealerCode;
            Map<String,Id> mapIdAccountToIdUser=new Map<String,Id>();
            List<user> users;
            Set<String> dealerCodes= CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.DEALER_CODE_COLUMN_HEADER ,
            recordCollection.CSVDataCollection);
           // Set<String> phones= CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.PHONE_COLUMN_HEADER ,
           // recordCollection.CSVDataCollection);
           //  Set<String> emails= CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.EMAIL_COLUMN_HEADER ,
           // recordCollection.CSVDataCollection);
            Account account;
            String accountLabel=Schema.SObjectType.Account.Label;
            Map<Id,Set<String>> mapIdAccountToSetVehicles=new Map<Id,Set<String>>();
            Id recordTypeId = Schema.SObjectType.ROLE__C.getRecordTypeInfosByName().get(accountLabel).getRecordTypeId();
            Set<Id> accountIds=new Set<Id>();
            Set<String> vehicles;
           
            //create a map to store the asset roles with the account id and the asset id.
                          
            List<Account> listAccounts=recordCollection.AccountsByRowId.values();     
                       
            for(Account acc:listAccounts){
            
            accountIds.add(acc.id);
            }
                      
                          
            List <Role__c> assetRoles=[select id,vehicle__c,account__c from role__c where role__c ='Finance Contract Holder' and account__c in:accountIds];
            
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
                         
            if(dealerCodes.isEmpty()==FALSE){
                accountsFromDealerCode=new Map<Id,Account>([select id,Record_Sub_Type__c,Dealer_CI_Code_2__c,Dealer_CI_Code__c from account where  Record_Sub_Type__c ='Dual Brand' and (Dealer_CI_Code_2__c IN:dealerCodes or Dealer_CI_Code__c IN:dealerCodes)]);
                users = [select id,userrole.name,userroleid,accountid  from user where userroleid != null and usertype ='PowerPartner' and isActive = TRUE and accountid IN: accountsFromDealerCode.keySet() and (userrole.name like '%User%') ];
   
            }
                      
           //create map with sales exec related with dealercode 
           if(users!=null)
               for(User user:users){
                       
                       account=accountsFromDealerCode.get(user.accountid);
                       
                       if(!String.isBlank(account.Dealer_CI_Code__c))
                           mapIdAccountToIdUser.put(account.Dealer_CI_Code__c ,user.id);
                       
                       if(!String.isBlank(account.Dealer_CI_Code_2__c ))
                           mapIdAccountToIdUser.put(account.Dealer_CI_Code_2__c ,user.id);       
                   
                   }
           
                                     
            for(FinanceUpload_SObjectCreator recordCreator : recordCreators) {
                    recordCreator.Create(recordCollection,mapIdAccountToIdUser,mapPhoneToIdAccount,serviceDataByRepairOrder);
            }
     
    }
}