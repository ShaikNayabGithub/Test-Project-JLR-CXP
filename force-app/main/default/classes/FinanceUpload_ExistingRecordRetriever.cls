public class FinanceUpload_ExistingRecordRetriever {
    private final FinanceUpload_AssetRetriever assetRetriever;
    private final FinanceUpload_AccountRetriever accountRetriever;
    private final FinanceUpload_ContactRetriever contactRetriever;
    private final FinanceUpload_LeadRetriever leadRetriever;
    private final FinanceUpload_ContractRetriever contractRetriever;

    private final FinanceUpload_AssetMapper assetMapper;
    private final FinanceUpload_AccountMapper accountMapper;
    private final FinanceUpload_ContractMapper contractMapper;

    public FinanceUpload_ExistingRecordRetriever(FinanceUpload_AssetRetriever assetRetriever,
            FinanceUpload_AccountRetriever accountRetriever, FinanceUpload_ContactRetriever contactRetriever,
            FinanceUpload_LeadRetriever leadRetriever, FinanceUpload_ContractRetriever contractRetriever,
            FinanceUpload_AssetMapper assetMapper, FinanceUpload_AccountMapper accountMapper,
            FinanceUpload_ContractMapper contractMapper)
    {
        this.assetRetriever = assetRetriever;
        this.accountRetriever = accountRetriever;
        this.contactRetriever = contactRetriever;
        this.leadRetriever = leadRetriever;
        this.contractRetriever = contractRetriever;
        this.assetMapper = assetMapper;
        this.accountMapper = accountMapper;
        this.contractMapper = contractMapper;
    }


    public void Retrieve(FinanceUpload_RecordCollection recordCollection)
    {
        Set<String> emails = CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.EMAIL_COLUMN_HEADER,
                recordCollection.CSVDataCollection);
        Set<String> phoneNumbers = CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.PHONE_COLUMN_HEADER,
                recordCollection.CSVDataCollection);
        Set<String> mobileNumbers= CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.MOBILE_NUMBER,
                recordCollection.CSVDataCollection);        
        Set<String> vins = CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.VIN_COLUMN_HEADER,
                recordCollection.CSVDataCollection);
        Set<String> registrationNumbers = CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.REGISTRATION_COLUMN_HEADER,
                recordCollection.CSVDataCollection);
        Set<String> financeReferences = CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.FINANCE_REFERENCE_COLUMN_HEADER,
                recordCollection.CSVDataCollection);
        Set<String> legalEntityIds= CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.LEGAL_ENTITY_ID,
                recordCollection.CSVDataCollection);
         Set<String> lastNames= CSVDataCollectionUtilities.GetUniqueValues(FinanceUpload_Constants.LAST_NAME_COLUMN_HEADER,
                recordCollection.CSVDataCollection);  
        
        phoneNumbers.addAll(mobileNumbers);
        
        List<Asset> assets = this.assetRetriever.Retrieve(vins, registrationNumbers);
        List<Account> accounts = this.accountRetriever.Retrieve(lastNames,emails, phoneNumbers,legalEntityIds);
        this.accountRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, accounts);
     
        //accounts=removeDuplicatedAccounts(accounts);
        
        List<Contact> contacts = this.contactRetriever.Retrieve(emails, phoneNumbers);
        this.contactRetriever.RemoveContactDetailsFromSets(emails, phoneNumbers, contacts);
        List<Lead> leads = this.leadRetriever.Retrieve(emails, phoneNumbers);
        List<Contract> contracts = this.contractRetriever.Retrieve(financeReferences);
        Map<Id,Id> mapAssetIdToRetailerid;
        Map<Id,Id> mapAccountIdToRetailerId;
        
        //populate maps here
        Set<Id> setVehids=new Set<id>();
           for(asset veh:assets)
               setVehIds.add(veh.id);
        
        Set<id> setaccounts=new set<id>();
            for(account acc:accounts)
                setaccounts.add(acc.id);       
            
        mapAssetIdToRetailerid=CreateMapAssetIdToRetailerId(assets);
        mapAccountIdToRetailerId=CreateMapAccountIdToRetailerId(accounts);
        
        recordCollection.mapAccountIdToRetailerId=mapAccountIdToRetailerId;
        recordCollection.mapAssetIdToRetailerid=mapAssetIdToRetailerid;
      
        this.assetMapper.AddToCollection(assets, recordCollection);
        this.accountMapper.AddToCollection(accounts, contacts, leads, recordCollection);
        this.contractMapper.AddToCollection(contracts, recordCollection);
    }
    
    private List<account> removeDuplicatedAccounts(List<Account> listAccounts){
    
        map<Id,account> mapAccounts=new Map<Id,Account>(listAccounts);
    
        for(account a:listAccounts){
        
            if(mapAccounts.containsKey(a.id))
                mapAccounts.remove(a.id);    
        
        }
        
      return mapAccounts.values();  
    
    }
    
    private Map<Id,ID> CreateMapAssetIdToRetailerId(list<asset> listassets){
    
        Map<Id,id> mapAssetIdToRetailerId=new Map<id,id>();
     
    
       // list<asset> listassets=[select account.owner.accountid from asset where ID in:setVehIds];
    
        for(asset veh:listassets){
        
           if(veh.account.recordtypeid==SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id)
               mapAssetIdToRetailerId.put(veh.id,veh.accountid);    
           else
           if(veh.account.owner!=null)
               if(veh.account.owner.accountId!=null)
                   mapAssetIdToRetailerId.put(veh.id,veh.account.owner.accountid);    
            }
 
        return mapAssetIdToRetailerId;
    
    }
    
      private Map<Id,ID> CreateMapAccountIdToRetailerId(list<account> listAccounts){
    
        Map<Id,id> mapAccountIdToRetailerId=new Map<Id,Id>();
       // list<ACCOUNT> accountsList= [SELECT id,owner.accountid FROM Account where Id in: setAccounts];

        for(account acc:listAccounts){

            mapAccountIdToRetailerId.put(acc.id,acc.owner.accountid);    
        }
            
        return mapAccountIdToRetailerId;
    
    }
    
}