public class AssetUtilities {
    public static Map<String, RecordType> RecordTypes { get {
        if(RecordTypes == null) {
            RecordTypes = new Map<String, RecordType>();
            List<RecordType> recordTypeList = [Select DeveloperName, Name, SobjectType From RecordType Where SObjectType = 'Asset' And IsActive = true];
            for(RecordType recordType : recordTypeList)
            {
                RecordTypes.put(recordType.DeveloperName, recordType);
            }
        }
        return RecordTypes;
    } private set; }
}