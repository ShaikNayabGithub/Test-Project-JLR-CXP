@isTest
public class FinanceUpload_ContractBuilder_T {
    static testMethod void Build_DoesNotChangeContractStatus_GivenContract()
    {
        FinanceUpload_ContractBuilder contractBuilder = new FinanceUpload_ContractBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();

        Integer rowIndex1 = 1;
        String initialStatus = 'start status';

        Contract contract1 = new Contract(Contract_Status__c = initialStatus);
        recordCollection.ContractsByRowId.put(rowIndex1, contract1);


        contractBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),new Map<String,service_data__c>());


        System.AssertEquals(initialStatus, contract1.Contract_Status__c);
    }

    static testMethod void Build_CreatesContractWithStatusUnknown_GivenCollectionWithAccountAndAsset()
    {
        FinanceUpload_ContractBuilder contractBuilder = new FinanceUpload_ContractBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();

        Integer rowIndex1 = 1;
        
        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
        insert asset1;
        String contractStatus;

        recordCollection.AccountsByRowId.put(rowIndex1, account1);
        recordCollection.AssetsByRowId.put(rowIndex1, asset1);

        contractBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),new Map<String,service_data__c>());
        
        if(recordCollection.ContractsByRowId!=null)
            If(recordCollection.ContractsByRowId.get(rowIndex1)!=null)
                contractStatus=recordCollection.ContractsByRowId.get(rowIndex1).Contract_Status__c;
        

        System.AssertNotEquals('Unknown',contractStatus );
    }
    
    @testsetup
    static void testsetup(){
    
      
    //    UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
       // insert r;
    
    
    }

    static testMethod void Build_DoesSetContractAccount_GivenCollectionWithContractAndAccountAndAsset()
    {
        FinanceUpload_ContractBuilder contractBuilder = new FinanceUpload_ContractBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();

        Integer rowIndex1 = 1;
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();
      
        Test.startTest();

        Contract contract1 = new Contract();
        
      
        
        Account account1 = new account();
        account1.name='test111';
        account1.phone='074327944';
        
        insert account1;
        
        Account a = TestClass_AccountCreator.CreateRetailer();
        a.ParentId = TestClass_AccountCreator.CreateRetailer().Id;
         
        update a;
        
        Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
        asset1.account=a;
        insert asset1;
       
        Contact c = TestClass_ValidContactBuilder.Build(a);
       
        //User u =[select id from user where id=:UserInfo.getUserId()];
        User u = new User(Id=UserInfo.getUserId());
        user us;
        
        System.runas(u){
        
            us=TestClass_UserCreator.CreateRetailerUser(c);
        }
        
        account1.OwnerId =us.Id;
        update account1;

        recordCollection.ContractsByRowId.put(rowIndex1, contract1);
        recordCollection.AccountsByRowId.put(rowIndex1, account1);
        recordCollection.AssetsByRowId.put(rowIndex1, asset1);

        Contract contract2=contractBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),new Map<String,service_data__c>());
        id contVeh;
        id contAcc;
        
        if(contract2!=null){
            contVeh=contract2.Asset__c;
            contAcc=contract2.AccountId;
            
        }    

        System.AssertNotEquals(null, contAcc);
        
        account rtacc=[select id,recordtypeid from account where id=:contAcc];
        
        Test.stopTest();
        
        System.assertequals(account1.id,contract2.accountid);
  
        System.AssertNotEquals(contAcc,null);
       
        System.AssertNotEquals(null, contVeh);
        
        System.AssertNotEquals(null, contract2);
        
    }

    static testMethod void Build_SetsContractAccount_GivenCollectionWithAccountAndAsset()
    {
        FinanceUpload_ContractBuilder contractBuilder = new FinanceUpload_ContractBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();

        Integer rowIndex1 = 1;
        Id accountId;
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();
        
        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
        insert asset1;
        
        if(recordCollection!=null)
            if(recordCollection.ContractsByRowId!=null)
                if(recordCollection.ContractsByRowId.get(rowIndex1)!=null)
                    accountId=recordCollection.ContractsByRowId.get(rowIndex1).accountId;

        recordCollection.AccountsByRowId.put(rowIndex1, account1);
        recordCollection.AssetsByRowId.put(rowIndex1, asset1);


        contractBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),new Map<String,service_data__c>());

        System.AssertNotEquals(account1.Id, accountId);
    }

    static testMethod void Build_DoesNotSetContractAsset_GivenCollectionWithContractAndAccountAndAsset()
    {
        FinanceUpload_ContractBuilder contractBuilder = new FinanceUpload_ContractBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();

        Integer rowIndex1 = 1;
        
        Contract contract1 = new Contract();
        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
        insert asset1;

        recordCollection.ContractsByRowId.put(rowIndex1, contract1);
        recordCollection.AccountsByRowId.put(rowIndex1, account1);
        recordCollection.AssetsByRowId.put(rowIndex1, asset1);


        contractBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),new Map<String,service_data__c>());


        System.AssertNotEquals(null, recordCollection.ContractsByRowId.get(rowIndex1).Asset__c);
    }

    static testMethod void Build_SetsContractAsset_GivenCollectionWithAccountAndAsset()
    {
        FinanceUpload_ContractBuilder contractBuilder = new FinanceUpload_ContractBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>();

        Integer rowIndex1 = 1;
        
        Id assetId;
        Account account1 = TestClass_AccountCreator.CreatePersonAccount();
        Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
        asset1.accountid=account1.id;
        insert asset1;

        recordCollection.AccountsByRowId.put(rowIndex1, account1);
        recordCollection.AssetsByRowId.put(rowIndex1, asset1);

        contractBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),new Map<String,service_data__c>());
        
        if(recordCollection.ContractsByRowId!=NULL)
            IF(recordCollection.ContractsByRowId.get(rowIndex1)!=NULL)
                assetId= recordCollection.ContractsByRowId.get(rowIndex1).Asset__c;
                
                
            
        System.AssertEquals(null,assetId);
    }
}