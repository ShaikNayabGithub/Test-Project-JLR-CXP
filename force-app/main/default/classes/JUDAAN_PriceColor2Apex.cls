public class JUDAAN_PriceColor2Apex 
{
    public List<Data> data; 
    public class Data 
    {
        public Integer COLOR_ID;
        public String COLOR_NM;
    }
    public static JUDAAN_PriceColor2Apex parse(String json) 
    {
        return (JUDAAN_PriceColor2Apex) System.JSON.deserialize(json, JUDAAN_PriceColor2Apex.class);
    }
}