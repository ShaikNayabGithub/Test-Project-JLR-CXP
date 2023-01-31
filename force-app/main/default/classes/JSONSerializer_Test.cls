@isTest
public class JSONSerializer_Test {
	static testMethod void Serialize_ReturnsListSizeThree_GivenThreeDummyObjectsAndIntegerThirty() 
    {
    	JSONSerializer serializer = new JSONSerializer();
    	List<DummyObject> input = new List<DummyObject>();
    	DummyObject object1 = new DummyObject();
    	input.Add(object1);
    	input.Add(object1);
    	input.Add(object1);

    	List<String> result = serializer.Serialize(input, 30);

    	System.assertEquals(3, result.size());
    }


    private class DummyObject implements I_Serializable {
    	String A;
    	String B;
    	
    	public Boolean IsEmpty()
        {
        	return false;
        }
    }
}