public class JUDAAN_Grade2Apex 
{
    public class Data 
    {
        public Integer CAR_CD;
        public Integer GRADE_CD;
        public String GRADE_NAME;
    }
    public List<Data> data; 
    public static JUDAAN_Grade2Apex parse(String json) 
    {
        return (JUDAAN_Grade2Apex) System.JSON.deserialize(json, JUDAAN_Grade2Apex.class);
    }
}