public class SF_MetadataAPIPort_Factory {
    public SF_MetadataAPI.MetadataPort Build()
    {
    	SF_MetadataAPI.MetadataPort port = new SF_MetadataAPI.MetadataPort();
    	
    	port.SessionHeader = new SF_MetadataAPI.SessionHeader_element();
    	
    	port.AllOrNoneHeader = new SF_MetadataAPI.AllOrNoneHeader_element();
    	port.AllOrNoneHeader.allOrNone = false;
    	
    	return port;
    }
}