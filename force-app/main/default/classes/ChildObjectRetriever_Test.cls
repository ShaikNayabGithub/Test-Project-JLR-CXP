@isTest
public class ChildObjectRetriever_Test {
    static testmethod void RetrieveChildObjects_ReturnsChildAccount_GivenTypeAccountAndFieldNameParentRecordAndParentRecordIdAndOneChildExist()
    {
    	Account parentAccount = TestClass_AccountCreator.CreateRetailer();
    	Account childAccount = TestClass_AccountCreator.CreateRetailer();
    	childAccount.ParentRecord__c = parentAccount.Id;
    	update childAccount;
    	
    	ChildObjectRetriever childObjectRetriever = new ChildObjectRetriever();
    	List<SObject> results = childObjectRetriever.RetrieveChildObjects(Schema.Account.sObjectType, 
    		Schema.Account.ParentRecord__c.getDescribe().getName(), new Set<Id>{parentAccount.Id});
    		
		System.AssertEquals(childAccount.Id, results[0].Id);
    }
    
    static testmethod void RetrieveChildObjects_ReturnsNoRecords_GivenTypeAccountAndFieldNameParentRecordAndParentRecordIdAndNoChildrenExist()
    {
    	Account parentAccount = TestClass_AccountCreator.CreateRetailer();
    	
    	ChildObjectRetriever childObjectRetriever = new ChildObjectRetriever();
    	List<SObject> results = childObjectRetriever.RetrieveChildObjects(Schema.Account.sObjectType, 
    		Schema.Account.ParentRecord__c.getDescribe().getName(), new Set<Id>{parentAccount.Id});
    		
		System.AssertEquals(0, results.Size());
    }
    
    static testmethod void RetrieveChildObjects_ReturnsTwoAccounts_GivenTypeAccountAndFieldNameParentRecordAndParentRecordIdAndTwoChildrenExist()
    {
    	Account parentAccount = TestClass_AccountCreator.CreateRetailer();
    	Account childAccount = TestClass_AccountCreator.CreateRetailer();
    	childAccount.ParentRecord__c = parentAccount.Id;
    	update childAccount;
    	Account childAccount2 = TestClass_AccountCreator.CreateRetailer();
    	childAccount2.ParentRecord__c = parentAccount.Id;
    	update childAccount2;    	
    	
    	ChildObjectRetriever childObjectRetriever = new ChildObjectRetriever();
    	List<SObject> results = childObjectRetriever.RetrieveChildObjects(Schema.Account.sObjectType, 
    		Schema.Account.ParentRecord__c.getDescribe().getName(), new Set<Id>{parentAccount.Id});
    		
		System.AssertEquals(2, results.Size());
    }
}