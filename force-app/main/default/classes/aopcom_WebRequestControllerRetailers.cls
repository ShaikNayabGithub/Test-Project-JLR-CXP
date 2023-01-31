global class aopcom_WebRequestControllerRetailers{
   
    global string retailername {get;set;}
    global string cicode {get;set;}   
    global string firstname  {get;set;}
    global string lastname {get;set;}
    global date birthday {get;set;}
    global string email {get;set;}    
    global string language {get;set;}
    global string homePhone {get;set;}
    global string mobilePhone {get;set;}
    global string city {get;set;}
    global string street {get;set;}
    global string state {get;set;}
    global string postalCode {get;set;}
    global string country {get;set;}
    global boolean EmailConsentAux {get;set;}
    global boolean PhoneConsentAux {get;set;}
    global boolean SMSConsentAux {get;set;}
    global boolean PostConsentAux {get;set;}
    global List<SelectOption> Purchases {get;set;}
    global List<SelectOption> Items {get;set;}
    global List<SelectOption> Items2 {get;set;}
    global string CIlanguage {get;set;}
    global List<SelectOption> countryItems{get;set;}
    global List<SelectOption> languageItems{get;set;}
    global List<SelectOption> Items3{get;set;}
    global String idmaker{get;set;} 
    global boolean errfirstname {get;set;} 
    global boolean errlastname {get;set;} 
    global boolean erremail {get;set;} 
    global boolean erremail2 {get;set;} 
    global boolean errpostcode {get;set;}
    global boolean errlanguage {get;set;} 
    global boolean errcountry {get;set;}
    global boolean errcicode {get;set;}
    global boolean errretailername {get;set;}
    global boolean recharge{get;set;}
    global String totalcode{get;set;}
    global integer errorsNumber{get;set;}
    global boolean errmatch{get;set;}
    global String urlParameter{get;set;}
    global boolean errmobilephone{get;set;}
    global boolean errmobilephone2{get;set;}
    global boolean errhomephone{get;set;}
    global String URLpath{get;set;}
    //reCaptcha variables
    global boolean verified{get;set;}

    public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }
    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = Label.aopcom_GoogleBaseUrl; 

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = Label.aopcom_PrivateGoogleKey;
    public String publicKey { 
        get { return Label.aopcom_PublicGoogleKey; }
    } 
    
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
    //End recaptcha variables
    
    // 
    // Initial method for Web Request Retailers page. It is loaded at the first page loading
    // 
    global aopcom_WebRequestControllerRetailers(){
        communityURL();
        urlParameter= ApexPages.currentPage().getParameters().get('campaignCode');
        system.debug('***************URL PARAMETER: '+urlParameter);
        getPurchase();
        takeItems();
        takeItems2();
        //Verified variable is set to false at the beggining in order to show reCaptcha buttons
        verified=false;
        if (errorsNumber==null){
            errorsNumber=0;
        }
        //Set Country combo values
        countryItems=new List<SelectOption>();
        List<aop_NationalityToISOCode__c> countryMap= [SELECT Name, aop_ISO_Code__c FROM aop_NationalityToISOCode__c ORDER BY Name];
        System.debug('***************** contryMap size'+countryMap.size());
        for(integer i=0; i<countryMap.size();i++){
            aop_NationalityToISOCode__c elem=countryMap.get(i);
            countryItems.add(new SelectOption(String.valueOf(elem.Name), String.valueOf(elem.Name)));
        }
        //Set Language combo values
        languageItems=new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult=Request__c.Language__c.getDescribe();
        List<Schema.PicklistEntry> languageMap=fieldResult.getPicklistValues();
        for(integer i=0; i<languageMap.size();i++){       
                languageItems.add(new SelectOption(languageMap.get(i).getLabel(),languageMap.get(i).getValue()));
        }
   }
        public string communityURL(){
            URLpath= site.getPathPrefix();
            return URLpath;
   }     
        
    public PageReference verify(){
        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        if ( challenge == null || response == null ) { 
            System.debug('reCAPTCHA verification attempt with empty form');
            return null; 
        }
        //It compose http response to Google            
        HttpResponse r = makeRequest(baseUrl,
            'privatekey=' + privateKey + 
            '&remoteip='  + remoteHost + 
            '&challenge=' + challenge +
            '&response='  + response
        );
        
        if ( r!= null ) {
            this.verified = (r.getBody().startsWithIgnoreCase('true'));
        }
        
        if(this.verified) {
            // If they pass verification, system try to submit request data. return null instruction is not executed.
            setRequest();
            return null;
        }
        else {
            // If they dont pass verification, system checks form anyway
            checkErrors();
            return null; 
        }
    }
    
    //
    // reCaptcha method
    // 
    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
    
    //
    // Get maker combo options
    // 
    public void takeItems() {
        Items = new List<SelectOption>();
        List<Vehicle_specification__c> maker=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,
                                             Is_India__c,Is_Japan__c,LastModifiedById,LastModifiedDate,LastReferencedDate,
                                             LastViewedDate,Make__c,Model_Code__c,Model__c,Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                             FROM Vehicle_Specification__c 
                                             WHERE Make__c = null];
        for (integer i=0; i <maker.size();i++){                        
            Items.add(new SelectOption(maker.get(i).Id, maker.get(i).Name));
        }       
    }
    
    //
    //  Get model combo options
    //  
    public void takeItems2() {
    
        Items2 = new List<SelectOption>();
        List<Vehicle_specification__c> model=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,Is_India__c,Is_Japan__c,
                                              LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Make__c,Model_Code__c,Model__c,
                                              Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                              FROM Vehicle_Specification__c 
                                              WHERE Make__c != null AND Is_Currently_Sold__c = true];

        for (integer i=0; i <model.size();i++){            
            Items2.add(new SelectOption(model.get(i).Id, model.get(i).Name));
        }       
   }
    //
    // Get purchase intervals
    // 
    public PageReference Redirect(){
        PageReference pageRef=new PageReference('https://'+Site.getDomain()+Site.getPathPrefix()+'/aopcom_WebRequestConfirm');
        pageRef.setRedirect(true);
        //PageReference pageRef = new PageReference(URLpath+'/aopcom_WebRequestConfirm');
        //PageReference pageRef=new PageReference('https://'+Site.getDomain()+Site.getPathPrefix()+'/aopcom_WebRequestConfirm');
        system.debug('pageRef ***** '+ pageRef);
        return pageRef;
    }  
    public void getPurchase(){
        Purchases= new List<SelectOption>(); 
        Schema.DescribeFieldResult fieldResult = Request__c.aop_Expected_Date_of_Purchase__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
        Purchases.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
    }
    //
    // Get Vehicle model
    // 
    global void selectValues(){
        Items3 = new List<SelectOption>();
        List<Vehicle_specification__c> model=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,Is_India__c,Is_Japan__c,
                                              LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Make__c,Model_Code__c,Model__c,
                                              Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                              FROM Vehicle_Specification__c 
                                              WHERE Make__c != null AND Make__c =: idmaker AND Is_Currently_Sold__c = true];    
          for (integer i=0; i <model.size();i++){            
            Items3.add(new SelectOption(model.get(i).Id, model.get(i).Name));
          }         
   } 
    
    public void getSecondaryDealerCode(){
         
    }   
    //
    // Check CI Code
    // 
    public boolean checkCICode(){
        system.debug('********************************CIlanguage '+CIlanguage);
        List<Account> codematch=[SELECT Secondary_Dealer_Code__c
                                 FROM Account
                                 WHERE Secondary_Dealer_Code__c!=null];  
        totalcode='J'+CIlanguage+cicode;
        system.debug('********************************Totalcode= '+totalcode);
        for (integer i=0; i< codematch.size();i++){
            if (totalcode.equalsIgnoreCase(codematch.get(i).Secondary_Dealer_Code__c)){  
                 system.debug('********************************Right!');
                return true;
            }
        }
        system.debug('********************************False!');
        return false;    
    }
    //
    //   check form errors
    //      
    public boolean checkErrors(){
        boolean errors=false;
        errlastname=false;
        erremail=false;
        erremail2=false;
        errlanguage=false;
        errcicode=false;
        errretailername=false;
        errmobilephone=false;
        errhomephone=false;

        //If firstname is null, we are going in
        if (firstname==null || firstname==''){
            system.debug('*****************ERRORS first name');
           errfirstname=true;
        }

        
        if (lastname==null || lastname==''){
            system.debug('*****************ERRORS lastname');
           errlastname=true;
        }
       
        if (email==null || email==''){
            system.debug('*****************ERRORS mail');
            erremail=true;     
        }       

        //If mobile phone is null, we are going in
        if (mobilePhone==null || mobilePhone==''){
            system.debug('*****************ERRORS mobilephone');
            errmobilephone2=true;
        }           

        //If post code is null, we are going in
        if (postalCode==null || postalCode==''){
            system.debug('*****************ERRORS post code');
            errpostcode=true;
        }       

        else {
             String emailRegex = '.+@.+\\.[a-zA-Z]+';           
             Pattern MyPattern = Pattern.compile(emailRegex);
             Matcher MyMatcher = MyPattern.matcher(email);
                if (!Mymatcher.matches()){
                system.debug('*****************ERRORS mail format');
                erremail2=true;
                }
        }
        if (language==null || language==''){
            system.debug('*****************ERRORS language');
            errlanguage=true;           
        }
        if (country==null || country==''){
            system.debug('*****************ERRORS country');
            errcountry=true;        
        }
        if (cicode==null || cicode==''){
            system.debug('*****************ERRORS cicode');
            errcicode=true;         
        }
        if (retailername==null || retailername==''){
            system.debug('*****************ERRORS retailername');
            errretailername=true;       
        }
        if(mobilePhone!=null && mobilePhone!=''){
            String mphoneRegex = '[0-9]+';           
            Pattern mphonePattern = Pattern.compile(mphoneRegex);
            Matcher mphoneMatcher = mphonePattern.matcher(mobilePhone.replace(' ' ,''));
        
            if (!mphonematcher.matches()){
                system.debug('*****************ERRORS mobile phone format');
                errmobilephone=true;
            }  
        }
        
        if(homePhone!=null && homePhone!=''){
            String homePhoneRegex = '[0-9]+';           
            Pattern homePhonePattern = Pattern.compile(homePhoneRegex);
            Matcher homePhoneMatcher = homePhonePattern.matcher(homePhone.replace(' ' ,''));
        
            if (!homePhonematcher.matches()){
                system.debug('*****************ERRORS home phone format');
                errhomephone=true;
            }  
        }
        
        
        if (errlanguage==true || errlastname==true || erremail==true || errcountry==true || errcicode==true || errretailername==true || errhomephone==true || errmobilephone==true ){
            errors=true;
        }
        system.debug(errlastname);
        system.debug('*****************ERRORS ' +errors);
        return errors;     
    }
    public void insertRequest(){ 
        recharge=true;
        RecordType rt= [SELECT Id FROM RecordType WHERE (Name = 'Pre-Registration Request' AND sObjectType = 'Request__C') LIMIT 1];
        //Create a new request (req) 
        Request__c req=new Request__c();
        req.Request_Type__c='SPEV';            
        req.aop_Event_Type__c='AOP Request';
        req.RecordTypeId=rt.Id;
        req.aop_Status__c='Submitted';
        //req.aop_Status__c=label.aop_Qualified;
        req.aop_Source__c='Retailer';
    
        //Set valor to the object fields                
        req.First_Name__c=firstname;
        req.Last_Name__c=lastname;
        req.aop_Date_of_Birth__c=birthday;
        req.Email__c=email;
        req.Finance_Interest__c=false;
        req.Trade_In__c=false;
        req.aop_Street__c=street;
        req.aop_Home_Phone__c= homePhone.replace(' ','');
        req.Mobile__c= mobilePhone.replace(' ','');
        req.Language__c= language;
        req.aop_Country__c= country;
        req.City__c=city;
        req.aop_Postcode_Zip_Code__c= postalCode;
        req.aop_State_Province__c= state;
        system.debug('***************************************************PREVIOUS TO ASSING CONSENT VALUES ');
        req.Consent_Email__c= EmailConsentAux;
        req.Consent_Phone__c= PhoneConsentAux;
        req.Consent_Post__c= PostConsentAux;
        req.Consent_SMS__c= SMSConsentAux;
        req.Preferred_Retailer_Code__c=cicode;
        req.aop_Retailer_Name__c=retailername;
        req.Campaign_Code__c= urlParameter;
    
        system.debug('***************************************************FIRST NAME '+ firstname);
        system.debug('***************************************************LAST NAME '+ lastname );
        system.debug('***************************************************BIRTHDAY '+ birthday);
        system.debug('***************************************************EMAIL '+ email);
        system.debug('***************************************************STREET'+ street );
        system.debug('***************************************************MOBILE PHONE '+ mobilePhone);
        system.debug('***************************************************LANGUAGE '+ language);
        system.debug('***************************************************COUNTRY '+ country);
        system.debug('***************************************************POSTALCODE '+postalCode );
        system.debug('***************************************************STATE '+ state);
        system.debug('***************************************************EMAIL CONSENT '+ req.Consent_Email__c);
        system.debug('***************************************************PHONE CONSENT '+ req.Consent_Phone__c );
        system.debug('***************************************************POST CONSENT '+ req.Consent_Post__c);
        system.debug('***************************************************SMS CONSENT '+ req.Consent_SMS__c);
        system.debug('***************************************************CI CODE '+ cicode);
        system.debug('***************************************************RETAILERNAME '+ retailername);
        system.debug('***************************************************Camapaign code '+ urlParameter);
        insert req; 
        
        System.debug('+++++++++++++Render value: '+recharge);
     }
    
    //
    //Set Request object with form information
    //
    public void setRequest(){
        List<aop_NationalityToISOCode__c> CIcountry= [SELECT aop_ISO_Code__c FROM aop_NationalityToISOCode__c WHERE Name=: country];
        aop_NationalityToISOCode__c CIname=CIcountry.get(0);  
        CIlanguage= CIname.aop_ISO_Code__c;
        system.debug('***************************************************Starting setRequest');
        recharge=false;      
        errmatch=false;
        //URLpath= site.getPathPrefix();
        // Previously to call to setRequest, checks if CI Code match with some CI Code Stored. User can try this 3 times, the third one, request is stored anyway
        if (!checkErrors()){
            system.debug('Errorsnumber before adding 1: '+errorsNumber);
            if (errorsNumber<2){
                if (checkCICode()){
                    insertRequest();
                    //PageReference pageRef = new PageReference(URLpath+'/aopcom_WebRequestConfirm');
                    //Redirect();
                }else {
                        errorsNumber=errorsNumber+1;
                        system.debug('***************************************************Errorsnumber: '+errorsNumber);
                        errmatch=true;  
                }
            }else {
            //Redirect();

            insertRequest();  

            }
       }
   }        
}