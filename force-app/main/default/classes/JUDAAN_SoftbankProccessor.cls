public class JUDAAN_SoftbankProccessor
{
    public  string merchant_id { get; set; }
    public  string service_id {set;get;}
    public  string cust_code {get; set; }
    public  string order_id {get; set; }
    public  string item_id {get; set; }
    public  string item_name {get; set; }
    public  string tax {get; set; }
    public  string amount {get; set; }
    public  string free1 {get; set; }
    public  string free2 {get; set; }
    public  string free3 {get; set; }
    public  string order_rowno {get; set; }
    public  string sps_cust_info_return_flg {get; set; }
    public  string cust_manage_flg {get; set;} 
    public  string encrypted_flg { get; set; }
    public  string request_date {get; set; }
    public  string processing_datetime { get; set; }
    public  string limit_second {get; set; }
    public  string sps_hashcode { get; set; }    
    public  string hashkey {get; set; }
    public  string result_str { get; set; }
    public  string transaction_id { get; set; }
    public  string tracking_id { get; set; } 
    public  static string TheTrackingId { get; set; }
    public  static boolean DoSucceed { get; set; }
    public  string token { get; set; }
    public  string token_key { get; set; }
    public  static Integer TIME_OUT = Integer.valueOf(system.label.c_timeout_softbank);
    public  string getTax()
    {
        string taxRate = system.label.c_tax;
        integer amount = Integer.valueOf(system.label.c_deposit_amount);
        integer tax    = Integer.valueOf(Decimal.valueOf(taxRate) * amount);
        return String.valueOf(tax);
    }
    public JUDAAN_SoftbankProccessor(string customerId, string vehicleName, string vehicleVIN, string merchant_id, string service_id, string token, string tokenKey)
    {
        this.merchant_id         = merchant_id == null ? system.label.c_merchant_id : merchant_id;
        this.service_id          = service_id == null ? system.label.c_service_id : service_id;
        cust_code                = customerId;
        order_id                 = customerId + '-' + Datetime.now().format('yyyyMMdd HHmmss').remove(' ');
        item_id                  = trim(vehicleVIN, system.label.c_item_id_limit);
        item_name                = trim(vehicleName, system.label.c_item_name_limit);
        tax                      = getTax();
        amount                   = system.label.c_deposit_amount;
        free1                    = '';
        free2                    = '';
        free3                    = '';
        order_rowno              = '';
        sps_cust_info_return_flg = '1'; 
        this.token               = token;
        this.token_key           = tokenKey;
        cust_manage_flg          = '0';
        encrypted_flg            = '1';
        request_date             = Datetime.now().format('yyyyMMdd HHmmss',  'Asia/Tokyo').remove(' ');
        limit_second             = '';
        hashkey                  = system.label.c_softbank_hashkey;
    }
    
    public void doShiftJISVariables()
    {
          merchant_id              = EncodingUtil.urlEncode(merchant_id , 'Shift-JIS').replace('%','');
          service_id               = EncodingUtil.urlEncode(service_id, 'Shift-JIS').replace('%','');
          cust_code                = EncodingUtil.urlEncode(cust_code, 'Shift-JIS').replace('%','');
          order_id                 = EncodingUtil.urlEncode(order_id, 'Shift-JIS').replace('%','');
          item_id                  = EncodingUtil.urlEncode(item_id, 'Shift-JIS').replace('%','');
          item_name                = EncodingUtil.urlEncode(item_name, 'Shift-JIS').replace('%','');
          tax                      = EncodingUtil.urlEncode(tax, 'Shift-JIS').replace('%','');
          amount                   = EncodingUtil.urlEncode(amount, 'Shift-JIS').replace('%','');
          free1                    = EncodingUtil.urlEncode(free1, 'Shift-JIS').replace('%','');
          free2                    = EncodingUtil.urlEncode(free2, 'Shift-JIS').replace('%','');
          free3                    = EncodingUtil.urlEncode(free3, 'Shift-JIS').replace('%','');
          order_rowno              = EncodingUtil.urlEncode(order_rowno, 'Shift-JIS').replace('%','');
          sps_cust_info_return_flg = EncodingUtil.urlEncode(sps_cust_info_return_flg , 'Shift-JIS').replace('%',''); 
          token                    = EncodingUtil.urlEncode(token, 'Shift-JIS').replace('%','');
          token_key                = EncodingUtil.urlEncode(token_key, 'Shift-JIS').replace('%','');
          cust_manage_flg          = EncodingUtil.urlEncode(cust_manage_flg, 'Shift-JIS').replace('%','');
          encrypted_flg            = EncodingUtil.urlEncode(encrypted_flg, 'Shift-JIS').replace('%','');
          request_date             = EncodingUtil.urlEncode(request_date, 'Shift-JIS').replace('%','');
          limit_second             = EncodingUtil.urlEncode(limit_second, 'Shift-JIS').replace('%','');
          hashkey                  = EncodingUtil.urlEncode(hashkey, 'Shift-JIS').replace('%','');  
    }
    
    public void connectVariables()
    {
         result_str =  merchant_id +
          service_id               +
          cust_code                +
          order_id                 +
          item_id                  +
          item_name                +
          tax                      +
          amount                   +
          free1                    +
          free2                    +
          free3                    +
          order_rowno              +
          sps_cust_info_return_flg + 
          token                    +
          token_key                + 
          cust_manage_flg          +
          encrypted_flg            +
          request_date             +
          limit_second             +
          hashkey ;
    }
    
    public String  setPostData()
    {
         String postdata; 
         postdata = '<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>' + 
         '<sps-api-request id=\"ST01-00131-101\">' + 
            '<merchant_id>'                 + merchant_id              + '</merchant_id>'               +
            '<service_id>'                  + service_id               + '</service_id>'                + 
            '<cust_code>'                   + cust_code                + '</cust_code>'                 +
            '<order_id>'                    + order_id                 +  '</order_id>'                 +
            '<item_id>'                     + item_id                  +  '</item_id>'                  +
            '<item_name>'                   + EncodingUtil.base64Encode(Blob.valueOf(item_name))        + '</item_name>'  +
            '<tax>'                         + tax                      +  '</tax>'                      +
            '<amount>'                      + amount                   + '</amount>'                    +
            '<free1>'                       + EncodingUtil.base64Encode(Blob.valueOf(free1))            + '</free1>'      +
            '<free2>'                       + EncodingUtil.base64Encode(Blob.valueOf(free2))            + '</free2>'      +
            '<free3>'                       + EncodingUtil.base64Encode(Blob.valueOf(free3))            + '</free3>'      +
            '<order_rowno>'                 + order_rowno              + '</order_rowno>'               +
            '<sps_cust_info_return_flg>'    + sps_cust_info_return_flg + '</sps_cust_info_return_flg>'  +
            '<dtls>'                        + 
            '</dtls>'                       +  
            '<pay_option_manage>'           + 
            '<token>'                       + token                    + '</token>'                     +
            '<token_key>'                   + token_key                + '</token_key>'                 +
            '<cust_manage_flg>'             + cust_manage_flg          + '</cust_manage_flg>'           +
            '</pay_option_manage>'          +
            '<encrypted_flg>'               + encrypted_flg            + '</encrypted_flg>'             +
            '<request_date>'                + request_date             + '</request_date>'              +
            '<limit_second>'                + limit_second             + '</limit_second>'              +
            '<sps_hashcode>'                + sps_hashcode             + '</sps_hashcode>'              +
        '</sps-api-request>';
         return postdata;
    }
    
    public String doPayment()
    { 
       // Shift_JIS変換
        doShiftJISVariables();
        connectVariables();
        Blob result_blob = Blob.valueOf(result_str);
        sps_hashcode =  EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', result_blob));  
        String postdata = setPostData();
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(system.label.c_softbank_server); 
        string Id = merchant_id + service_id;
        string pwd = hashkey;
        Blob headerValue = Blob.valueOf(Id + ':' + pwd);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(postdata);
        req.setMethod('POST'); 
        req.setTimeout(TIME_OUT);
        HttpResponse res = h.send(req);
        String xml = res.getBody();
        string rawResponse = xml;
        XmlStreamReader reader = res.getXmlStreamReader();
        string result = JUDAANHttpServiceUtil.readXMLResponse(reader,'res_result');
        reader = res.getXmlStreamReader();
        string err;
        if (result == 'OK')
        {
            reader = res.getXmlStreamReader();
            transaction_id = JUDAANHttpServiceUtil.readXMLResponse(reader, 'res_sps_transaction_id'); 
            reader = res.getXmlStreamReader();
            tracking_id = JUDAANHttpServiceUtil.readXMLResponse(reader, 'res_tracking_id'); 
            TheTrackingId = tracking_id;
            return confirm();            
        }
        else
        {
            err = JUDAANHttpServiceUtil.readXMLResponse(reader, 'res_err_code');
            DoSucceed = false;
            return result = err;
        } 
    }
    
    
    public String confirm()
    {
        transaction_id              = EncodingUtil.urlEncode(transaction_id , 'Shift-JIS').replace('%','');
        tracking_id                 = EncodingUtil.urlEncode(tracking_id, 'Shift-JIS').replace('%','');
        request_date                = EncodingUtil.urlEncode(Datetime.now().format('yyyyMMdd HHmmss',  'Asia/Tokyo').remove(' '), 'Shift-JIS').replace('%','');
    
        String result_str = merchant_id         +
                            service_id          +
                            transaction_id      +
                            tracking_id         +
                            request_date        +
                            limit_second        +
                            hashkey; 
        Blob result_blob = Blob.valueOf(result_str);
        sps_hashcode =  EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', result_blob));
         String postdata;
         postdata = '<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>' + 
         '<sps-api-request id=\"ST02-00101-101\">' + 
            '<merchant_id>'                 + merchant_id              + '</merchant_id>'          +
            '<service_id>'                  + service_id               + '</service_id>'         + 
            '<sps_transaction_id>'          + transaction_id           + '</sps_transaction_id>' +
            '<tracking_id>'                 + tracking_id              +  '</tracking_id>'       +
            '<request_date>'                + request_date                 + '</request_date>'       +
            '<limit_second>'                + limit_second             + '</limit_second>'       +
            '<sps_hashcode>'                + sps_hashcode             + '</sps_hashcode>'       +
        '</sps-api-request>';
     
      
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(system.label.c_softbank_server); 
        string Id = merchant_id + service_id;
        string pwd = hashkey;
        Blob headerValue = Blob.valueOf(Id + ':' + pwd);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(postdata );
        req.setMethod('POST'); 
        req.setTimeout(TIME_OUT);
        HttpResponse res = h.send(req);
        String xml = res.getBody();
        string rawResponse = xml;
        XmlStreamReader reader = res.getXmlStreamReader();
        string result = JUDAANHttpServiceUtil.readXMLResponse(reader,'res_result');
        reader = res.getXmlStreamReader();
        string err;
        if(result == 'OK')
        { 
            result = 'profit ok';
            result = TheTrackingId;
            DoSucceed = true;
        }
        else
        {
            err = JUDAANHttpServiceUtil.readXMLResponse(reader, 'res_err_code');
            result = err;
            DoSucceed = false;
        }
        return result;
    }
    
    /*public String doProfit()
    {
        merchant_id         = EncodingUtil.urlEncode(merchant_id , 'Shift-JIS').replace('%','');
        service_id          = EncodingUtil.urlEncode(service_id , 'Shift-JIS').replace('%','');
        transaction_id      = EncodingUtil.urlEncode(transaction_id , 'Shift-JIS').replace('%','');
        tracking_id         = EncodingUtil.urlEncode(tracking_id, 'Shift-JIS').replace('%',''); 
        processing_datetime = EncodingUtil.urlEncode(Datetime.now().format('yyyyMMdd HHmmss',  'Asia/Tokyo').remove(' '), 'Shift-JIS').replace('%','');
        amount              = EncodingUtil.urlEncode(amount, 'Shift-JIS').replace('%','');
        request_date        = EncodingUtil.urlEncode(Datetime.now().format('yyyyMMdd HHmmss',  'Asia/Tokyo').remove(' '), 'Shift-JIS').replace('%','');
        limit_second        = EncodingUtil.urlEncode(limit_second, 'Shift-JIS').replace('%','');
        hashkey             = EncodingUtil.urlEncode(hashkey, 'Shift-JIS').replace('%','');
    
        String result_str = merchant_id              +
                            service_id               +
                            transaction_id           +
                            tracking_id              +
                            processing_datetime      +
                            amount                   +
                            request_date             + 
                            limit_second             +
                            hashkey; 
        Blob result_blob = Blob.valueOf(result_str);
        sps_hashcode =  EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', result_blob)); 
        String postdata;
        postdata = '<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>' + 
                     '<sps-api-request id=\"ST02-00201-101\">' + 
                        '<merchant_id>'                 + merchant_id              + '</merchant_id>'                 +
                        '<service_id>'                  + service_id               + '</service_id>'                  + 
                        '<sps_transaction_id>'          + transaction_id           + '</sps_transaction_id>'          +
                        '<tracking_id>'                 + tracking_id              +  '</tracking_id>'                +
                        '<processing_datetime>'         + processing_datetime      + '</processing_datetime>'         + 
                        '<pay_option_manage><amount>'   + amount                   + '</amount></pay_option_manage>'  + 
                        '<request_date>'                + request_date             + '</request_date>'                      +
                        '<limit_second>'                + limit_second             + '</limit_second>'                +
                        '<sps_hashcode>'                + sps_hashcode             + '</sps_hashcode>'                +
                    '</sps-api-request>';
     
      
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(system.label.c_softbank_server); 
        string Id = merchant_id + service_id;
        string pwd = hashkey;
        Blob headerValue = Blob.valueOf(Id + ':' + pwd);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(postdata );
        req.setMethod('POST'); 
        req.setTimeout(TIME_OUT);
        HttpResponse res = h.send(req);
        String xml = res.getBody();
        string rawResponse = xml;
        XmlStreamReader reader = res.getXmlStreamReader();
        string result = JUDAANHttpServiceUtil.readXMLResponse(reader,'res_result');
        reader = res.getXmlStreamReader();
        string err;
        if(result == 'OK')
        { 
            result = 'profit ok';
            result = TheTrackingId;
            DoSucceed = true;
        }
        else
        {
            err = JUDAANHttpServiceUtil.readXMLResponse(reader, 'res_err_code');
            result = err;
        }
        return result;
    } */
    
    public String trim(String str, String expectedLength)
    {
        Integer expectedSize = Integer.valueOf(expectedLength);
        if(str.length() > expectedSize )
        {
            return str.substring(0, expectedSize);
        }
        return str;
    }
}