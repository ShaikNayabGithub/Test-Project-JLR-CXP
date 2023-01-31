@isTest
public class JSONDeserializer_Test {
    static testMethod void DeserializeIterable_ReturnsMapTwoLeadOne_GivenLeadNameOneAndTwoAndThree() 
    {
    	JSONDeserializer deserializer = new JSONDeserializer();
    	
    	String name = JSON.serialize(new List<Integer>{1,2,3});
    	String fieldName = Lead.FirstName.getDescribe().getName();
    	
    	List<Lead> sobjects = new List<Lead>();
    	Lead lead1 = new Lead();
    	lead1.put(fieldName, name);
    	sobjects.add(lead1);
    	
    	Map<Object, SObject> result = deserializer.DeserializeIterable(sobjects, fieldName, Type.forName('List<Integer>'));
    	
    	System.AssertEquals(lead1, result.get(2));
    }
    
    static testMethod void DeserializeSingle_ReturnsEmptyString_GivenEmptyStringAndTypeListInteger() 
    {
    	JSONDeserializer deserializer = new JSONDeserializer();
    	
    	Object result = deserializer.DeserializeSingle('', Type.forName('List<Integer>'));
    	
    	System.AssertEquals(0, ((List<Integer>)result).Size());
    }
    
    static testMethod void DeserializeSingle_ReturnsListContainingTwo_GivenSerializedListOneTwoThreeAndTypeListInteger() 
    {
    	JSONDeserializer deserializer = new JSONDeserializer();
    	
    	String serializedList = JSON.serialize(new List<Integer>{1,2,3});
    	Object result = deserializer.DeserializeSingle(serializedList, Type.forName('List<Integer>'));
    	
    	System.AssertEquals(2, ((List<Integer>)result)[1]);
    }
}