@isTest
public class StringExtensions_Test {
    static testmethod void AddIfNotEmpty_DoesNotAddStringToList_GivenEmptyString()
    {
    	List<String> listToAddTo = new List<String>();
    	String stringToAdd = '';
    	
    	StringExtensions.AddIfNotEmpty(stringToAdd, listToAddTo);
    	
    	System.AssertEquals(0, listToAddTo.Size());
    }
    
    static testmethod void AddIfNotEmpty_DoesNotAddStringToList_GivenNullString()
    {
    	List<String> listToAddTo = new List<String>();
    	String stringToAdd = null;
    	
    	StringExtensions.AddIfNotEmpty(stringToAdd, listToAddTo);
    	
    	System.AssertEquals(0, listToAddTo.Size());
    }
    
    static testmethod void AddIfNotEmpty_AddsStringToList_GivenPopulatedString()
    {
    	List<String> listToAddTo = new List<String>();
    	String stringToAdd = 'test';
    	
    	StringExtensions.AddIfNotEmpty(stringToAdd, listToAddTo);
    	
    	System.AssertEquals(stringToAdd, listToAddTo[0]);
    }
    
    
    static testmethod void ConcatonateList_ReturnsEmptyString_GivenEmptyList()
    {
    	List<String> stringList = new List<String>();
    	String deliminator = '';
    	String finalDeliminator = '';
    	
    	String result = StringExtensions.ConcatonateList(stringList, deliminator, finalDeliminator);
    	
    	System.AssertEquals('', result);
    }
    
    static testmethod void ConcatonateList_ReturnsTest_GivenTest()
    {
    	String string1 = 'test';
    	List<String> stringList = new List<String>();
    	stringList.Add(string1);
    	String deliminator = '';
    	String finalDeliminator = '';
    	
    	String result = StringExtensions.ConcatonateList(stringList, deliminator, finalDeliminator);
    	
    	System.AssertEquals(string1, result);
    }
    
    static testmethod void ConcatonateList_ReturnsTestAndTest_Given2TestEmptyStringAnd()
    {
    	String string1 = 'test';
    	List<String> stringList = new List<String>();
    	stringList.Add(string1);
    	stringList.Add(string1);
    	String deliminator = '';
    	String finalDeliminator = 'And ';
    	
    	String result = StringExtensions.ConcatonateList(stringList, deliminator, finalDeliminator);
    	
    	System.AssertEquals(string1 + finalDeliminator + string1, result);
    }
    
    static testmethod void ConcatonateList_ReturnsTestCommaTestAndTest_Given3TestEmptyStringAnd()
    {
    	String string1 = 'test';
    	List<String> stringList = new List<String>();
    	stringList.Add(string1);
    	stringList.Add(string1);
    	stringList.Add(string1);
    	String deliminator = ', ';
    	String finalDeliminator = 'And ';
    	
    	String result = StringExtensions.ConcatonateList(stringList, deliminator, finalDeliminator);
    	
    	System.AssertEquals(string1 + deliminator + string1 + finalDeliminator + string1, result);
    }
    
    static testmethod void GetSobjectIds_ReturnsLeadId_GivenSObjectTypeLeadAndLeadIdAndAccountId()
    {
    	Lead lead = TestClass_LeadCreator.CreateLead();
    	Account account = TestClass_AccountCreator.CreatePersonAccount();
    	
    	Set<String> inputIds = new Set<String>{lead.Id, account.Id};
    	
    	Set<Id> outputIds = StringExtensions.GetSobjectIds(Schema.Lead.sObjectType, inputIds);
    	
    	System.Assert(outputIds.Contains(lead.Id));
    }
    
    static testmethod void GetSobjectIds_DoesNotReturnAccountId_GivenSObjectTypeLeadAndLeadIdAndAccountId()
    {
    	Lead lead = TestClass_LeadCreator.CreateLead();
    	Account account = TestClass_AccountCreator.CreatePersonAccount();
    	
    	Set<String> inputIds = new Set<String>{lead.Id, account.Id};
    	
    	Set<Id> outputIds = StringExtensions.GetSobjectIds(Schema.Lead.sObjectType, inputIds);
    	
    	System.Assert(!outputIds.Contains(account.Id));
    }
}