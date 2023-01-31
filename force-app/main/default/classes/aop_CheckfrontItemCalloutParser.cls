public class aop_CheckfrontItemCalloutParser {
    Public Class aop_Container
    {
        public string version;
        public integer account_id;
        public string host_id;
        public string name;
        public Map<string,string> locale;
        public aop_CalloutRequest request;
        public aop_CalloutQuery query;
        public aop_CalloutItem item;
        public Map<string, aop_CalloutEvent> events;
    }

        Public Class aop_CalloutRequest
    {
        public string status;
        public string resource;
        public string aopid;
        public string method;
        public integer records;
        public integer aoplimit;
        public integer page;
        public integer pages;
        public double aoptime;
    }

            Public Class aop_CalloutQuery
    {
        public string start_date;
        public string end_date;
        public boolean discount_code;
        public boolean exclude;
        public Map<string, integer> param;
        public string local_end_date;
        public string local_start_date;
    }

                Public Class aop_CalloutItem
    {
        public string unit;
        public integer item_id;
        public string sku;
        public string url;
        public integer lock;
        public string visibility;
        public string name;
        public integer pos;
        public string summary;
        public string details;
        public aop_CalloutMeta meta;
        public integer stock;
        public integer unlimited;
        public Map<string, aop_CalloutParam> param;        
    }

                    Public Class aop_CalloutMeta
    {
        public string display_mode;
        public string item_package_rate;
        public integer delay;
    }

                        Public Class aop_CalloutParam
    {
        public integer lock;
        public integer price;
        public string lbl;
        public integer qty;
        public integer range;
        public integer hide;
        public integer customer_hide;
        public integer req;
        public integer def;
        public string MIN;
        public string MAX;
    }

                            Public Class aop_CalloutEvent
    {
        public string name;
        public string start_date;
        public string end_date;
    }


}