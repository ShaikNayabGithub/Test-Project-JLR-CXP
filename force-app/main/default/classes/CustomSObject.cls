public abstract class CustomSObject {
    public Id RecordId;
    
    public final Map<String, CustomSObjectField> Fields;
    
    protected CustomSObject()
    {
    	this.Fields = new Map<String, CustomSObjectField>();
    }
    
    protected CustomSObjectField AddField(Schema.DescribeFieldResult fieldDescription)
    {
    	CustomSObjectField field = new CustomSObjectField(fieldDescription);
    	this.Fields.put(fieldDescription.getName(), field);
    	return field;
    }
}