global class aopcom_WebRequestController {
    
    global string retailername {get;set;}
    global string cicode {get;set;}   
    global string firstname  {get;set;}
    global string lastname {get;set;}
    global date birthday {get;set;}
    global string email {get;set;}    
    global boolean dataConsent {get;set;}
    global boolean validLicense {get;set;}
    global string language {get;set;}
    global string homePhone {get;set;}
    global string mobilePhone {get;set;}
    global string city {get;set;}
    global string street {get;set;}
    global string state {get;set;}
    global string postalCode {get;set;}
    global string country {get;set;}
    global List<SelectOption> Purchases {get;set;}
    global List<SelectOption> Items {get;set;}
    global List<SelectOption> Items2 {get;set;}
    global List<SelectOption> Items4 {get;set;}
    global string Purch {get;set;}
    global Request__c New_Request {get;set;}
    global string Model {get;set;} 
    global string Maker {get;set;} 
    global string IntMake {get;set;} 
    global string IntMod {get;set;} 
    global List<SelectOption> countryItems{get;set;}
    global List<SelectOption> languageItems{get;set;}
    string[] planPurchase = new string[]{};
    string[] makers = new string[]{};
    string[] makers2 = new string[]{};
    global List<SelectOption> Items3{get;set;}
    global String idmaker{get;set;} 
    global boolean errfirstname {get;set;} 
    global boolean errlastname {get;set;} 
    global boolean errbirthday {get;set;} 
    global boolean erremail {get;set;} 
    global boolean erremail2 {get;set;}
    global boolean errpostcode {get;set;}
    global boolean errlanguage {get;set;} 
    global boolean errcountry {get;set;}
    global boolean recharge{get;set;}
    global boolean errmobilephone{get;set;}
    global boolean errmobilephone2{get;set;}
    global boolean errhomephone{get;set;}
    global boolean EmailConsentAux{get;set;}
    global boolean PhoneConsentAux {get;set;}
    global boolean SMSConsentAux {get;set;}
    global boolean PostConsentAux {get;set;}
    global boolean validLicenseAux {get;set;}
    global boolean verified{get;set;}
    global String urlParameter{get;set;}
    global String URLpath{get;set;}
    
    //Start reCaptcha variables
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
    // Initial method for Web Request Page
    // 
    global aopcom_WebRequestController(){
        communityURL();
        urlParameter= ApexPages.currentPage().getParameters().get('campaignCode');
        system.debug('***************URL PARAMETER: '+urlParameter);
        New_Request = new Request__c();
        getPurchase();
        takeItems();
        takeItems2();
        takeItems4();
        //Verified variable is set to false at the beggining in order to show reCaptcha buttons
        verified=false;
        //Set Country combo values
        countryItems=new List<SelectOption>();
        List<aop_NationalityToISOCode__c> countryMap= [SELECT Name, aop_ISO_Code__c FROM aop_NationalityToISOCode__c ORDER BY Name];//aop_NationalityToISOCode__c.getAll().values();
            for(integer i=0; i<countryMap.size();i++){
                aop_NationalityToISOCode__c elem=countryMap.get(i);
                //System.debug('*********Id: '+i);
                //System.debug('*********Name: '+elem.aop_ISO_Code__c);
                countryItems.add(new SelectOption(String.valueOf(elem.Name), String.valueOf(elem.Name)));
        }
        
       
        //Set Language combo values
        languageItems=new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult=Request__c.Language__c.getDescribe();
        List<Schema.PicklistEntry> languageMap=fieldResult.getPicklistValues();
        for(integer i=0; i<languageMap.size();i++){       
                languageItems.add(new SelectOption(languageMap.get(i).getValue(),languageMap.get(i).getLabel()));
        }
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
    
    public string communityURL(){
            URLpath= site.getPathPrefix();
            return URLpath;
   }       
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
        
    
        
    public void takeItems() {
        Items = new List<SelectOption>();
        
        //It takes all the Vehicle specification that have no maker as a 'parent' (Make__c). So, it is not a model.
        List<Vehicle_specification__c> maker=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,
                                             Is_India__c,Is_Japan__c,LastModifiedById,LastModifiedDate,LastReferencedDate,
                                             LastViewedDate,Make__c,Model_Code__c,Model__c,Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                             FROM Vehicle_Specification__c 
                                             WHERE Make__c = null];
        system.debug('Valor del primer maker:' +maker);
        //Add an extra empty option to maker combo
        Items.add(new SelectOption('empty', ' '));
        //Add all the options
        for (integer i=0; i <maker.size();i++){                        
            Items.add(new SelectOption(maker.get(i).Id, maker.get(i).Name));
        }       
    }
    
    public void takeItems4() {
        Items4 = new List<SelectOption>();
        //It takes all the Vehicle specification that have no maker as a 'parent' (Make__c), so, it is not a model it is a maker, and check if aop_JLR_Owned__c its checked
        List<Vehicle_specification__c> maker=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,
                                              Is_India__c,Is_Japan__c,LastModifiedById,LastModifiedDate,LastReferencedDate,
                                              LastViewedDate,Make__c,Model_Code__c,Model__c,Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                              FROM Vehicle_Specification__c 
                                              WHERE Make__c = null AND aop_JLR_Owned__c= true ];
          system.debug('Valor del segundo maker:' +maker);
        for (integer i=0; i <maker.size();i++){                        
            Items4.add(new SelectOption(maker.get(i).Id, maker.get(i).Name));
        }       
    }
    
    
    public void takeItems2() {
    
        Items2 = new List<SelectOption>();
        //It takes all the Vehicle specification that have a maker as a 'parent' (Make__c), so, it is  a model
        List<Vehicle_specification__c> model=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,Is_India__c,Is_Japan__c,
                                              LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Make__c,Model_Code__c,Model__c,
                                              Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                              FROM Vehicle_Specification__c 
                                              WHERE Make__c != null AND Is_Currently_Sold__c = true];

          for (integer i=0; i <model.size();i++){            
            Items2.add(new SelectOption(model.get(i).Id, model.get(i).Name));
          }       
   }

    public void getPurchase(){
        // Get purchase intervals stored as a picklist of Request object
        Purchases= new List<SelectOption>(); 
        Schema.DescribeFieldResult fieldResult = Request__c.aop_Expected_Date_of_Purchase__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            Purchases.add(new SelectOption(f.getValue(), f.getLabel()));
            system.debug('List of purchases: '+Purchases);
        }       
    }
    global void selectValues(){
        //When a maker it is selected, model combo it is refreshed with the related models and filled
        Items3 = new List<SelectOption>();
        List<Vehicle_specification__c> model=[SELECT CreatedById,CreatedDate,Id,IsDeleted,Is_APIO__c,Is_Currently_Sold__c,Is_India__c,Is_Japan__c,
                                              LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Make__c,Model_Code__c,Model__c,
                                              Name,OwnerId,Price__c,RecordTypeId,SystemModstamp 
                                              FROM Vehicle_Specification__c 
                                              WHERE Make__c != null AND Make__c =:idmaker AND Is_Currently_Sold__c = true];    
          for (integer i=0; i <model.size();i++){            
            Items3.add(new SelectOption(model.get(i).Id, model.get(i).Name));
          }         
   } 
    
    //
    // Checks if mandatory fields are not null and email and phone fields have correct patterns
    // 
    public boolean checkErrors(){
        boolean errors=false;
        errfirstname=false;
        errlastname=false;
        errbirthday=false;
        erremail=false;
        errlanguage=false;
        erremail2=false;
        errmobilephone=false;
        errhomephone=false;

        //If firstname is null, we are going in
        if (firstname==null || firstname==''){
            system.debug('*****************ERRORS first name');
           errfirstname=true;
        }

        //If lastname is null, we are going in
        if (lastname==null || lastname==''){
            system.debug('*****************ERRORS lastname');
           errlastname=true;
        }
        //If bithday is null, we are going in
        if (birthday==null){
            system.debug('*****************ERRORS birthday');
            errbirthday=true;     
        }        
        //If email is null, we are going in
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

        
        //If email has contains these values: .+@.+\\.[a-zA-Z]+, we are going in
        else {
            String emailRegex = '.+@.+\\.[a-zA-Z]+';           
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(email);
            
            if (!Mymatcher.matches()){
            system.debug('*****************ERRORS mail format');
            erremail2=true;
            }
        }
        //If language is null, we are going in
        if (language==null || language==''){
            system.debug('*****************ERRORS language');
            errlanguage=true;           
        }
        //If country is null, we are going in
        if (country==null || country==''){
            system.debug('*****************ERRORS country');
            errcountry=true;        
        }
        //If mobilePhone is null, we are going in
        if(mobilePhone!=null && mobilePhone!=''){
            String mphoneRegex = '[0-9]+';           
            Pattern mphonePattern = Pattern.compile(mphoneRegex);
            Matcher mphoneMatcher = mphonePattern.matcher(mobilePhone.replace(' ' ,''));
            //If mobilePhone contains these values: 0, 1, 2, ... , 9, we are going in
            if (!mphonematcher.matches()){
                system.debug('*****************ERRORS mobile phone format');
                errmobilephone=true;
            }  
        }
        
        //If homePhone is null, we are going in
        if(homePhone!=null && homePhone!=''){
            String homePhoneRegex = '[0-9]+';           
            Pattern homePhonePattern = Pattern.compile(homePhoneRegex);
            Matcher homePhoneMatcher = homePhonePattern.matcher(homePhone.replace(' ',''));
            //If homePhone contains these values: 0, 1, 2, ... , 9, we are going in
            if (!homePhonematcher.matches()){
                system.debug('*****************ERRORS home phone format');
                errhomephone=true;
            }  
        }
        //If any of these errors are true, that is to say any of them is null, we are going in
        if (errlanguage==true || 
            errbirthday==true || 
            errlastname==true || 
            erremail==true || 
            errcountry==true || 
            erremail2==true || 
            errhomephone==true || 
            errmobilephone==true){
            errors=true;
        }
        system.debug(errlastname);
        system.debug('*****************ERRORS ' +errors);
        return errors;     
    }


    public void setRequest(){
        system.debug('***************************************************Starting setRequest');
        //system.debug('Valor del tamaño de maker: '+Maker);
        recharge=false;
        if (!checkErrors()){
            recharge=true;
            RecordType rt= [SELECT Id FROM RecordType WHERE (Name = 'Pre-Registration Request' AND sObjectType = 'Request__C') LIMIT 1];
            
            //Create a new request (req) 
           
            Request__c req=new Request__c();
            req.Request_Type__c='SPEV';             
            req.aop_Event_Type__c='AOP Request';
            req.aop_Source__c='Campaign';
            req.RecordTypeId=rt.Id;
            req.aop_Status__c='Submitted';
            //req.aop_Source__c='Retailer';
            
            //Set valor to the object fields                
            req.First_Name__c=firstname;
            req.Last_Name__c=lastname;
            req.aop_Date_of_Birth__c=birthday;
            req.Email__c=email;
            req.Finance_Interest__c=false;
            req.Trade_In__c=false;
            req.City__c=city;
            req.aop_Street__c=street;
            //take care of empty option in Maker combo field

            req.aop_Expected_Date_of_Purchase__c=Purch; 
            req.Brand_Lookup__c=IntMake; 
            req.Primary_Model_Of_Interest__c=IntMod;
            req.aop_Home_Phone__c= homePhone.replace(' ','');
            req.Mobile__c= mobilePhone.replace(' ','');
            req.Language__c= language;
            req.aop_Country__c= country;
            req.aop_Postcode_Zip_Code__c= postalCode;
            req.aop_State_Province__c= state;
            system.debug('***************************************************PREVIOUS TO ASSING CONSENT VALUES ');
            req.Consent_Email__c= EmailConsentAux;
            req.Consent_Phone__c= PhoneConsentAux;
            req.Consent_Post__c= PostConsentAux;
            req.Consent_SMS__c= SMSConsentAux;
            req.aop_Valid_Driving_License__c= validLicenseAux;
            req.Campaign_Code__c= urlParameter;          
            if (Maker!='empty' && Maker!=null){
                req.Current_Vehicle_Brand__c=Id.valueOf(Maker);
            }
            system.debug('***************************************************FIRST NAME '+ firstname);
            system.debug('***************************************************LAST NAME '+ lastname );
            system.debug('***************************************************BIRTHDAY '+ birthday);
            system.debug('***************************************************EMAIL '+ email);
            system.debug('***************************************************STREET'+ street );
            system.debug('***************************************************MAKER '+ (Maker));
            system.debug('***************************************************interest Maker '+ IntMake);
            system.debug('***************************************************interest Model '+ IntMod);             
            system.debug('***************************************************PURCH'+Purch );
            system.debug('***************************************************MOBILE PHONE '+ mobilePhone);
            system.debug('***************************************************LANGUAGE '+ language);
            system.debug('***************************************************COUNTRY '+ country);
            system.debug('***************************************************POSTALCODE '+postalCode );
            system.debug('***************************************************STATE '+ state);
            system.debug('***************************************************EMAIL CONSENT '+ req.Consent_Email__c);
            system.debug('***************************************************PHONE CONSENT '+ req.Consent_Phone__c );
            system.debug('***************************************************POST CONSENT '+ req.Consent_Post__c);
            system.debug('***************************************************SMS CONSENT '+ req.Consent_SMS__c);
            system.debug('***************************************************VALID LICENSE '+ req.aop_Valid_Driving_License__c);
            system.debug('***************************************************CI CODE '+ cicode);
            system.debug('***************************************************RETAILERNAME '+ retailername);
            system.debug('***************************************************Camapaign code '+ urlParameter);
            system.debug('la request es:    '+req);
            if(test.isRunningTest()){
                
                req.OwnerId = (Id)UserInfo.getUserId();
            }
            insert req; 
            
            System.debug('+++++++++++++Render value: '+recharge);
               
        }     
    }   
}