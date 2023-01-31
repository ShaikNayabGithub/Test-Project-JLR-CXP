@isTest
public class TimeAdapter_HHMMSS_Test {
    static testMethod void Parse_ThrowsTypeException_GivenString12345() {
    	TimeAdapter_HHMMSS timeAdapter = new TimeAdapter_HHMMSS();
    	
    	string input = '12345';
    	
    	boolean result = false;
    	try
    	{
    		timeAdapter.parse(input);
    	}
    	catch (TypeException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
    
    static testMethod void Parse_ThrowsTypeException_GivenString1234() {
    	TimeAdapter_HHMMSS timeAdapter = new TimeAdapter_HHMMSS();
    	
    	string input = '1234';
    	
    	boolean result = false;
    	try
    	{
    		timeAdapter.parse(input);
    	}
    	catch (TypeException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
    
    static testMethod void Parse_Returns23595900_GivenString235959() {
    	TimeAdapter_HHMMSS timeAdapter = new TimeAdapter_HHMMSS();
    	
    	string input = '235959';
    	
    	Time result = timeAdapter.parse(input);
    	
    	System.assertEquals(Time.newInstance(23,59,59,00), result);
    }
}