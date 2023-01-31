public class DMS_FieldPopulatedValidator {//needs unit tests
    public static void CheckField(SObject s, Schema.DescribeFieldResult field)
    {
    	string fieldName = field.getName();
    	if(String.isEmpty((string)s.get(fieldName)))
    	{
	    	string exceptionMessage = String.format(System.Label.DMSException_MissingField, new List<String> {field.getLabel(), s.getSObjectType().getDescribe().getLabel()});
	    	throw new DMSOutbound_InvalidDataException(exceptionMessage);
	    }
    }

    public static void CheckField(SObject s, List<Schema.DescribeFieldResult> fields)
    {
    	string fieldNames = '';
    	string deliminater = '';
    	for(Schema.DescribeFieldResult field : fields)
    	{
    		string fieldName = field.getName();

	    	string fieldValue = (string)s.get(fieldName);	    	
	    	if(String.isNotEmpty(fieldValue)){ return; }

	    	fieldNames += deliminater + field.getLabel();
	    	deliminater = ', ';
    	}

    	string exceptionMessage = String.format(System.Label.DMSException_MissingOneOfManyFields, new List<String> {fieldNames, s.getSObjectType().getDescribe().getLabel()});
    	throw new DMSOutbound_InvalidDataException(exceptionMessage);
    }
}