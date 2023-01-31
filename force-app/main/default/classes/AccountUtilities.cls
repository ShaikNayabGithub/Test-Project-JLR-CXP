public class AccountUtilities {
    public static Map<String, RecordType> RecordTypes { get {
        if(RecordTypes == null) {
            RecordTypes = new Map<String, RecordType>();            
          
            Map<String,Schema.RecordTypeInfo> recordTypeList1 =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            for(string s :recordTypeList1.keyset()){
                
                Schema.RecordTypeInfo recordtyperetrived = recordTypeList1.get(s);
                RecordType rt = new RecordType();
                rt.Id = recordtyperetrived.getRecordTypeId();
                rt.DeveloperName = s;
                RecordTypes.put(s,rt);                
                
            }            
           
        }
        return RecordTypes;
    } private set; }
}