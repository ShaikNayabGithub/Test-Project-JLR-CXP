public class aop_CheckfrontItemParser {
    Public Class aop_ItemContainer
    {
        public string version;
        public string host;
        public string type;
        public string action;
        public aop_NewItem item;
    }

        Public Class aop_NewItem
    {
        //public string unit;
        public integer item_id;
        public string sku;
        public string url;
        //public integer lock;
        public string visibility;
        public string name;
        //public integer pos;
        public string summary;
        //public string details;
        public aop_ItemMeta meta;
        //public integer stock;
        //public integer unlimited;
        //public aop_ItemVideo video;
        public aop_Images image;
        public integer category_id;
        //public aop_Rules rules;
        //public integer rated;
        //public string product_group_type;
        //public string product_group_children;
        //public string type;
    }

            Public Class aop_ItemMeta
    {
        //public string display_mode;
        //public string item_package_rate;
        public aop_ItemLocation location;
    }

                Public Class aop_ItemVideo
    {
        //public string aopid;
        //public integer start;
    }

    Public Class aop_Images
    {
        public aop_Image one;
        public aop_Image two;
        public aop_Image three;
        public aop_Image four;
        public aop_Image five;
    }

    Public Class aop_Image
    {
        public integer x1;
        public integer x2;
        public integer y1;
        public integer y2;
        public string src;
    }
    
    Public Class aop_ItemLocation
    {
        public string str;
        public double lat;
        public double lng;
        public string title;
        public string description;
        public string link_txt;
        public string link;
        public integer zoom;
    }

}