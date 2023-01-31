@isTest
public class FinanceUpload_AccountBuilder_T {
    
	//TODO refactor this class
	static testMethod void Build_ReturnsNull_GivenAccount()
    {
        FinanceUpload_AccountBuilder accountBuilder = new FinanceUpload_AccountBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();

        Integer rowIndex1 = 1;

        Account account1 = new Account();
        recordCollection.AccountsByRowId.put(rowIndex1, account1);
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>(); 
        
        Map<String,Service_data__c> mapStringToService=new Map<String,Service_data__c>();

        Account result = accountBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),mapStringToService);

        System.AssertEquals(null, result);
    }

    static testMethod void Build_ReturnsAccountWithRecordTypePersonAccount_GivenEmptyCollection()
    {
        FinanceUpload_AccountBuilder accountBuilder = new FinanceUpload_AccountBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        
         Map<String,Id> mapStringAccountToUserId=new Map<String,Id>(); 
         
         Map<String,Service_data__c> mapStringToService=new Map<String,service_data__c>();

        Integer rowIndex1 = 1;

        Account result = accountBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),mapStringToService);
 
        System.AssertEquals(null, result);
    }

    static testMethod void Build_AddsAccountWithRecordTypePersonAccounttoCollection_GivenEmptyCollection()
    {
        FinanceUpload_AccountBuilder accountBuilder = new FinanceUpload_AccountBuilder();

        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        
        Map<String,Id> mapStringAccountToUserId=new Map<String,Id>(); 

        Map<String,Service_data__c> mapStringToService=new Map<String,service_data__c>();
        
        Integer rowIndex1 = 1;

        Account result = accountBuilder.Build(rowIndex1, recordCollection,mapStringAccountToUserId,new Map<String,account>(),mapStringToService);

        System.AssertEquals(null,result);
    }
}