@isTest
global class JUDAAN_MockHttpResponseGenerator implements HttpCalloutMock {
    public static Integer brand { get; set; }
    public static Integer model { get; set; }
    public static Integer grade { get; set; }
    public static Integer year { get; set; }
    public static String handle_id { get; set; }
    public static String year_num { get; set; }
    public static String cate_id { get; set; }
    public static Integer color { get; set; }
    public static Integer mileage { get; set; }
    public static String MyVehicle { get; set; }
    public static String plan { get; set; }
    public static String step { get; set; }
    
    public static Boolean NoYear { get; set; }
    public static Boolean NoColor { get; set; }
    public static Boolean FinanceNG { get; set; }
    public static Boolean PaymentNG { get; set; }

    public static final String make = 'JAGU';
    public static final String smodel = 'XJ';
    public static final String stype = 'PS';
    public static final String syear = '2016';
    public static final String vehicle = 'JAGU16AI';
    public static final String smileage = '50000';

    public static final String RedbookEndpoint = 'https://www.redbookasiapacific.com/rbnetv2/rbnet.php';
    public static final String MakeBody = 'userid=JLR&password=Redbook&silo=car&action=makes';
    public static final String ModelBody = 'userid=JLR&password=Redbook&silo=car&action=families&makecode=' + make;
    public static final String YearBody = 'userid=JLR&password=Redbook&silo=car&action=years&makecode=' + make + '&familycode=' + smodel + '&vehicletype=' + stype;
    public static final String VehicleBody = 'userid=JLR&password=Redbook&silo=car&action=vehicles&makecode=' + make + '&familycode=' + smodel+ '&vehicletype=' + stype + '&year=' + syear;
    public static final String PriceBody = 'userid=JLR&password=Redbook&silo=car&action=autocalc&rbc=' + vehicle;

    public static final String PaypalEndpointTest = System.Label.SGPaypal_endpoint_test;
    public static final String PaypalEndpointProd = System.Label.SGPaypal_endpoint_prod;
    
    global HTTPResponse respond(HTTPRequest req) { 
        HttpResponse res = new HttpResponse(); 
        String jsonStr;
        String backCalculateEndpoint = system.label.JACCS_BACK_API_URL;
        String normalCalculateEndpoint = system.label.JACCS_NORMAL_API_URL;
        String protoServer = system.label.Proto_Server;
        String protoSession = system.label.Proto_Session;

        protoServer += '/grade';
        String brandEndpoint = protoServer + '/1.0/brand_h1.json?session_id=' + protoSession;
        brand = 2510;
        String modelEndpoint = protoServer + '/1.0/cartype_h1.json?session_id=' + protoSession + '&brand_cd=' + brand;

        Model = 25101512;
        String gradeEndpoint = protoServer + '/1.0/grade.json?session_id=' + protoSession + '&car_cd=' + Model;

        Grade = 16;
        String yearEndpoint = protoServer + '/1.0/year_t1.json?session_id=' + protoSession + '&car_cd=' + Model + '&grade_cd=' + Grade;

        Year = 2014;
        String cateEndpoint = protoServer + '/1.0/catalog_h1.json?session_id=' + protoSession + '&brand_cd=' + brand + '&car_cd=' + Model + '&year_s=' + Year + '&year_e=' + Year;

        handle_id = '0';
        year_num = '2014';
        cate_id = '10087905';
        String  colorEndpoint = protoServer + '/1.0/bb_k_color.json?session_id=' + protoSession + '&cat_id=' + cate_id + '&syear=' + year_num + '&handle_id=' + handle_id;
        
        Color = 3001;
        Mileage = 20000; 
        String defaultPriceEndpoint = system.label.Proto_Server + '/price/1.0/wholesaleczprice_revision_h1.json?session_id=' + protoSession + '&cat_id=' + cate_id + '&syear=' + year_num + '&handle_id=' + handle_id + '&color_id=' + Color +  '&kyori=' + Mileage + '&margin_rate=' + system.label.c_default_proto_margin_rate + '&margin_bottom=' + system.label.c_default_proto_margin_bottom + '&margin_top=' + system.label.c_default_proto_margin_top;
        String JLRPriceEndpoint = system.label.Proto_Server + '/price/1.0/wholesaleczprice_revision_h1.json?session_id=' + protoSession + '&cat_id=' + cate_id + '&syear=' + year_num + '&handle_id=' + handle_id + '&color_id=' + Color +  '&kyori=' + Mileage + '&margin_rate=' + system.label.c_proto_margin_rate + '&margin_bottom=' + system.label.c_proto_margin_bottom + '&margin_top=' + system.label.c_proto_margin_top;
        MyVehicle = 'ジャガー Fタイプ Sコンバーチブル 2014 ブラック';
        
        //system.debug('---test endpoint:' + brandEndpoint);
        
        // Finance Calculation
        if(req.getEndpoint() == backCalculateEndpoint)
        {
            jsonStr = '{"calcResult":"0","backPrice":6697000}';
        }
        if(req.getEndpoint() == normalCalculateEndpoint)
        {
            if(plan == '0')
            {
                if(!FinanceNG)
                {
                    jsonStr = '{"requestid":"abcde12345","calcResult":"0","loanPrincipal":5500000, "payment1st":100230,"paymentMonthly":98700,"bonusAdditionalCost":50000,"numOfBonus":8, "installmentsFee":239130,"installmentsTotal":5739130,"totalPayments":6239130,"paymentPeriod":60}';      
                }
                else
                {
                    jsonStr = '{"requestid": "abcds12345", "calcResult": "1", "error": "error msg"}';
                }
            }
            else
            {
                if(!FinanceNG)
                {
                    jsonStr = '{"requestid":"abcde12345","calcResult":"0","loanPrincipal":5500000, "paymentLast":5000000,"payment1st":100230,"paymentMonthly":98700,"bonusAdditionalCost":50000,"numOfBonus":8, "installmentsFee":239130,"installmentsTotal":5739130,"totalPayments":6239130,"paymentPeriod":37}';
                }
                else
                {
                    jsonStr = '{"requestid": "abcds12345", "calcResult": "1", "error": "error msg"}';                    
                }
            }
        }

        // Trade in value
        if(req.getEndpoint() == brandEndpoint)
        {
            jsonStr = '{"data":[{"BRAND_CD":1020,"BRAND_NAME":"ホンダ"},{"BRAND_CD":1005,"BRAND_NAME":"レクサス"},{"BRAND_CD":2510,"BRAND_NAME":"ジャガー"},{"BRAND_CD":2550,"BRAND_NAME":"ランドローバー"}]}';
        }

        if(req.getEndpoint() == modelEndpoint)
        {
            jsonStr = '{"data":[{"BRAND_CD":2510, "CAR_CD":25101512,"CAR_NAME":"Fタイプ"},{"BRAND_CD":2510, "CAR_CD":25102501,"CAR_NAME":"Fベース"},{"BRAND_CD":2510, "CAR_CD":25101501,"CAR_NAME":"Sタイプ"}]}';
        }

        if(req.getEndpoint() == gradeEndpoint)
        {
            jsonStr = '{"data":[{"CAR_CD":25101512,"GRADE_CD":16,"GRADE_NAME":"Sコンバーチブル"}, {"CAR_CD":25101512,"GRADE_CD":63,"GRADE_NAME":"KEI NISHIKORIエディション"}, {"CAR_CD":25101512,"GRADE_CD":53,"GRADE_NAME":"Sクーペ"}, {"CAR_CD":25101512,"GRADE_CD":23,"GRADE_NAME":"Sコンバーチブル"}]}';
        }

        if(req.getEndpoint() == yearEndpoint)
        {
            if(!NoYear)
            {
                jsonStr = '{"data":[{"CAR_CD":25101512,"TYPE_CD":13,"TYPE_NM":"J608A","TYPE_NM2":"J608A","GRADE_CD":16,"YEAR_NUM":2014,"S_YEAR_NUM":"2014(H26)"}]}}';    
            }
            else
            {
                jsonStr = '{"data":[]}';    
            }
                
        }

        if(req.getEndpoint() == cateEndpoint)
        {
            jsonStr = '{"data":[{"CAT_ID":10087905,"BRAND_CD":2510,"BRAND_NAME":"ジャガー","CAR_CD":25101512,"CAR_NAME":"Fタイプ","KATASHIKI_ETC":"","TYPE_CD":13,';
               jsonStr += '"TYPE_NAME":"J608A", "KATASHIKI":"CBA-J608A","YEAR_STR":"2014年04月～","PRICE":"1183.0","YEAR_CD":"201404","DEBUT_YEAR":"2014","END_YEAR":"2014","GRADE_CD":16,';
               jsonStr += '"GRADE_NAME":"Sコンバーチブル", "DOOR_CD":32,"DOOR_NAME":"オープン","EXHAUST_CD":"52","EXHAUST_NAME":"3.0","SHIFT_NAME":"8AT","TEIIN_CD":"2","TEIIN_NAME":"2名","DRIVE_CD":"1",';
               jsonStr += '"DRIVE_NAME":"FR", "HAIBAI_DATE_NEW":"2014/4～2014/11","NAVI":"標準","MEDIA":"HDD","LS":"標準","SR":"","AW":"19","HANDLE_ID":"0","HANDLE_NAME":"不問",';
               jsonStr += '"D_MODEL_CYCLE_ID":"1", "FMC_MC_YEAR":"2013","FMC_MC_MONTH":"5","BODY_CD":4,"BODY_NAME":"オープン・カブリオレ・コンバーチブル","YEAR_NUM":2014'; 
               jsonStr += '}]}';
        }

        if(req.getEndpoint() == colorEndpoint)
        {
            if(!NoColor)
            {
                jsonStr = '{"data":[{"COLOR_ID":3001,"COLOR_NM":"ブラック"},{"COLOR_ID":1001,"COLOR_NM":"ホワイト"},{"COLOR_ID":4021,"COLOR_NM":"シルバー"}, {"COLOR_ID":4021,"COLOR_NM":"その多色"}]}';      
            }
            else
            {
                jsonStr = '{"data":[]}';    
            }
        }
        
        if(req.getEndpoint() == defaultPriceEndpoint)
        {
            jsonStr = '{"data":[{"CAT_ID":10087905,"YYYYMM":201705, "PRICE_0":5872, "PRICE_1":5920,"PRICE_2":5677,"PRICE_3":5677,"PRICE_4":5697,"PRICE_5":5346,"PRICE_6":5346, "PRICE_7":5168,"PRICE_8":5007,"PRICE_9":5018,';
               jsonStr += '"PRICE_10":4907, "PRICE_11":4709,"PRICE_12":4797,"PRICE_13":4832,"PRICE_14":4766,"PRICE_15":4623,"PRICE_16":4635, "PRICE_17":4465,"PRICE_18":4192,"PRICE_19":4192,';
               jsonStr += '"PRICE_20":4057, "PRICE_21":4062,"PRICE_22":3968,"PRICE_23":3804,"PRICE_24":3906,"PRICE_25":3906,"PRICE_26":3861, "PRICE_27":3753,"PRICE_28":3639,"PRICE_29":3545,';
               jsonStr += '"PRICE_30":3545, "PRICE_31":3430,"PRICE_32":3337,"PRICE_33":3337,"PRICE_34":3138,"PRICE_35":3138,"PRICE_36":3199}]}';
        }
        if(req.getEndpoint() == JLRPriceEndpoint)
        {
            jsonStr = '{"data":[{"CAT_ID":10087905,"YYYYMM":201705, "PRICE_0":6872, "PRICE_1":5920,"PRICE_2":5677,"PRICE_3":5677,"PRICE_4":5697,"PRICE_5":5346,"PRICE_6":5346, "PRICE_7":5168,"PRICE_8":5007,"PRICE_9":5018,';
               jsonStr += '"PRICE_10":4907, "PRICE_11":4709,"PRICE_12":4797,"PRICE_13":4832,"PRICE_14":4766,"PRICE_15":4623,"PRICE_16":4635, "PRICE_17":4465,"PRICE_18":4192,"PRICE_19":4192,';
               jsonStr += '"PRICE_20":4057, "PRICE_21":4062,"PRICE_22":3968,"PRICE_23":3804,"PRICE_24":3906,"PRICE_25":3906,"PRICE_26":3861, "PRICE_27":3753,"PRICE_28":3639,"PRICE_29":3545,';
               jsonStr += '"PRICE_30":3545, "PRICE_31":3430,"PRICE_32":3337,"PRICE_33":3337,"PRICE_34":3138,"PRICE_35":3138,"PRICE_36":3199}]}';
        }

        // Payment
        String paymentEndpoint = system.label.c_softbank_server;
        String paymentStep1;
        String paymentStep2;
        String paymentStep3;
       
        if(req.getEndpoint() == paymentEndpoint)
        {
            res.setHeader('Content-Type', 'text/xml');
            System.debug('---request body in mock:' + req.getBody());
            if(req.getBody().contains('ST01-00131-101'))
            {
                paymentStep1 = '<sps-api-response id="ST01-00131-101"> <res_result>OK</res_result> ';
                paymentStep1 += '<res_sps_transaction_id>X1234567890123456789012345678901</res_sps_transaction_id> <res_tracking_id>11111111111111</res_tracking_id> <res_pay_method_info>';
                paymentStep1 +='<cc_company_code>99665</cc_company_code> <cardbrand_code>J</cardbrand_code> <recognized_no>123456</recognized_no> </res_pay_method_info> <res_sps_info><res_sps_cust_no>111111112222</res_sps_cust_no> <res_sps_payment_no>111</res_sps_payment_no> </res_sps_info>';
                paymentStep1 += '<res_process_date>20120620144317</res_process_date><res_err_code/><res_date>20120620144318</res_date></sps-api-response>';        
                jsonStr = paymentStep1; 
               
            }
            if(req.getBody().contains('ST02-00101-101'))
            {
                paymentStep2 = '<sps-api-response id="ST02-00101-101"> <res_result>OK</res_result> ';
                paymentStep2 += '<res_sps_transaction_id>X1234567890123456789012345678901</res_sps_transaction_id>';
                paymentStep2 += '<res_process_date>20120620144317</res_process_date><res_err_code/><res_date>20120620144318</res_date></sps-api-response>';
                jsonStr = paymentStep2;
            }
        } 
        system.debug('--jlr endpoint:' + JLRPriceEndpoint);
        system.debug('---endpoint:' + req.getEndpoint());
        system.debug('---json:' + jsonStr);
        



        // SG Redbook Trade in 
        String makeStr;
        String modelStr;
        String yearStr;
        String vehicleStr;
        String priceStr;
        system.debug('---req body:' + req.getBody() + '---endpoint:' + req.getEndpoint());
        system.debug('---make body:' + MakeBody);
        if(req.getBody() == MakeBody)
        {
            makeStr = '<dataroot><make><makecode>JAGU</makecode><description>Jaguar</description><latestyear>2018</latestyear><vehicletype>PS,SV</vehicletype></make>';
            makeStr += '<make><makecode>Land</makecode><description>Land Rover</description><latestyear>2018</latestyear><vehicletype>PU,SV</vehicletype></make></dataroot>';
            jsonStr = makeStr;
        }

        if(req.getBody() == ModelBody)
        {
            modelStr = '<dataroot><family><makecode>JAGU</makecode><familycode>XF</familycode><vehicletype>PS</vehicletype><description>XF</description><latestyear>2018</latestyear></family>';
            modelStr += '<family><makecode>JAGU</makecode><familycode>XJ</familycode><vehicletype>PS</vehicletype><description>XJ</description><latestyear>2018</latestyear></family></dataroot>';
            jsonStr = modelStr;
        } 

        if(req.getBody() == YearBody)
        {
            yearStr = '<dataroot><yeargroup><makecode>JAGU</makecode><familycode>XJ</familycode><vehicletype>PS</vehicletype><year>2018</year><month>4</month><description>2018</description></yeargroup>';
            yearStr += '<yeargroup><makecode>JAGU</makecode><familycode>XJ</familycode><vehicletype>PS</vehicletype><year>2017</year><month>4</month><description>2017</description></yeargroup>';
            yearStr += '<yeargroup><makecode>JAGU</makecode><familycode>XJ</familycode><vehicletype>PS</vehicletype><year>2016</year><month>4</month><description>2016</description></yeargroup></dataroot>';
            jsonStr = yearStr;
        }

        if(req.getBody() == VehicleBody)
        {
            vehicleStr = '<dataroot><vehicle><makecode>JAGU</makecode><familycode>XJ</familycode><vehicletype>PS</vehicletype><year>2016</year><month>4</month>';
            vehicleStr += '<rbc>JAGU16AI</rbc><rbid>767415</rbid><bodystyle>SEDAN</bodystyle><description>X351 Sedan 4dr SA 8sp RWD 2.0iT (Premium Luxury SWB)</description><importflag>L</importflag><newprice>360000</newprice></vehicle></dataroot>';
            jsonStr = vehicleStr;
            
        }

        if(req.getBody() == PriceBody)
        {
            priceStr = '<dataroot><autocalc><km>50</km><condition>0</condition><wholesale>260840</wholesale><retail>240240</retail></autocalc>';
            priceStr += '<autocalc><km>50</km><condition>1</condition><wholesale>250840</wholesale><retail>240240</retail></autocalc>';
            priceStr += '<autocalc><km>50</km><condition>2</condition><wholesale>220840</wholesale><retail>240240</retail></autocalc>';
            priceStr += '<autocalc><km>50</km><condition>3</condition><wholesale>210840</wholesale><retail>240240</retail></autocalc>';
            priceStr += '<autocalc><km>50</km><condition>4</condition><wholesale>200840</wholesale><retail>240240</retail></autocalc>';
            priceStr += '<autocalc><km>50</km><condition>5</condition><wholesale>200740</wholesale><retail>240240</retail></autocalc></dataroot>';
            jsonStr = priceStr;

        }

        // Paypal 
        String payPalStr;
        Boolean OK = true;
        if(req.getEndpoint() == PaypalEndpointTest || req.getEndpoint() == PaypalEndpointProd)
        {
            //payPalStr = '';
            if(OK)
            {
                payPalStr = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cc="urn:ebay:apis:CoreComponentTypes" xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility" xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:wsse="http://schemas.xmlsoap.org/ws/2002/12/secext" xmlns:ed="urn:ebay:apis:EnhancedDataTypes" xmlns:ebl="urn:ebay:apis:eBLBaseComponents" xmlns:ns="urn:ebay:api:PayPalAPI">';
                payPalStr += '<SOAP-ENV:Header><Security xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext" xsi:type="wsse:SecurityType"></Security><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI" xsi:type="ebl:CustomSecurityHeaderType"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents" xsi:type="ebl:UserIdPasswordType"><Username xsi:type="xs:string"></Username><Password xsi:type="xs:string"></Password><Signature xsi:type="xs:string"></Signature><Subject xsi:type="xs:string"></Subject></Credentials></RequesterCredentials></SOAP-ENV:Header><SOAP-ENV:Body id="_0"><DoDirectPaymentResponse xmlns="urn:ebay:api:PayPalAPI"><Timestamp xmlns="urn:ebay:apis:eBLBaseComponents">2018-03-19T08:28:00Z</Timestamp><Ack xmlns="urn:ebay:apis:eBLBaseComponents">Success</Ack><CorrelationID xmlns="urn:ebay:apis:eBLBaseComponents">23f6ebdc3ce69</CorrelationID><Version xmlns="urn:ebay:apis:eBLBaseComponents">1.00</Version><Build xmlns="urn:ebay:apis:eBLBaseComponents">39949200</Build><Amount xsi:type="cc:BasicAmountType" currencyID="SGD">1000.00</Amount><AVSCode xsi:type="xs:string">Y</AVSCode><CVV2Code xsi:type="xs:string">S</CVV2Code><TransactionID>2CD15618U51381540</TransactionID></DoDirectPaymentResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
            }
            else
            {
               payPalStr =  '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cc="urn:ebay:apis:CoreComponentTypes" xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility" xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:wsse="http://schemas.xmlsoap.org/ws/2002/12/secext" xmlns:ed="urn:ebay:apis:EnhancedDataTypes" xmlns:ebl="urn:ebay:apis:eBLBaseComponents" xmlns:ns="urn:ebay:api:PayPalAPI">';
               payPalStr += '<SOAP-ENV:Header><Security xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext" xsi:type="wsse:SecurityType"></Security>';
               payPalStr += '<RequesterCredentials xmlns="urn:ebay:api:PayPalAPI" xsi:type="ebl:CustomSecurityHeaderType">';
               payPalStr += '<Credentials xmlns="urn:ebay:apis:eBLBaseComponents" xsi:type="ebl:UserIdPasswordType">';
               payPalStr += '<Username xsi:type="xs:string"></Username><Password xsi:type="xs:string"></Password>';
               payPalStr += '<Signature xsi:type="xs:string"></Signature><Subject xsi:type="xs:string"></Subject></Credentials></RequesterCredentials>';
                payPalStr += '</SOAP-ENV:Header><SOAP-ENV:Body id="_0"><DoDirectPaymentResponse xmlns="urn:ebay:api:PayPalAPI">';
                payPalStr += '<Timestamp xmlns="urn:ebay:apis:eBLBaseComponents">2018-02-27T15:27:23Z</Timestamp>';
                payPalStr += '<Ack xmlns="urn:ebay:apis:eBLBaseComponents">Failure</Ack>';
                payPalStr += '<CorrelationID xmlns="urn:ebay:apis:eBLBaseComponents">f216fa5875d9d</CorrelationID>';
                payPalStr += '<Errors xmlns="urn:ebay:apis:eBLBaseComponents" xsi:type="ebl:ErrorType">';
                payPalStr += '<ShortMessage xsi:type="xs:string">Invalid Configuration</ShortMessage>';
                payPalStr += '<LongMessage xsi:type="xs:string">This transaction cannot be processed. The merchant account is not able to process transactions.</LongMessage>';
                payPalStr += '<ErrorCode xsi:type="xs:token">10548</ErrorCode>';
                payPalStr += '<SeverityCode xmlns="urn:ebay:apis:eBLBaseComponents">Error</SeverityCode></Errors>';
                payPalStr += '<Version xmlns="urn:ebay:apis:eBLBaseComponents">1.00</Version>';
                payPalStr += '<Build xmlns="urn:ebay:apis:eBLBaseComponents">39206242</Build>';
                payPalStr += '<Amount xsi:type="cc:BasicAmountType" currencyID="SGD">1000.00</Amount>';
                payPalStr += '</DoDirectPaymentResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
            }

            jsonStr = payPalStr;
        }
        system.debug('---json:' + jsonStr);
        res.setBody(jsonStr);
        res.setStatusCode(200);
        return res;
    }
}