@isTest
public class LocalNameSetter_Test {
    static testmethod void SetLocalNames_SetsOpportunityNameToTest_GivenAccountWithNameTestAndOpportunityWithAccountId()
    {
    	Account account = TestClass_AccountCreator.CreatePersonAccount();
    	account.LastName = 'Test';
    	Opportunity opportunity = new Opportunity(AccountId=account.Id);
    	
    	Map<Id, SObject> parentObjectMap = new Map<Id, Account>{account.Id=>account};
    	List<SObject> childObjects = new List<SObject>{opportunity};
    	Map<String,String> fieldMap = new Map<String,String>{'LastName'=>'Name'};
    	String lookupFieldName = Schema.Opportunity.AccountId.getDescribe().getName();
    	
    	LocalNameSetter localNameSetter = new LocalNameSetter();
    	localNameSetter.SetLocalNames(parentObjectMap, childObjects, fieldMap, lookupFieldName);
    	
    	System.AssertEquals(account.LastName, opportunity.Name);
    }
    
    static testmethod void SetLocalNames_SetsOpportunity2NameToTest_GivenAccountWithNameTestAndOpportunity2WithAccountId()
    {
    	Account account = TestClass_AccountCreator.CreatePersonAccount();
    	account.LastName = 'Test';
    	Opportunity opportunity = new Opportunity(AccountId=account.Id);
    	Opportunity opportunity2 = new Opportunity(AccountId=account.Id);
    	
    	Map<Id, SObject> parentObjectMap = new Map<Id, Account>{account.Id=>account};
    	List<SObject> childObjects = new List<SObject>{opportunity,opportunity2};
    	Map<String,String> fieldMap = new Map<String,String>{'LastName'=>'Name'};
    	String lookupFieldName = Schema.Opportunity.AccountId.getDescribe().getName();
    	
    	LocalNameSetter localNameSetter = new LocalNameSetter();
    	localNameSetter.SetLocalNames(parentObjectMap, childObjects, fieldMap, lookupFieldName);
    	
    	System.AssertEquals(account.LastName, opportunity2.Name);
    }
}