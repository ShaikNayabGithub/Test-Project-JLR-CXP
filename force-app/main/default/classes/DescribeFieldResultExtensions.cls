public class DescribeFieldResultExtensions {
    public static List<String> GetNames(List<Schema.DescribeFieldResult> describeFieldResults)
    {
    	List<String> fieldNames = new List<String>();
    	for(Schema.DescribeFieldResult describeFieldResult : describeFieldResults){
        	fieldNames.add(describeFieldResult.getName());
        }
        return fieldNames;
    }
}