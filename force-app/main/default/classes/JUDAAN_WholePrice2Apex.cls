public class JUDAAN_WholePrice2Apex 
{ 
    public List<Data> data; 
    public class Data 
    {
        public Integer CAT_ID;
        public Integer YYYYMM;
        public Integer PRICE_0;
        public Integer PRICE_1;
        public Integer PRICE_2;
        public Integer PRICE_3;
        public Integer PRICE_4;
        public Integer PRICE_5;
        public Integer PRICE_6;
        public Integer PRICE_7;
        public Integer PRICE_8;
        public Integer PRICE_9;
        public Integer PRICE_10;
        public Integer PRICE_11;
        public Integer PRICE_12;
        public Integer PRICE_13;
        public Integer PRICE_14;
        public Integer PRICE_15;
        public Integer PRICE_16;
        public Integer PRICE_17;
        public Integer PRICE_18;
        public Integer PRICE_19;
        public Integer PRICE_20;
        public Integer PRICE_21;
        public Integer PRICE_22;
        public Integer PRICE_23;
        public Integer PRICE_24;
        public Integer PRICE_25;
        public Integer PRICE_26;
        public Integer PRICE_27;
        public Integer PRICE_28;
        public Integer PRICE_29;
        public Integer PRICE_30;
        public Integer PRICE_31;
        public Integer PRICE_32;
        public Integer PRICE_33;
        public Integer PRICE_34;
        public Integer PRICE_35;
        public Integer PRICE_36;
    }
    public static JUDAAN_WholePrice2Apex parse(String json) 
    {
        return (JUDAAN_WholePrice2Apex) System.JSON.deserialize(json, JUDAAN_WholePrice2Apex.class);
    }
}