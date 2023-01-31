public class SchemaUtility {
    
    public static Map<String,String> getObjectLabelMap(String objectName) {  
        Map<String,String> fieldLableMap = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();      
        
        for (String fieldName: fieldMap.keySet()) {
            System.debug('##Field API Name='+fieldName);
            System.debug('##Field API Name='+fieldMap.get(fieldName).getDescribe().getLabel());
            fieldLableMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
        } 
        return fieldLableMap;
    }
    public static Map<String,String> getPickListValues(String ObjectApiName, String FieldApiName){
        Map<String,String> pickListValuesMap= new Map<String,String>();        
        Map<String,String> fieldLableMap = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(ObjectApiName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap(); 
        Schema.DescribeFieldResult fieldResult = fieldMap.get(FieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getLabel());
        }     
        return pickListValuesMap;
    }
    
    public static List<Schema.FieldSetMember> getObjectFieldSetFieldNames(String objectName, String fieldSetName) {
        System.debug('Getting schema for ' + objectName + ', field set ' + fieldSetName);
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        List<Schema.FieldSetMember> fieldNames = new List<Schema.FieldSetMember>();
        if(sObj.getDescribe().fieldSets.getMap().containsKey(fieldSetName)){
            System.debug('Found field set members');
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
                System.debug('Adding ' + fieldMember);
                fieldNames.add(fieldMember);
            }
        }
        return fieldNames;
    }
    
    public class CurrentDateDetails {
        @AuraEnabled public Integer financailYear;
        @AuraEnabled public Integer Quarter;
        public CurrentDateDetails(Integer Year, Integer Month) {
            financailYear = Year;
            if(Month >= 1 && Month <= 3){
                Quarter = 4;
                financailYear = Year-1;
            } else if(Month >= 4 && Month <= 6){                
                Quarter = 1;
            }else  if(Month >= 7 && Month <= 9){                
                Quarter = 2;
            }else  if(Month >= 10 && Month <= 12){                
                Quarter = 3;
            }
        }
        
    }
    
    
    
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField fieldType) {
        Schema.DescribeFieldResult fieldResult = fieldType.getDescribe();
        Schema.sObjectField controlFieldType = fieldResult.getController();
        if (controlFieldType == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult controlFieldResult = controlFieldType.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(controlFieldResult.getType() != Schema.DisplayType.Boolean) {
            controlEntries = controlFieldResult.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
}