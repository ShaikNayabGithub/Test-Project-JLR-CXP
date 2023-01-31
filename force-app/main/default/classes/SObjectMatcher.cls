public class SObjectMatcher {   
    public static Map<SObject, SObject> Match(List<SObject> objectToMatch, List<SObject> objectsToMatchAgainst, List<String> fieldNames)
    {
        Map<SObject, SObject> matchedMap = new Map<SObject, SObject>();
        if(fieldNames.Size() == 0) { return matchedMap; }
        
        Map<String, SObject> objectsToMatchAgainstMap = new Map<String, SObject>();
        for(SObject sObjectRecord : objectsToMatchAgainst) {
            String mergedValues = MergeFieldValues(sObjectRecord, fieldNames);
            objectsToMatchAgainstMap.put(mergedValues, sObjectRecord);
        }
        
        for(SObject sObjectRecord : objectToMatch) {
            String mergedValues = MergeFieldValues(sObjectRecord, fieldNames);
            SObject matchedSObject = objectsToMatchAgainstMap.get(mergedValues);
            if(matchedSObject != null){
                matchedMap.put(sObjectRecord, matchedSObject);
            }
        }       
        
        return matchedMap;
    }
    
    private static String MergeFieldValues(SObject objectToMerge, List<String> fieldNames)
    {
        List<String> fieldValues = new List<String>();
        for(String fieldName : fieldNames){
            fieldValues.Add(String.valueOf(objectToMerge.get(fieldName)));
        }
        return StringExtensions.ConcatonateList(fieldValues, '_', '_');
    }
}