public class aop_CheckfrontCalloutBookingParser {
    Public aop_CheckfrontCalloutBookingParser()
	{

	}
    Public Class aop_Container
    {
        public string version;
        public integer account_id;
        public string host_id;
        public string name;
        public Map<string,string> locale;
        public aop_CalloutRequest request;
        public aop_CalloutBooking booking;
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

            Public Class aop_CalloutBooking
    {
        public string aopid;
        public integer booking_id;
        public integer account_id;
        public string status_id;
        public integer created_date;
        public integer checkin;
        public integer checkout;
        public string customer_name;
        public string customer_address;
        public string customer_city;
        public string customer_region;
        public string customer_postal_zip;
        public string customer_country;
        public string customer_email;
        public string customer_phone;
        public string customer_id;
        public string token;
        public string currency_id;
        public aop_CalloutMeta meta;
        public aop_CalloutFields fields;
        public string tid;
        public integer start_date;
        public integer end_date;
        //public string[] taxes;
        public string amount_paid;
        public string amount_due;
        public string tax_total;
        public string tax_inc_total;
        public string sub_total;
        public string total;
        public aop_CalloutItems items;
        public string[] transactions;
    }

                Public Class aop_CalloutMeta
    {
        public string customer_tid;
        public string customfield1;
        public string customer_account_id;
        public string mobile_device;
    }

                    Public Class aop_CalloutFields
    {
        public Map<string,string> customer_tid;
    }

                        Public Class aop_CalloutItems
    {
        public aop_CalloutItem one;
    }

                            Public Class aop_CalloutItem
    {
        public string status_id;
        public integer aopid;
        public string sku;
        public string name;
        public integer start_date;
        public integer end_date;
        public integer qty;
        public string tax_total;
        public string tax_inc_total;
        public string item_total;
        public string sub_total;
        public string total;
        public string summary;
        public aop_CalloutParam param;
        public string[] transactions;
    }

                                Public Class aop_CalloutParam
    {

    }

}