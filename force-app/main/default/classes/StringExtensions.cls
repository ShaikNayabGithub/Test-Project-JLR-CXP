public class StringExtensions {
    public static void AddIfNotEmpty(String value, List<String> listToAddTo)
    {
    	if(String.isNotEmpty(value)){
    		listToAddTo.Add(value);
    	}
    }
    
    public static String ConcatonateList(List<String> stringList, String deliminator, String finalDeliminator)
    {
    	String concatonatedString = '';
    	if(stringList.Size() == 0){ return concatonatedString; }
    	concatonatedString = stringList[0];
    	if(stringList.Size() == 1){ return concatonatedString; }
    	
		for(Integer i = 1; i < (stringList.Size() - 1); i++){
			concatonatedString += (deliminator + stringList[i]);
		}
		concatonatedString += (finalDeliminator + stringList[stringList.Size() - 1]);
		
		return concatonatedString;
    }
    
    public static Set<Id> GetSobjectIds(SObjectType sObjectType, Set<String> objectIds)
    {
    	Set<Id> typeIds = new Set<Id>();
    	
    	for(String objectId : objectIds)
    	{
    		Id idAsId = Id.valueOf(objectId);
    		if(idAsId.getSobjectType() == sObjectType)
    		{
    			typeIds.add(idAsId);
    		}
    	}
    	
    	return typeIds;
    }
}