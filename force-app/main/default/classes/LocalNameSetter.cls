public class LocalNameSetter {
    public void SetLocalNames(Map<Id, SObject> parentObjectMap, List<SObject> childObjects, Map<String, String> fieldMap, 
        String lookupFieldName)
    {
        for(SObject childObject : childObjects)
        {
            SObject parentObject = parentObjectMap.get((Id)childObject.get(lookupFieldName));
            if(parentObject == null) { continue; }
            for(String parentField : fieldMap.KeySet())
            {
                Object fieldValue = parentObject.get(parentField);
                childObject.put(fieldMap.get(parentField), fieldValue);
            }
        }
    }
}