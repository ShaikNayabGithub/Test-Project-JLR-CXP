public class ChildObjectRetriever {
	private static final String soqlBaseString = 'SELECT Id, {1} FROM {0} WHERE {1} IN:parentIds';
	
    public List<SObject> RetrieveChildObjects(SObjectType sObjectType, String parentLookupFieldName, Set<Id> parentIds)
    {
    	String soqlString = String.Format(soqlBaseString, new List<String>{sObjectType.getDescribe().getName(), parentLookupFieldName});
    	return Database.query(soqlString);
    }
}