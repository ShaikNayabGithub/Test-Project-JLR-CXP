@isTest
public class SObjectMatcher_Test {
    static testmethod void Match_ReturnsEmptyMap_GivenEmptyLists()
    {
    	List<SObject> objectToMatch = new List<SObject>();
    	List<SObject> objectsToMatchAgainst = new List<SObject>();
    	List<String> fieldNames = new List<String>();
    	
    	Map<SObject, SObject> results = SObjectMatcher.Match(objectToMatch, objectsToMatchAgainst, fieldNames);
    	
    	System.assertEquals(0, results.Size());
    }
    
    static testmethod void Match_ReturnsEmptyMap_GivenEmptyObjectsToMatchList()
    {
    	List<SObject> objectToMatch = new List<SObject>();
    	List<SObject> objectsToMatchAgainst = new List<SObject>();
    	objectsToMatchAgainst.Add(new Lead());
    	List<String> fieldNames = new List<String>();
    	fieldNames.Add('Name');
    	
    	Map<SObject, SObject> results = SObjectMatcher.Match(objectToMatch, objectsToMatchAgainst, fieldNames);
    	
    	System.assertEquals(0, results.Size());
    }
    
    static testmethod void Match_ReturnsEmptyMap_GivenEmptyObjectsToMatchAgainstList()
    {
    	List<SObject> objectToMatch = new List<SObject>();
    	objectToMatch.Add(new Lead());
    	List<SObject> objectsToMatchAgainst = new List<SObject>();
    	List<String> fieldNames = new List<String>();
    	fieldNames.Add('Name');
    	
    	Map<SObject, SObject> results = SObjectMatcher.Match(objectToMatch, objectsToMatchAgainst, fieldNames);
    	
    	System.assertEquals(0, results.Size());
    }
    
    static testmethod void Match_ReturnsEmptyMap_GivenEmptyFieldNamesList()
    {
    	List<SObject> objectToMatch = new List<SObject>();
    	objectToMatch.Add(new Lead());
    	List<SObject> objectsToMatchAgainst = new List<SObject>();
    	objectsToMatchAgainst.Add(new Lead());
    	List<String> fieldNames = new List<String>();
    	
    	Map<SObject, SObject> results = SObjectMatcher.Match(objectToMatch, objectsToMatchAgainst, fieldNames);
    	
    	System.assertEquals(0, results.Size());
    }
    
    static testmethod void Match_ReturnsPairLeadOneLeadTwo_GivenMatchingFirstNamesAndFieldFirstName()
    {
    	String value = 'test';
    	String fieldName = 'FirstName';
    	
    	List<SObject> objectToMatch = new List<SObject>();
    	Lead leadOne = new Lead();
    	leadOne.put(fieldName, value);
    	objectToMatch.Add(leadOne);
    	
    	List<SObject> objectsToMatchAgainst = new List<SObject>();
    	Lead leadTwo = new Lead();
    	leadTwo.put(fieldName, value);
    	objectsToMatchAgainst.Add(leadTwo);
    	
    	List<String> fieldNames = new List<String>();
    	fieldNames.Add(fieldName);
    	
    	Map<SObject, SObject> results = SObjectMatcher.Match(objectToMatch, objectsToMatchAgainst, fieldNames);
    	
    	System.assertEquals(leadTwo, results.get(leadOne));
    }
}