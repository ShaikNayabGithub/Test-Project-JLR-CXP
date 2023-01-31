public class EventUtilities {
    public static Map<String, RecordType> RecordTypes { get {
        if(RecordTypes == null) {
            RecordTypes = new Map<String, RecordType>();
            List<RecordType> recordTypeList = [Select DeveloperName From RecordType Where SObjectType = 'Event' And IsActive = true];
            for(RecordType recordType : recordTypeList)
            {
                RecordTypes.put(recordType.DeveloperName, recordType);
            }
        }
        return RecordTypes;
    } private set; }
}