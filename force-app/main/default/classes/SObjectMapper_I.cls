public interface SObjectMapper_I {
    Map<Id, SObject> ConvertToMap(List<SObject> records);
}