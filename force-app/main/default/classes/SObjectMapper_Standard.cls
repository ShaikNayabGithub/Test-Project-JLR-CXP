public class SObjectMapper_Standard implements SObjectMapper_I{
    public Map<Id, SObject> ConvertToMap(List<SObject> records)
    {
    	return new Map<Id, SObject>(records);
    }
}