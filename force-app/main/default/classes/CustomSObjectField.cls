public class CustomSObjectField {
    public final String Description;//cannot store Schema.DescribeFieldResult without making transient for visualforce
	public String Value { get; set; }
	
	public CustomSObjectField(Schema.DescribeFieldResult description)
	{
		this.Description = description.getName();
	}
}