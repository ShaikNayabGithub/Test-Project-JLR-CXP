public class JUDAAN_Year2Apex 
{
    public List<Data> data;
    public class Data 
    {
        public Integer CAR_CD;
        public Integer TYPE_CD;
        public String TYPE_NM;
        public String TYPE_NM2;
        public Integer GRADE_CD;
        public Integer YEAR_NUM;
        public String S_YEAR_NUM;
    }
    public static JUDAAN_Year2Apex parse(String json) 
    {
        return (JUDAAN_Year2Apex) System.JSON.deserialize(json, JUDAAN_Year2Apex.class);
    }
}