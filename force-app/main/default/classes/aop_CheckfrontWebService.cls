@RestResource(urlMapping='/checkfrontwebservice')
global class aop_CheckfrontWebService {
    @HttpPost
    global static void doPost()
    {
        RestRequest restReq = RestContext.request;
        string bookingString = restReq.requestBody.toString();
        string removeAt = bookingString.replace('@attributes', 'attributes');
        removeAt = removeAt.replace('{}', '""');
        removeAt = removeAt.replace('taxes":""', 'taxes":{}');
        system.debug(removeAt);
        JSONParser parser = JSON.createParser(removeAt);     
        aop_Checkfront newCheckfrontBooking = (aop_Checkfront)parser.readValueAs(aop_Checkfront.class);
        aop_CheckfrontLogic businessLogic = new aop_CheckfrontLogic();
        businessLogic.HandleCheckfrontJSON(newCheckfrontBooking);
    }

    global class aop_Order {
        public Map<string,string> attributes;
        public String sub_total;
        public String tax_total;
        public String paid_total;
        public String total;
        public aop_Taxes taxes;
        public aop_Items items;
    }

    global class aop_Meta {
        public String note;
        public String mobile_device;
        public string customer_tid;
    }

    global class aop_Customer {
        public String name;
        public String email;
        public String region;
        public String address;
        public String city;
        public String country;
        public String phone;
        public String postal_zip;
    }


    global class aop_Tax {
        public Map<string,string> attributes;
        public String name;
        public String amount;
    }

    global class aop_Booking {
        public Map<string,string> attributes;
        public String status;
        public String code;
        public String created_date;
        public String staff_id;
        public String source_ip;
        public String start_date;
        public String end_date;
        public aop_Customer customer;
        public aop_Meta meta;
        public aop_Order order;
    }

    global class aop_Item {
        public Map<string,string> attributes;
        public String start_date;
        public String end_date;
        public String sku;
        public string slip;
        public String package_id;
        public String status;
        public String total;
        public String tax_total;
        public String qty;
    }

    global class aop_Taxes {
        public aop_Tax tax;
    }



    global class aop_Items {
        public aop_Item item;
    }

    global class aop_Checkfront
    {
        public Map<string,string> attributes;
        public aop_Booking booking;
    }

}