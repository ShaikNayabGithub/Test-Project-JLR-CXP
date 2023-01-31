@isTest
public class ChildSObjectLocalFieldUpdater_Test {
    static testmethod void UpdateChildren_SetsChildNameToChildSObjectLocalFieldUpdater_GivenDealerCICodeChangedToChildSObjectLocalFieldUpdater()
    {
    	String parentSourceFieldName = Schema.Account.Dealer_CI_Code__c.getDescribe().getName();
    	String childDestinationFieldName = Schema.Account.Name.getDescribe().getName();
    	String childToParentLookupFieldName = Schema.Account.ParentRecord__c.getDescribe().getName();
    	
    	Account parentAccount = TestClass_AccountCreator.CreateRetailer();
    	parentAccount.put(parentSourceFieldName,'ChildSObjectLocalFieldUpdater');
    	Account childAccount = TestClass_AccountCreator.CreateRetailer();
    	childAccount.put(childToParentLookupFieldName, parentAccount.Id);
    	update childAccount;
    	
    	Map<String, Map<SObjectType, String>> fieldMapping = new Map<String, Map<SObjectType, String>>{parentSourceFieldName=>
    		new Map<SObjectType, String>{ Schema.Account.SObjectType=>childDestinationFieldName}};
		Map<SObjectType, String> childRelationshipMap = new Map<SObjectType, String>{Schema.Account.SObjectType=>childToParentLookupFieldName};
		
		ChildSObjectLocalFieldUpdater childSObjectLocalFieldUpdater = new ChildSObjectLocalFieldUpdater(fieldMapping,childRelationshipMap);
		childSObjectLocalFieldUpdater.UpdateChildren(new List<Account>{parentAccount}, new List<Account>{new Account()});
		
		childAccount = [SELECT Name FROM Account Where Id=:childAccount.Id];
		
		System.AssertEquals(parentAccount.get(parentSourceFieldName), childAccount.get(childDestinationFieldName)); 
    }
    
    static testmethod void UpdateChildren_SetsChild2NameToChildSObjectLocalFieldUpdater_GivenDealerCICodeChangedToChildSObjectLocalFieldUpdater()
    {
    	String parentSourceFieldName = Schema.Account.Dealer_CI_Code__c.getDescribe().getName();
    	String childDestinationFieldName = Schema.Account.Name.getDescribe().getName();
    	String childToParentLookupFieldName = Schema.Account.ParentRecord__c.getDescribe().getName();
    	
    	Account parentAccount = TestClass_AccountCreator.CreateRetailer();
    	parentAccount.put(parentSourceFieldName,'ChildSObjectLocalFieldUpdater');
    	Account childAccount = TestClass_AccountCreator.CreateRetailer();
    	childAccount.put(childToParentLookupFieldName, parentAccount.Id);
    	update childAccount;
    	Account childAccount2 = TestClass_AccountCreator.CreateRetailer();
    	childAccount2.put(childToParentLookupFieldName, parentAccount.Id);
    	update childAccount2;
    	
    	Map<String, Map<SObjectType, String>> fieldMapping = new Map<String, Map<SObjectType, String>>{parentSourceFieldName=>
    		new Map<SObjectType, String>{ Schema.Account.SObjectType=>childDestinationFieldName}};
		Map<SObjectType, String> childRelationshipMap = new Map<SObjectType, String>{Schema.Account.SObjectType=>childToParentLookupFieldName};
		
		ChildSObjectLocalFieldUpdater childSObjectLocalFieldUpdater = new ChildSObjectLocalFieldUpdater(fieldMapping,childRelationshipMap);
		childSObjectLocalFieldUpdater.UpdateChildren(new List<Account>{parentAccount}, new List<Account>{new Account()});
		
		childAccount2 = [SELECT Name FROM Account Where Id=:childAccount2.Id];
		
		System.AssertEquals(parentAccount.get(parentSourceFieldName), childAccount2.get(childDestinationFieldName)); 
    }
    
    static testmethod void UpdateChildren_SetsLeadLastNameToChildSObjectLocalFieldUpdater_GivenDealerCICodeChangedToChildSObjectLocalFieldUpdater()
    {
    	String parentSourceFieldName = Schema.Account.Dealer_CI_Code__c.getDescribe().getName();
    	String childDestinationFieldName = Schema.Account.Name.getDescribe().getName();
    	String childToParentLookupFieldName = Schema.Account.ParentRecord__c.getDescribe().getName();
    	String leadChildToParentLookupFieldName = Schema.Lead.Preferred_Retailer__c.getDescribe().getName();
    	String leadChildDestinationFieldName = Schema.Lead.LastName.getDescribe().getName();
    	
    	Account parentAccount = TestClass_AccountCreator.CreateRetailer();
    	parentAccount.put(parentSourceFieldName,'ChildSObjectLocalFieldUpdater');
    	Account childAccount = TestClass_AccountCreator.CreateRetailer();
    	childAccount.put(childToParentLookupFieldName, parentAccount.Id);
    	update childAccount;
    	Account childAccount2 = TestClass_AccountCreator.CreateRetailer();
    	childAccount2.put(childToParentLookupFieldName, parentAccount.Id);
    	update childAccount2;
    	Lead lead = TestClass_LeadCreator.CreateLead();
    	lead.put(leadChildToParentLookupFieldName, parentAccount.Id);
    	update lead;
    	
    	Map<String, Map<SObjectType, String>> fieldMapping = new Map<String, Map<SObjectType, String>>{parentSourceFieldName=>
    		new Map<SObjectType, String>{ Schema.Account.SObjectType=>childDestinationFieldName,
    		Schema.Lead.SObjectType=>leadChildDestinationFieldName}};
		Map<SObjectType, String> childRelationshipMap = new Map<SObjectType, String>{
			Schema.Account.SObjectType=>childToParentLookupFieldName,
			Schema.Lead.SObjectType=>leadChildToParentLookupFieldName};
		
		ChildSObjectLocalFieldUpdater childSObjectLocalFieldUpdater = new ChildSObjectLocalFieldUpdater(fieldMapping,childRelationshipMap);
		childSObjectLocalFieldUpdater.UpdateChildren(new List<Account>{parentAccount}, new List<Account>{new Account()});
		
		lead = [SELECT LastName FROM Lead Where Id=:lead.Id];
		
		System.AssertEquals(parentAccount.get(parentSourceFieldName), lead.get(leadChildDestinationFieldName)); 
    }
}