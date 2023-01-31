public class JUDAAN_Category2Apex 
{
    public List<Data> data; 
    public class Data 
    {
        public Integer CAT_ID;
        public Integer BRAND_CD;
        public String BRAND_NAME;
        public String CAR_CD;
        public String CAR_NAME;
        public String KATASHIKI_ETC;
        public Integer TYPE_CD;
        public String TYPE_NAME;
        public String KATASHIKI;
        public String YEAR_STR;
        public String PRICE;
        public String YEAR_CD;
        public String DEBUT_YEAR;
        public String END_YEAR;
        public Integer GRADE_CD;
        public String GRADE_NAME;
        public Integer DOOR_CD;
        public String DOOR_NAME;
        public String EXHAUST_CD;
        public String EXHAUST_NAME;
        public String SHIFT_NAME;
        public String TEIIN_CD;
        public String TEIIN_NAME;
        public String DRIVE_CD;
        public String DRIVE_NAME;
        public String HAIBAI_DATE_NEW;
        public String NAVI;
        public String MEDIA;
        public String LS;
        public String SR;
        public String AW;
        public String HANDLE_ID;
        public String HANDLE_NAME;
        public String D_MODEL_CYCLE_ID;
        public String FMC_MC_YEAR;
        public String FMC_MC_MONTH;
        public Integer BODY_CD;
        public String BODY_NAME;
        public Integer YEAR_NUM;
    }
    public static JUDAAN_Category2Apex parse(String json) 
    {
        return (JUDAAN_Category2Apex) System.JSON.deserialize(json, JUDAAN_Category2Apex.class);
    }
}