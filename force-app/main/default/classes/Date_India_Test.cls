@isTest
public class Date_India_Test {
    static testMethod void Parse_ReturnsDate20101991_GivenString20Dash10Dash1991() {
    	Date_India parser = new Date_India();
    	string input = '20-10-1991';
    	Date expected = Date.newInstance(1991, 10, 20);
    	
    	Date result = parser.parse(input);
    	System.assertEquals(expected, result);
    }
    
    static testMethod void Parse_ThrowsTypeException_GivenString20Dash1991() {
    	Date_India parser = new Date_India();
    	string input = '20-1991';
    	Boolean result = false;
    	
    	try
    	{
    		parser.parse(input);
    	}
    	catch(TypeException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
    
    static testMethod void Parse_ThrowsTypeException_GivenString20Dash10Dash() {
    	Date_India parser = new Date_India();
    	string input = '20-10-';
    	Boolean result = false;
    	
    	try
    	{
    		parser.parse(input);
    	}
    	catch(TypeException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
    
    static testMethod void Parse_ThrowsTypeException_GivenString20DashDash1991() {
    	Date_India parser = new Date_India();
    	string input = '20--1991';
    	Boolean result = false;
    	
    	try
    	{
    		parser.parse(input);
    	}
    	catch(TypeException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
}