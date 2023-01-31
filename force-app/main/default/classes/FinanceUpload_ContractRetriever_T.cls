@isTest
public class FinanceUpload_ContractRetriever_T {
    static testMethod void RemoveContactDetailsFromSets_DoesNothing_GivenEmptyCollections()
  {
        FinanceUpload_ContractRetriever contractRetriever = new FinanceUpload_ContractRetriever();
        FinanceUpload_assetRetriever assetRetriever=new FinanceUpload_assetRetriever ();
        FinanceUpload_accountRetriever accountRetriever=new FinanceUpload_accountRetriever ();
        FinanceUpload_contactRetriever contactRetriever=new FinanceUpload_contactRetriever ();
        FinanceUpload_leadRetriever leadRetriever=new FinanceUpload_leadRetriever();
        
         FinanceUpload_AssetMapper assetMapper= new  FinanceUpload_AssetMapper();
         FinanceUpload_AccountMapper accountMapper= new  FinanceUpload_AccountMapper();
         FinanceUpload_ContractMapper contractMapper= new  FinanceUpload_ContractMapper();
         
         
         

        Set<String> emails = new Set<String>();
        Set<String> phoneNumbers = new Set<String>();
        List<Contact> contacts = new List<Contact>();
        
        Account account =New account();
        account.lastName='test';
        account.PersonEmail='test@test.com';
        
        insert account;
        
        Vehicle_Specification__c vs=new Vehicle_Specification__c();

        insert vs;
        
        Asset assetObj=new asset();
        assetObj.name='testasset';
        assetObj.brand__c=vs.id;
        assetObj.accountId=account.id;

        insert assetObj;
        
        Contract contract = new Contract();
        contract.accountId=account.id;
        contract.asset__c=assetObj.id;
        contract.Finance_Reference__c='test111';
        insert contract;
        
        Set<String> setString= new Set<String>();
        setString.add('test111');


        List<contract> listContract=contractRetriever.retrieve(setString);


        System.AssertNotequals(listContract,null);
        System.AssertEquals(listContract.size(),1);
        
       FinanceUpload_RecordCollection rc=new FinanceUpload_RecordCollection();
       
       contractMapper.addToCollection(listContract,rc);
      
        FinanceUpload_ExistingRecordRetriever retriever= new FinanceUpload_ExistingRecordRetriever(assetRetriever,accountRetriever,contactRetriever,
       leadRetriever,contractRetriever,assetMapper,accountMapper,contractMapper);
       
       
        
        retriever.retrieve(rc);
        
        
    }

}