@isTest
public class DateTimeExtension_Test {
    static testmethod void AddHours_Returns1_1_2_2_1_1_Given1_1_1_1_1_1And1()
    {
    	DateTime inputDateTime = DateTime.newInstance(1,1,1,1,1,1);
    	integer hoursToAdd = 1;
    	
    	DateTime result = DateTimeExtension.AddHours(inputDateTime, hoursToAdd);
    	
    	System.AssertEquals(DateTime.newInstance(1,1,1,2,1,1), result);
    }
    
    static testmethod void AddHours_Returns1_1_2_2_1_1_Given1_1_1_1_1_1And25()
    {
    	DateTime inputDateTime = DateTime.newInstance(1,1,1,1,1,1);
    	integer hoursToAdd = 25;
    	
    	DateTime result = DateTimeExtension.AddHours(inputDateTime, hoursToAdd);
    	
    	System.AssertEquals(DateTime.newInstance(1,1,2,2,1,1), result);
    }
    
    static testmethod void AddHours_Returns1_1_1_1_1_1_Given1_1_1_2_1_1Andm1()
    {
    	DateTime inputDateTime = DateTime.newInstance(1,1,1,2,1,1);
    	integer hoursToAdd = -1;
    	
    	DateTime result = DateTimeExtension.AddHours(inputDateTime, hoursToAdd);
    	
    	System.AssertEquals(DateTime.newInstance(1,1,1,1,1,1), result);
    }
    
    static testmethod void AddHours_Returns1_1_1_1_1_1_Given1_1_2_2_1_1Andm25()
    {
    	DateTime inputDateTime = DateTime.newInstance(1,1,2,2,1,1);
    	integer hoursToAdd = -25;
    	
    	DateTime result = DateTimeExtension.AddHours(inputDateTime, hoursToAdd);
    	
    	System.AssertEquals(DateTime.newInstance(1,1,1,1,1,1), result);
    }
}