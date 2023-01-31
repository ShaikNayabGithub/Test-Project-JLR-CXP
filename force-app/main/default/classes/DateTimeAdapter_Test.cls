@isTest
public class DateTimeAdapter_Test {
    static testMethod void Validate_ReturnsDateTime_GivenSpaceSeparatedDateTimeString() {
    	DateTimeAdapter dateTimeAdapter = BuildDateTimeAdapter(); 
    	
    	string input = 'date time';
    	DateTime expected = DateTime.newInstance(1991, 10, 20);
    	
    	DateTime result = dateTimeAdapter.parseDateTime(input);
    	
    	System.assertEquals(expected, result);
    }
    
    static testMethod void Validate_ThrowsTypeException_GivenNonSpaceSeparatedDateTimeString() {
    	DateTimeAdapter dateTimeAdapter = BuildDateTimeAdapter(); 
    	
    	string input = 'datetime';
    	Boolean result = false;
    	
    	try
    	{
    		dateTimeAdapter.parseDateTime(input);
    	}
    	catch(TypeException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
    
    private static DateTimeAdapter BuildDateTimeAdapter()
    {
    	I_DateAdapter dateAdapter = new Dummy_DateAdapter();
    	I_TimeAdapter timeAdapter = new Dummy_TimeAdapter();
    	return new DateTimeAdapter(dateAdapter, timeAdapter);
    }
    
    private class Dummy_DateAdapter implements I_DateAdapter{
    	public Date parse(string dateString)
    	{
    		return Date.newInstance(1991, 10, 20);
    	}
    }
    
    private class Dummy_TimeAdapter implements I_TimeAdapter{
    	public Time parse(string timeString)
    	{
    		return Time.newInstance(0,0,0,0);
    	}
    }
}