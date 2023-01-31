public class JUDAAN_CarType2Apex {

    
        public List<Data> data; 

    public class Data {
        public Integer BRAND_CD;
        public Integer CAR_CD;
        public String CAR_NAME;
    }

    
    public static JUDAAN_CarType2Apex parse(String json) {
        return (JUDAAN_CarType2Apex) System.JSON.deserialize(json, JUDAAN_CarType2Apex.class);
    }
}