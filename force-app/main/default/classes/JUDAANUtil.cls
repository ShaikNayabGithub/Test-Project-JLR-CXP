public without sharing class JUDAANUtil 
{    
    public static List<SelectOption> getMileageOptions()
    {
        List<SelectOption> MileageOptions = new List<SelectOption>();
        MileageOptions.add(new SelectOption('', system.label.c_select_a_mileage));
        MileageOptions.add(new SelectOption('5000', '0 - 10000'));
        MileageOptions.add(new SelectOption('15000', '10000 - 20000'));
        MileageOptions.add(new SelectOption('25000', '20000 - 30000'));
        MileageOptions.add(new SelectOption('35000', '30000 - 40000'));
        MileageOptions.add(new SelectOption('45000', '40000 - 50000'));
        MileageOptions.add(new SelectOption('50000', '50000 ~'));
        return MileageOptions;
    }
    
    public static Map<String, String> getPicklistValues(string objName, String fld)
    {
          Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
          Sobject obj = targetType.newSObject();
          Schema.sObjectType objType = obj.getSObjectType(); 
          Schema.DescribeSObjectResult objDescribe = objType.getDescribe(); 
          map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
          list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
          Map<String, String> picklistMap = new Map<String, String>();
          for (Schema.PicklistEntry a : values)
          { 
             picklistMap.put(a.getValue(), a.getLabel());
          }
          return picklistMap;
    } 
    
    
    public static PageReference brandCheck(){
        PageReference p;
        // sandbox check      
        if(JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).LR_Cname__c == JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).JG_Cname__c){
            return null;
        }
        
        String url = String.valueOf(System.URL.getCurrentRequestUrl());
        if(!url.containsIgnoreCase(JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).JG_Cname__c) &&  !url.containsIgnoreCase(JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).LR_Cname__c)){
            return null;
        }
        
        String redirectBrand;
        if(url.containsIgnoreCase(JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).JG_Cname__c)){
            redirectBrand = 'jaguar';
        }else{
            redirectBrand = 'landrover';
        }
        
        if(ApexPages.currentPage().getParameters().get('brand') == redirectBrand){
            return null;
        }
        
        if(redirectBrand == 'jaguar'){
            p = new PageReference(JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).JG_Cname__c);
        }else{
            p = new PageReference(JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).LR_Cname__c);
        }
        p.getParameters().put('brand', redirectBrand);
        p.setRedirect(true);
        return p;
    }
    
    public static String CustomPath = Site.getBaseRequestUrl();
    public static String PathPrefix = Site.getPathPrefix();
    
    // Check Production or Sandbox
    public static Boolean runningInASandbox() 
    {
        system.debug('org id:' + UserInfo.getOrganizationId());
        return UserInfo.getOrganizationId() != '00D24000000qZQNEA2'; 
    }
    public static String getSimpleMarket()
    {
        String keyName;
        if(runningInASandbox())
        {
            keyName = ApexPages.currentPage().getParameters().get('market');
        }
        else
        {
            if(Test.isRunningTest())
            {
                keyName = ApexPages.currentPage().getParameters().get('market');
            }
            else
            {
                String baseUrl = Site.getBaseCustomUrl();
                String baseUrl3 = Site.getBaseRequestUrl();
                String baseUrl2 = String.valueOf(System.URL.getCurrentRequestUrl());
                system.debug('---custom url:' + baseUrl);
                system.debug('---custom url3:' + baseUrl3);
                system.debug('---request url2:' + baseUrl2);
                if(baseUrl3.contains('force.com'))
                {
                    keyName = ApexPages.currentPage().getParameters().get('market');
                }
                else
                {
                    /*if(baseUrl3.lastIndexOf('.') > baseUrl3.lastIndexOf('/'))
                    {
                        keyName = baseUrl3.substring(baseUrl3.lastIndexOf('.'));
                    }
                    else
                    {
                        keyName = baseUrl3.substring(baseUrl3.lastIndexOf('.') + 1, baseUrl3.lastIndexOf('/'));
                    }*/
					//Changes for thailand market
					if(baseUrl3.contains('th.com'))
					keyName = 'th';
					else
                    keyName = baseUrl3.substring(baseUrl3.lastindexof('.') + 1);
                }
            }   
        }
        system.debug('---key name:' + keyName);
        return keyName;
    }
   
    public static String getFullMarket()
    {
        return JUDAANMarketSettings__c.getValues(getSimpleMarket()).Market__c;
    }
    
    public static Boolean checkAPO()
    {
        String PathPrefix = Site.getPathPrefix();
        Boolean IsAPO = false;
        if(runningInASandbox())
        {
            if(ApexPages.currentPage().getParameters().get('APO') != null)
            {
                IsAPO = Boolean.valueOf(ApexPages.currentPage().getParameters().get('APO'));
            }
        }
        else
        {
            if(String.isNotBlank(PathPrefix) && PathPrefix.equalsIgnoreCase('APO'))
            {
                IsAPO = true;
            }
        }
        return IsAPO;
    }
    
    public static Boolean IsAPO()
    {
        Boolean IsAPO;
        String vid = ApexPages.currentPage().getParameters().get('vid');
        if(JUDAANUtil.getCurrentPageName().contains('APO'))
        {
            IsAPO = true;
        }
        else if(vid != null && vid  != '' && [select Id, APO__c from Asset where Id = :vid].APO__c)
        {
            IsAPO = true;
        }
        else
        {
            IsAPO = false;
        }
        return IsAPO;
    }
    
    public static Boolean IsAPO(String vid)
    {
        return [select Id, APO__c from Asset where Id = :vid].APO__c;
    }
    
    public static String getSupportedLanguages()
    {
        String market = getSimpleMarket();
        return JUDAANMarketSettings__c.getValues(market).Support_Languages__c;
    }
    
    public static String getDefaultLanguage()
    {
        return JUDAANMarketSettings__c.getValues(getSimpleMarket()).Default_Language__c;
    }
   /* **************************************************
    Method Name: getCurrencySymbol
    Input Parameters: 
    Return Type: String
    Method Description: Method to fetch the value of Currency_Symbol__c from custom setting JUDAANMarketSettings__c.
   ****************************************************** */  
   
     public static String getCurrencySymbol()
    {
         return JUDAANMarketSettings__c.getValues(getSimpleMarket()).Currency_Symbol__c;
    }
    
  /* **************************************************
    Method Name: getCurrentPageName
    Input Parameters: 
    Return Type: String
    Method Description: Method to fetch the current page URL.
   ****************************************************** */  
   
    public static String getCurrentPageName(){
        String url = ApexPages.currentPage().getUrl();      
        url = url.substringAfterLast('/');
        url = url.substringBefore('?');
        return url;
    }
    
   /* **************************************************
    Method Name: getAPOorNot
    Input Parameters: 
    Return Type: boolean 
    Method Description: Method to check, if it is APO page or not.
   ****************************************************** */  
    public static boolean getAPOorNot()
    {
        boolean IsAPO ; 
        String vid = ApexPages.currentPage().getParameters().get('vid');
        system.debug('::asset id::'+vid);  
        if(JUDAANUtil.getCurrentPageName().containsIgnoreCase('APOVehicleSearch') || JUDAANUtil.getCurrentPageName().containsIgnoreCase('APOVehicleSingle')||JUDAANUtil.getCurrentPageName().containsIgnoreCase('APOVehicleCompare'))
        {
            IsAPO =true;
        }
        else if(JUDAANUtil.getCurrentPageName().containsIgnoreCase('Checkout') || JUDAANUtil.getCurrentPageName().containsIgnoreCase('SGCheckout') || JUDAANUtil.getCurrentPageName().containsIgnoreCase('ReservationConfirmThankYou'))// Added ReservationConfirmThankYou 
        { 
        List<Asset> childAsset=[select Id,APO__c from Asset where id =:vid];  
            System.debug('childAsset :: '+childAsset);
        if(!childAsset.isEmpty())
        {
            IF(childAsset[0].APO__c  == true)
            {
              
            IsAPO =true;
            SYSTEM.DEBUG('in else if > if SGcheckout getAPOorNot IsAPO >>>'+IsAPO );
            system.debug('::IsAPO 1::'+IsAPO);
            }
            else
            { 
            IsAPO =false;
            system.debug('::IsAPO 2::'+IsAPO);
            }
         }
         }
        else
        {
            SYSTEM.DEBUG('in else getAPOorNot IsAPO >>>'+IsAPO );
            IsAPO =false;
        }
        SYSTEM.DEBUG('in getAPOorNot IsAPO >>>'+IsAPO );
        return IsAPO ;
    }
    
    //Added by Nana
    public static String getApoDxLink(){
        String JGapolink = JUDAANMarketSettings__c.getValues(getSimpleMarket()).APO_DX_JG_Link__c;
        String LRapolink = JUDAANMarketSettings__c.getValues(getSimpleMarket()).APO_DX_LR_Link__c;       
         
        if(ApexPages.currentPage().getParameters().get('brand') == 'jaguar'){
            return JGapolink;
            }else{
            return LRapolink;
        }    
    }
    
    public static String getRetailerDxLink(){
        String JGretailerLink = JUDAANMarketSettings__c.getValues(getSimpleMarket()).Dealer_Locator_JG_Link__c;
        String LRretailerLink = JUDAANMarketSettings__c.getValues(getSimpleMarket()).Dealer_Locator_LR_Link__c;       
         
        if(ApexPages.currentPage().getParameters().get('brand') == 'jaguar'){
            return JGretailerLink;
            }else{
            return LRretailerLink;
        }    
    }
    
    
    public static String getAddress()
    {
        String ipaddress = '';             
        Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();
        if(mapHeaders != null) 
        {
            ipAddress = mapHeaders.get('True-Client-IP');
            if(ipAddress == null)
                ipAddress = mapHeaders.get('X-Salesforce-SIP'); 
        }
        return ipaddress;
    }
    public static Vehicle_Specification__c getVehicleSpecFromProductCode(String ProductCode) {
        Savepoint sp = Database.setSavepoint();
        if (Limits.getQueries()>95){
            try{
                return new Vehicle_Specification__c ();
    
            }
            catch(Exception ex)
            {
                EmailUtility.SendEmail(new List<String>{system.label.Debug_EmailAddress_JLR,system.label.Debug_EmailAddress_TCS}, 'CreateSavedQuoteImplByCheckout Exception', 'CreateSavedQuoteImplByCheckout.cls Exception - ' + system.now(),'<pre>'+ex.getMessage()+'</pre><br/><pre>'+json.serializePretty(String.ValueOf(ex))+'</pre>');
                system.debug('---ex::' + ex.getMessage());
            }
        
        }
        if(ProductCode !=null){
            ProductCode = EncodingUtil.urlEncode(ProductCode,'UTF-8'); 
        }
    
        String GeneralDefaultQuery = 'select id, make__c, product_code__c from Vehicle_Specification__c where product_code__c != null and make__c != null and name = \'Range Rover Evoque\' and Is_Currently_Sold__c = true limit 1';
        String SpecificResultQuery = 'select id, make__c, product_code__c from Vehicle_Specification__c where make__c != null and product_code__c like \'%' + ProductCode + '%\' and Is_Currently_Sold__c = true';
    
        List<Vehicle_Specification__c> specs = Database.query(SpecificResultQuery); // SOQL Limit ++ 
    
        if (specs.isEmpty()) {
            specs = Database.query(GeneralDefaultQuery); // SOQL Limit ++ 
            return specs[0];
        }
    
           Map<String,Vehicle_Specification__c> ProductCodesToSpec = new Map<String,Vehicle_Specification__c>();
    
        for (Vehicle_Specification__c v : specs) {
            if (v.product_code__c.contains(',')) {
                for (String s : v.product_code__c.split(',')) {
                    ProductCodesToSpec.put(s,v);
                } 
            } else {
                ProductCodesToSpec.put(v.product_code__c,v);
            }
        }
    
        if (!ProductCodesToSpec.containsKey(ProductCode)) {
            specs = Database.query(GeneralDefaultQuery); 
            return specs[0];
        } else {
            return ProductCodesToSpec.get(ProductCode);
        }
    
    }
    
    public static string readXMLResponse(XmlStreamReader reader, String sxmltag)
    {
      string retValue; // Read through the XML
      while(reader.hasNext())
      {
        if (reader.getEventType() == XmlTag.START_ELEMENT)
        {
          if (reader.getLocalName() == sxmltag) {
            reader.next();
            if (reader.getEventType() == XmlTag.characters)
            {
              retValue = reader.getText();
            }
          }
        }
        reader.next();
      }
      return retValue;
    }
  
    /* **************************************************
    Method Name: getLabels
    Input Parameters: String 
    Return Type: string (Value stored in custom label)
    Method Description: Method to display custom label value into string.
   ****************************************************** */  
 public static String  getLabels(String labelName)
    {   
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + labelName + '}';
        return String.valueOf(output.value);
    }
    
    /////////////tm
    /* **************************************************
    Method Name: payHoldingDepositLimit
    Input Parameters: 
    Return Type: boolean
    Method Description: Method to check the reservation limit and compare it with the no of opportunities.
   ****************************************************** */  
  public static boolean payHoldingDepositLimit(){
        boolean ret;
        Integer checklimit;
        
        List<User> users = [select Id,AccountId from User where Id = :UserInfo.getUserId()];
     if(users.size() > 0)
         { 
            List<Opportunity> theOpps = [select id,name, StageName, Reservation_Cancelled__c, Deposit_paid_date__c, AccountId from Opportunity WHERE Reservation_Cancelled__c = false And Deposit_paid_date__c !=null and AccountId = :users[0].AccountId ];
            Integer size = theOpps.size();
            decimal check=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Reservation_Limit__c ;
            checklimit=check.intValue();
             if(size >= checklimit ) {
                     ret = true;
                     }
              else{
                     ret = false;
                   }
           }
        return ret;
        } 
        

}