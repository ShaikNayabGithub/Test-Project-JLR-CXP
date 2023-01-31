public class JSONDeserializer {
	public Map<Object, SObject> DeserializeIterable(List<SObject> records, String fieldName, Type objectType) {
		Map<Object, SObject> iterableMap = new Map<Object, SObject>();

		for(SObject record : records){
			String fieldValue = String.valueOf(record.get(fieldName));
			List<Object> fieldContent = (List<Object>)JSON.deserialize(fieldValue, objectType);
			for(Object iterable : fieldContent) {
				iterableMap.put(iterable, record);
			}
		}

		return iterableMap;
	}
	
	public Object DeserializeSingle(String content, Type objectType)
	{
		if(String.IsEmpty(content)) { return objectType.newInstance(); }
		return JSON.deserialize(content, objectType);
	}
}