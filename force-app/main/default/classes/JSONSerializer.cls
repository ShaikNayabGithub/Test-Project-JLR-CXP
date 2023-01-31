public class JSONSerializer {
    public List<String> Serialize(List<I_Serializable> objectsToSerialize, Integer maximumSize)
    {
    	this.RemoveEmptyObjects(objectsToSerialize);
        return this.Serialize(objectsToSerialize, maximumSize, 0);
    }


    private List<String> Serialize(List<Object> objectsToSerialize, Integer maximumSize, Integer previousAttemptedSplit)
    {
        List<List<Object>> splitList = new List<List<Object>>();
        Integer splitListSize = objectsToSerialize.Size()/(previousAttemptedSplit + 1);

        for(Object serializationChild : objectsToSerialize){
            List<Object> childList = new List<Object>();
            if(splitList.size() == 0 || splitList[splitList.size() - 1].size() >= splitListSize) {
                splitList.add(childList);
            } else {
                childList = splitList[splitList.size() - 1];
            }
            childList.add(serializationChild);
        }

        List<String> splitSerialization = new List<String>();
        for(List<Object> serializationTarget : splitList){
            String serialization = JSON.serialize(serializationTarget);
            if(serialization.length() < maximumSize) {
                splitSerialization.add(serialization);
            } else {
                return this.Serialize(objectsToSerialize, maximumSize, previousAttemptedSplit + 1);
            }
        }
        return splitSerialization;
    }
    
    private void RemoveEmptyObjects(List<I_Serializable> objects)
    {
    	List<Integer> indexesToRemove = new List<Integer>();
    	for(Integer i = 0; i < objects.Size(); i++) {
    		if(objects[i].IsEmpty()) {
    			indexesToRemove.Add(i);
    		}
    	}
    	
    	for(Integer i = indexesToRemove.Size() - 1; i >= 0; i--) {//reversed so removal does not alter position of objects not yet removed
    		objects.Remove(indexesToRemove[i]);
    	}
    }
}