/*
** Direct Payment API of Paypal
*/
public class SGPaypalProccessor{
    public  String amount;
    public  String result {set;get;}
    public  string FirstName{get; set; }
    public  string LastName{get; set; }
    public  string Addy1{get; set; }
    public  string Addy2{get; set; }
    public  string Country{get; set; }
    public  string CardType{get; set; }
    public  string CardNo{get; set; }
    public  string expMo{get; set; }
    public  string expYe{get; set; }
    public  string CVV{get; set; }
    public  string city{get; set; }
    public  string state{get; set; }
    public  string zip{get; set; }
    public  string payer{ get; set; }
    public  string transid {get; set;}
    public  string message {get; set; }
    public  string err {get; set; }
    public  string rawResponse {get; set; }
    
    public string un { get; set; }
    public string pw {get; set; }
    public string sig { get; set; }
    public string endpoint { get; set; }
    
    public  string ipaddress {get; set; }
    public static Boolean DoSucceed { get; set; }

    public SGPaypalProccessor(String firstname, String lastname, String payer, String ipAddress, String cardNo, String expYe, String expMo, String cvv)
    {
        if(JUDAANUtil.runningInAsandbox())
        {
             endpoint = System.Label.SGPaypal_endpoint_test;
             un = System.Label.SGPaypal_user_test;
             pw = System.Label.SGPaypal_pwd_test;
             sig = System.Label.SGPaypal_signature_test;
        }
        else
        {
             endpoint = System.Label.SGPaypal_endpoint_prod;
             un = System.Label.SGPaypal_user_prod;
             pw = System.Label.SGPaypal_pwd_prod;
             sig = System.Label.SGPaypal_signature_prod;
        }
          city = '';
          state = '';
          zip = '';
          CardType = '';
          Country = '';
          Addy1 = '';
          Addy2 = '';
          payer = '';
          err = '';
          message = '';
          
          this.CVV = cvv;
          this.expYe = expYe;
          this.expMo = expMo;
          this.CardNo = cardNo;
          this.FirstName = firstname;
          this.LastName = lastname;
          this.ipaddress = ipAddress;
          this.payer = payer;
          this.amount = System.Label.SGPaypal_deposit;
    }

    public String doDirectPayment()
    { 
      
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      String doDirectRequest;
      doDirectRequest =  '<soap:Envelope xmlns:soap=' + '\'' + 'http://schemas.xmlsoap.org/soap/envelope/'  + '\'' + ' xmlns:xsi=' + '\''+ 'http://www.w3.org/2001/XMLSchema-instance'  + '\'' + ' xmlns:xsd=' + '\''+ 'http://www.w3.org/2001/XMLSchema' + '\'' + '>';
      doDirectRequest += '<soap:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
      doDirectRequest += '<Username>' + un + '</Username><ebl:Password xmlns:ebl="urn:ebay:apis:eBLBaseComponents">' + pw;
      doDirectRequest += '</ebl:Password><Signature>' + sig + '</Signature>';
      doDirectRequest += '</Credentials></RequesterCredentials></soap:Header><soap:Body><DoDirectPaymentReq xmlns="urn:ebay:api:PayPalAPI">';
      doDirectRequest += '<DoDirectPaymentRequest><Version xmlns="urn:ebay:apis:eBLBaseComponents">1.00</Version>';
      doDirectRequest += '<DoDirectPaymentRequestDetails xmlns="urn:ebay:apis:eBLBaseComponents">';
      doDirectRequest += '<PaymentAction>Sale</PaymentAction><PaymentDetails>';
      doDirectRequest += '<IPADDRESS>' + ipaddress + '</IPADDRESS>';
      doDirectRequest += '<OrderTotal currencyID="SGD">' + amount + '</OrderTotal>';
      doDirectRequest += '<ShipToAddress><Name>' + FirstName + ' ' + LastName + '</Name><Street1>' + Addy1 + '</Street1><Street2>' +Addy2 + '</Street2>';
      doDirectRequest += '<CityName>' + city + '</CityName><StateOrProvince>' + state + '</StateOrProvince><PostalCode>' + zip + '</PostalCode>';
      doDirectRequest += '<Country>' + country + '</Country></ShipToAddress>';
      doDirectRequest += '</PaymentDetails><CreditCard><CreditCardType>' + CardType + '</CreditCardType><CreditCardNumber>' + CardNo + '</CreditCardNumber>';
      doDirectRequest += '<ExpMonth>' + expMo + '</ExpMonth><ExpYear>' + expYe + '</ExpYear><CVV2>' + CVV + '</CVV2><CardOwner><PayerStatus>verified</PayerStatus>';
      doDirectRequest += '<Payer>' + payer + '</Payer>';
      doDirectRequest += '<PayerName><FirstName>' + FirstName+ '</FirstName><LastName>' + LastName + '</LastName></PayerName><PayerCountry>' + country + '</PayerCountry>';
      doDirectRequest += '<Address><Street1>' + Addy1 + '</Street1><Street2>' + Addy2 + '</Street2><CityName>' + city + '</CityName>';
      doDirectRequest += '<StateOrProvince>' + state + '</StateOrProvince><Country>' + country + '</Country><PostalCode>' + zip + '</PostalCode></Address>';
      doDirectRequest += '</CardOwner></CreditCard></DoDirectPaymentRequestDetails>';
      doDirectRequest += '</DoDirectPaymentRequest></DoDirectPaymentReq></soap:Body></soap:Envelope>';
      
      req.setEndpoint(endpoint);
      req.setMethod('POST');
      req.setBody(doDirectRequest);
      req.setHeader('Content-length', '1753' );
      req.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
      req.setHeader('SOAPAction','');
      //req.setHeader('Host','api-aa.sandbox.paypal.com');
      req.setTimeout(60000);
      HttpResponse res = h.send(req);
      String xml = res.getBody();
      rawResponse = xml;
      XmlStreamReader reader = res.getXmlStreamReader();
      result = JUDAANUtil.readXMLResponse(reader,'Ack');
      reader = res.getXmlStreamReader();
      err = JUDAANUtil.readXMLResponse(reader, 'LongMessage');
      
      if (result == 'Success')
      {
        reader = res.getXmlStreamReader();
        transid = JUDAANUtil.readXMLResponse(reader, 'TransactionID'); 
        system.debug('::' + transid ); 
        result = transid;
        DoSucceed = true;
      }
      else
      {
        result = err;
        DoSucceed = false;
      }
      
      return result;
    }

}