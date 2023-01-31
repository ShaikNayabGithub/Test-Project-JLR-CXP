public class JUDAAN_Brand2Apex { 
     
        public List<Data> data; 

    public class Data {
        public Integer BRAND_CD;
        public String BRAND_NAME;
    }

    
    public static JUDAAN_Brand2Apex parse(String json) {
        return (JUDAAN_Brand2Apex) System.JSON.deserialize(json, JUDAAN_Brand2Apex.class);
    }
}