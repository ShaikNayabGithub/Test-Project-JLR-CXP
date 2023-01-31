@isTest
public class DescribeFieldResultExtensions_Test {
    static testmethod void GetNames_ReturnsFirstName_GivenFirstName()
    {
    	List<Schema.DescribeFieldResult> describeFieldResults = new List<Schema.DescribeFieldResult>();
    	Schema.DescribeFieldResult firstNameDescribe = Lead.FirstName.getDescribe();
    	describeFieldResults.add(firstNameDescribe);
    	
    	List<String> results = DescribeFieldResultExtensions.GetNames(describeFieldResults);
    	
    	System.assertEquals(firstNameDescribe.getName(), results[0]);
    }
    
    static testmethod void GetNames_ReturnsLastName_GivenFirstNameLastName()
    {
    	List<Schema.DescribeFieldResult> describeFieldResults = new List<Schema.DescribeFieldResult>();
    	Schema.DescribeFieldResult firstNameDescribe = Lead.FirstName.getDescribe();
    	Schema.DescribeFieldResult lastNameDescribe = Lead.LastName.getDescribe();
    	describeFieldResults.add(firstNameDescribe);
    	describeFieldResults.add(lastNameDescribe);
    	
    	List<String> results = DescribeFieldResultExtensions.GetNames(describeFieldResults);
    	
    	System.assertEquals(lastNameDescribe.getName(), results[1]);
    }
}