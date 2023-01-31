public class SObjectUtilities {
	
    public static Map<Id,User> usersMap = new Map<Id,User>(); // Added by NTT as part of Code optimisation - 14/06/2021

    public static Map<String, Map<String, RecordType>> RecordTypes { get {
        if(RecordTypes == null) {
            RecordTypes = new Map<String, Map<String, RecordType>>();
            List<RecordType> recordTypeList = [Select DeveloperName, SObjectType From RecordType Where IsActive = true];
            for(RecordType recordType : recordTypeList)
            {
                Map<String, RecordType> objectRecordTypes = RecordTypes.get(recordType.SObjectType);
                if(objectRecordTypes == null) {
                    objectRecordTypes = new Map<String, RecordType>();
                    RecordTypes.put(recordType.SObjectType, objectRecordTypes);
                }
                objectRecordTypes.put(recordType.DeveloperName, recordType);
            }
        }
        return RecordTypes;
    } private set; }
    
    public static Set<String> GetFieldValues(List<SObject> records, String fieldName)
    {
        Set<String> fieldData = new Set<String>();
        for(SObject record : records){
            String value = String.valueOf(record.get(fieldName));
            if(String.isNotEmpty(value)){
                fieldData.add(value);
            }
        }
        return fieldData;
    }    
    
    public static void SetMultiple(SObject record, List<String> fieldsToSet, String value)
    {
        for(String fieldName : fieldsToSet){
            record.put(fieldName, value);
        }
    }
    
    public static Map<Id, User> GetOwnerMap(List<SObject> records)
    {
        String ownerFieldName = 'OwnerId';
        if(records.Size() > 0) {
            SObjectType recordType = records[0].getSObjectType();
            if(recordType == Schema.Contact.getSObjectType()) {
                ownerFieldName = Schema.Contact.ownerid.getDescribe().getName();
            } else if(recordType == Schema.Account.getSObjectType()) {
                ownerFieldName = Schema.Account.ownerid.getDescribe().getName();
            }
        }
        
        Set<String> recordOwners = SObjectUtilities.GetFieldValues(records, ownerFieldName);
        recordOwners.add(UserInfo.getUserId());
        // Start - Added by NTT as part of Code optimisation - 14/06/2021
        Boolean recalculateUsers = false;
        for (String recordOwner : recordOwners) {
            if (!usersMap.containsKey(recordOwner)) {
                recalculateUsers = true;
            }
        }
        
        if (recalculateUsers) {
            List<User> users = [Select Country_ISO_Code__c From User Where Id In :recordOwners];
            usersMap.putAll(users);
        }
        
        Map<Id, User> userMap = new Map<Id, User>();
        for (String recordOwner : recordOwners) {
            if (usersMap.containsKey(recordOwner)) {
                userMap.put(recordOwner, usersMap.get(recordOwner));
            }
        }
		// End - Added by NTT as part of Code optimisation - 14/06/2021
        //List<User> users = [Select Country_ISO_Code__c From User Where Id In :recordOwners];
        //Map<Id, User> userMap = new Map<Id, User>(users);
        return userMap;
    }
    
    public static Set<Id> GetFieldValuesId(List<SObject> records, String fieldName)
    {
        Set<Id> fieldData = new Set<Id>();
        for(SObject record : records){
            String value = String.valueOf(record.get(fieldName));
            if(String.isNotEmpty(value)){
                fieldData.add(value);
            }
        }
        return fieldData;
    } 
    
    public static List<SObject> QueryWithMultipleOrs(string queryFirstLine, string whereClauseFormat, List<string> fieldsToGet, List<SObject> objectsToIterate)
    { 
        List<SObject> queryResults = new List<SObject>();
        List<string> WhereClauses = new List<string>();
        
        for(SObject genericObject : objectsToIterate)
        {
            List<string> fieldValues = new List<string>();
            for(string fieldName : fieldsToGet)
            {
                string fieldValue = (string)genericObject.get(fieldName);
                fieldValues.add(fieldValue);                
            }
            WhereClauses.add(String.format(WhereClauseFormat, fieldValues));
        }
        if(!WhereClauses.isEmpty())
        {
            boolean needExtraBracket = false;
            if(queryFirstLine.endsWith('AND ('))
            {
                 needExtraBracket = true;  
            }
            queryFirstLine += String.join(WhereClauses, 'OR');
            if(needExtraBracket)
            {
                queryFirstLine += ')';
            }
            system.debug('Query string: ' + queryFirstLine);
            queryResults = database.query(queryFirstLine);  
        }
        return queryResults;
    }
    
    public static List<SObject> GetChanged(List<SObject> newRecords, List<SObject> oldRecords, Set<String> monitoredFields)
    {
        List<SObject> updatedRecords = new List<SObject>();
        for(integer i=0; i < newRecords.size(); i++)
        {
            for(String field : monitoredFields)
            {
                if(newRecords[i].get(field) != oldRecords[i].get(field)){
                    updatedRecords.add(newRecords[i]);
                    break;
                }
            }
        }
        return updatedRecords;
    }

    public static void SetIfNotBlank(SObject record, Schema.DescribeFieldResult field, String value)
    {
        if(String.isNotBlank(value)) {
            record.put(field.getName(), value);
        }
    }

    public static Map<Id, List<SObject>> MapByIdField(List<SObject> records, Schema.DescribeFieldResult field)
    {
        Map<Id, List<SObject>> recordMap = new Map<Id, List<SObject>>();

        String fieldName = field.getName();
        
        for(SObject record : records) {
            Id key = (Id)record.get(fieldName);
            List<SObject> subList = recordMap.get(key);
            if(subList == null) {
                subList = new List<SObject>();
                recordMap.put(key, subList);
            }
            
            subList.add(record);
        }

        return recordMap;
    }

    public static Map<String, List<SObject>> MapByField(List<SObject> records, Schema.DescribeFieldResult field)
    {
        Map<String, List<SObject>> recordMap = new Map<String, List<SObject>>();

        String fieldName = field.getName();
        
        for(SObject record : records) {
            String key = String.valueOf(record.get(fieldName));
            List<SObject> subList = recordMap.get(key);
            if(subList == null) {
                subList = new List<SObject>();
                recordMap.put(key, subList);
            }
            
            subList.add(record);
        }

        return recordMap;
    }

   public static object CastFieldData(String fieldValueString, Schema.DescribeFieldResult fieldDescription)
    {
        Schema.DisplayType fieldType = fieldDescription.getType();
        String user_locale = UserInfo.getLocale();
        String JPdatetime_format ='yyyy-MM-dd';
        Date datepa;
        Datetime dt;
     
        if(fieldType == Schema.DisplayType.Boolean) {
            return Boolean.valueOf(fieldValueString);
        } else if(fieldType == Schema.DisplayType.String ||
                fieldType == Schema.DisplayType.TextArea ||
                fieldType == Schema.DisplayType.Phone ||
                fieldType == Schema.DisplayType.Picklist ||
                fieldType == Schema.DisplayType.ID ||
                fieldType == Schema.DisplayType.Email) {
            return fieldValueString;
        } else if(fieldType == Schema.DisplayType.Date) {
            if(Pattern.matches('[0-9]{4}-[0-9]{2}-[0-9]{2}', fieldValueString)) {
         
                return Date.valueOf(fieldValueString);
            } else {
            
            if(Pattern.matches('[0-9]{4}-[0-9]{1}-[0-9]{2}', fieldValueString)) {
       
                return Date.valueOf(fieldValueString);
            } 
            else
             
            if(Pattern.matches('[0-9]{2}-[A-z]{3}-[0-9]{2}', fieldValueString)) {
                
                return returnCorrectDateFormat(fieldValueString);
            }    
            else
            if(user_locale =='ja_JP' || user_locale=='ja')
              
                 if(!String.isblank(fieldvaluestring))
                     {
                 
                     datepa= Date.parse(fieldValueString);
                 
                     if(datepa!=null)
                         dt = Datetime.newInstance(datepa.year(), datepa.month(),datepa.addDays(1).day());
                      }
                 return Date.valueOf(dt);
                
            }
        } else if(fieldType == Schema.DisplayType.Double ||
                fieldType == Schema.DisplayType.Currency) {
            return Double.valueOf(fieldValueString);
        } else if(fieldType == Schema.DisplayType.DateTime) {
            if(Pattern.matches('[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}', fieldValueString)) {
                return DateTime.valueOf(fieldValueString);
            } else {
                return DateTime.parse(fieldValueString);
            }
        } else if(fieldType == Schema.DisplayType.Integer) {
            return Integer.valueOf(fieldValueString);
        } else if(fieldType == Schema.DisplayType.Percent) {
            return Decimal.valueOf(fieldValueString);
        }

        return fieldValueString;
    }
    
    
    public static Date returnCorrectDateFormat(String dateToFormat){
    
     String day = dateToFormat.split('-')[0];
                String month = dateToFormat.split('-')[1];
                String year= dateToFormat.split('-')[2];
                String monthInt;
                
                if(month.toLowerCase()=='jan')
                    monthInt=String.valueOf(1);
                else    
                if(month.toLowerCase()=='feb')
                    monthInt=String.valueOf(2);
                else
                if(month.toLowerCase()=='mar')
                    monthInt=String.valueOf(3);
                else
                if(month.toLowerCase()=='apr')
                    monthInt=String.valueOf(4);
                else
                if(month.toLowerCase()=='may')
                    monthInt=String.valueOf(5);
                else
                 if(month.toLowerCase()=='jun')
                    monthInt=String.valueOf(6);
                else
                 if(month.toLowerCase()=='jul')
                    monthInt=String.valueOf(7);
                else
                 if(month.toLowerCase()=='aug')
                    monthInt=String.valueOf(8);
                else
                 if(month.toLowerCase()=='sep')
                    monthInt=String.valueOf(9);
                else
                 if(month.toLowerCase()=='oct')
                    monthInt=String.valueOf(10);
                 else
                 if(month.toLowerCase()=='nov')
                    monthInt=String.valueOf(11);
                 else
                 if(month.toLowerCase()=='dec')
                    monthInt=String.valueOf(12);
    
        return Date.parse(day+'/'+monthInt+'/'+year);
    }
    
}