@isTest
public class SOAPXMLAttributeConstructor_Test {
    static testMethod void AddAttributeStringString_ReturnsEmptyString_GivenEmptyName() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = '';
    	string value = 'test value';
    	
    	string result = attributeConstructor.AddAttribute(name, value);
    	
    	System.assertEquals('', result);
    }
    
    static testMethod void AddAttributeStringString_ReturnsEmptyString_GivenEmptyValue() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = 'testName';
    	string value = '';
    	
    	string result = attributeConstructor.AddAttribute(name, value);
    	
    	System.assertEquals('', result);
    }
    
    static testMethod void AddAttributeStringString_ThrowsXmlException_GivenNameContainingSpace() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = 'test Name';
    	string value = 'test value';
    	
    	boolean result = false;
    	
    	try
    	{
    		attributeConstructor.AddAttribute(name, value);
    	}
    	catch(XmlException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
    
    static testMethod void AddAttributeStringString_ReturnsSOAPAttributeJLRTestNameTestValue_GivenNameTestNameAndValueTestValue() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = 'testName';
    	string value = 'test value';
    	
    	string result = attributeConstructor.AddAttribute(name, value);
    	
    	System.assertEquals('<jlr:testName>test value</jlr:testName>', result);
    }
    
    
    static testMethod void AddAttributeStringBoolean_ReturnsEmptyString_GivenEmptyName() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = '';
    	boolean value = true;
    	
    	string result = attributeConstructor.AddAttribute(name, value);
    	
    	System.assertEquals('', result);
    }
    
    static testMethod void AddAttributeStringBoolean_ReturnsEmptyString_GivenNullValue() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = 'testName';
    	boolean value = null;
    	
    	string result = attributeConstructor.AddAttribute(name, value);
    	
    	System.assertEquals('', result);
    }
    
    static testMethod void AddAttributeStringBoolean_ThrowsXmlException_GivenNameContainingSpace() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = 'test Name';
    	boolean value = true;
    	
    	boolean result = false;
    	
    	try
    	{
    		attributeConstructor.AddAttribute(name, value);
    	}
    	catch(XmlException e)
    	{
    		result = true;
    	}
    	
    	System.assert(result);
    }
    
    static testMethod void AddAttributeStringBoolean_ReturnsSOAPAttributeJLRTestName1_GivenNameTestNameAndValueTrue() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = 'testName';
    	boolean value = true;
    	
    	string result = attributeConstructor.AddAttribute(name, value);
    	
    	System.assertEquals('<jlr:testName>1</jlr:testName>', result);
    }
    
    static testMethod void AddAttributeStringBoolean_ReturnsSOAPAttributeJLRTestName0_GivenNameTestNameAndValueFalse() {
    	SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
    	
    	string name = 'testName';
    	boolean value = false;
    	
    	string result = attributeConstructor.AddAttribute(name, value);
    	
    	System.assertEquals('<jlr:testName>0</jlr:testName>', result);
    }
}