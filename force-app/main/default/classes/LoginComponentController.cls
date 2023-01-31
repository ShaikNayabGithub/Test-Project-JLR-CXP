public without sharing class LoginComponentController {
    
     public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    //public CreateSavedVehicleInterface createSavedVehicle {get; set;}
    public CreateSavedVehicleDto dto {get; set;}
    public String GACLIENTID{get; set;}
    public String GAUSERID{get; set;}
    public String GATRACKID{get; set;}
    public String language{get; set;}
    public String errorMsg {get; set;}
    public Boolean createUserFlag {get; set;}
    public Account acc;
    public Lead l;
    
    // Variable for Login
    public String loginUserName {get; set;}
    public String loginPassword {get; set;}
        
    // Variable for forgotPassword
    public String forgotPasswordMail{get; set;}
    
    // Variable for create user account
    public String firstName {get; set;}
    public String CPF {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String phone { get; set; }
    public String enquiryinfo {get; set;}
    public String password {get; set;}
    public String confirmPassword {get; set;}
    public Boolean emailOptedOut { get; set; }
    public Boolean agree {get;set;}
    public Boolean registerDisabled {get;set;}
    public DateTime pwdChangedDate {get; set; }
    public string userId;
    public Id personAccountId;

    // Getter Method is used to get market only when it is blank/null
    public String market {
        get {
            if(String.isBlank(market)) {
                market = JUDAANUtil.getSimpleMarket();
            }
            return market;
        }
        set;
    }    
    
    public LoginComponentController(){
        userId = '';
        this.registerDisabled = true;
        /* if( ! String.isEmpty( language ) ) {
        this.language = language;
        system.debug('lang1==>'+language);
        } else {
        this.language = JUDAANMarketSettings__c.getValues(market).Default_Language__c;
        system.debug('lang2==>'+language);
        
        } */
        if(ApexPages.CurrentPage().getParameters().containsKey('lang')){
            this.language = ApexPages.CurrentPage().getParameters().get('lang');
        }
        else {
            this.language = JUDAANUtil.getDefaultLanguage();
        }
        if(this.language != 'ja' && this.language != 'en' && this.language != 'pt_BR'){
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        List<User> userList = [Select Id from User where Name = 'System User'];
        if(userList != null && !userList.isEmpty())
            userId = userList[0].id;
        
    }
    
     
    public PageReference login(){
        try{
            this.errorMsg = '';
            List<User> userList = UserDao.getUserByUserName(this.loginUserName);
            if(userList.size() == 0 || !userList.get(0).IsActive || !userList.get(0).Udaan_Active__c){
                this.errorMsg = Label.Login_Error_Message;
                return null;
            }
            // Check if the password will soon be expired
            pwdChangedDate = userList.get(0).LastPasswordChangeDate;
            if(pwdChangedDate == null)
            {
                pwdChangedDate  =  userList.get(0).CreatedDate;
            }
            System.debug('Inside pwd expired');
            if(pwdChangedDate.addDays(Integer.valueOf(Label.Expired_Days)) <= System.now())
            {
                System.debug('Inside pwd expired 1');
                this.ErrorMsg = Label.Expired_Warning;
                return null;
            }
            
            // Requrire Check
            if(String.isEmpty(this.loginUserName) || String.isEmpty(this.loginPassword) ){
                this.errorMsg = Label.Required_Error_Message;
                return null;
            }
            PageReference p = Site.login(this.loginUserName, this.loginPassword, this.dto.url);
            // Login Error
            if(p == null){
                this.errorMsg = Label.Login_Error_Message;
                return null;
            }
            System.debug('Inside pwd expired 2');
            this.dto.userId = userList.get(0).Id;
            this.createSavedVehicle();
            this.setURLParameter();
            p = Site.login(this.loginUserName, this.loginPassword, this.dto.url);
            System.debug('Inside pwd expired 3'+p);
            return p;
        }catch(Exception e){
            this.errorMsg = Label.Login_Error_Message;
            System.debug('Exception occured :: '+e.getStackTraceString());
            return null;
        }
    }
    
    public void createSavedVehicle(){
        if(this.dto.createSavedVehicle != null){
            this.dto.createSavedVehicle.create(this.dto);
        }
    }
    
    public void createUserAccount(){
        Savepoint sp = Database.setSavepoint();
        try{
            this.errorMsg = '';
            this.createUserFlag = false;
            
            // Requrire Check
            if(String.isEmpty(this.firstName) || String.isEmpty(this.lastName) 
                    || String.isEmpty(this.email) || String.isEmpty(this.password) || String.isEmpty(this.confirmPassword) || !this.agree ||(market.toUpperCase() == 'BR' &&  String.isEmpty(this.CPF))){
                this.errorMsg = Label.Required_Error_Message;
                return;
            }
            System.debug( 'password-->'+password );
            System.debug( 'confirmPassword-->'+confirmPassword );
            if(this.password != this.confirmPassword){
                System.debug( 'password-->'+password );
                System.debug( 'confirmPassword-->'+confirmPassword );
                 this.errorMsg = Label.Password_MissMatch;
                 return;
            }
            
            
            if(!String.isEmpty(this.CPF) && !this.CPF.isNumeric() && market.toUpperCase() == 'BR')
            {
                this.errorMsg = Label.CPF_Message;
                return;
            }
            if(!String.isEmpty(this.CPF) && this.CPF.length() != 11 && market.toUpperCase() == 'BR')
            {
                this.errorMsg = Label.CPF_Message;
                return;
            }
            // Requrire Check
            if(!String.isEmpty(this.phone ) && ( this.phone.length() > 11 || this.phone.length() < 10 ) && 
                 market.toUpperCase() == 'JP'
                   ){
                this.errorMsg = Label.Japan_Phone;
                return;
            }
            
            // Requrire Check
            if(!String.isEmpty(this.phone ) && ( this.phone.length() > 8 || this.phone.length() < 8 ) && 
                  (market.toUpperCase() == 'HK' ||  market.toUpperCase() == 'SG')
                   ){
                this.errorMsg = Label.HongKong_Singapore_Phone_Number;
                return;
            }
           System.debug('length :: '+this.phone.length());
           
            if(!String.isEmpty(this.phone ) && ( this.phone.length() < 8 || this.phone.length() >= 13 ) && 
                  (market.toUpperCase() == 'BR')
                   ){
                this.errorMsg = Label.Brazil_Phone_Number;
                return;
            }
            System.debug('this.email '+email);
            // Created Check
            List<User> userList = UserDao.getUserByUserName(this.email);
            System.debug('userList :: '+userList);
            System.debug('labels :: '+ProfileDao.getInstance().getProfileId(Label.Udaan_User_Profile_Name));
            if(userList.size() >= 1 && (userList.get(0).IsActive &&  userList.get(0).Udaan_Active__c)){
                this.errorMsg = Label.Created_User_Error_Message;
                return;
            }else if (userList.size() >= 1 && userList.get(0).ProfileId != ProfileDao.getInstance().getProfileId(Label.Udaan_User_Profile_Name))
            {
                 System.debug('Inside ProfileId:: '+userList);
                this.errorMsg = Label.Created_User_Error_Message;
                return;
            }
            else if(userList.size() >= 1 && (!userList.get(0).IsActive || !userList.get(0).Udaan_Active__c)){
                userList.get(0).Is_new_for_Udaan__c = true;
                update userList;
                return;
            }
            System.debug('CPF:: :: '+CPF);
             List<User> userCPFList = UserDao.getUserCPF(this.CPF);
            System.debug('userCPFList :: '+userCPFList);
            if(userCPFList != null && userCPFList.size()>0 && market.toUpperCase() == 'BR')
                {
                    System.debug('userCPFList1 :: '+userCPFList.size());
                    this.errorMsg = Label.CPF_Error_Message;
                    return;
                }
            this.createAccount();
            this.createLead();
            this.createUserFlag = true;
            return;
        }catch(Exception e){
            this.errorMsg = Label.Create_User_Error_Message;
            if((e.getMessage()).contains(Label.Error_For_Phone_Number))
            this.errorMsg = Label.created_user_phone_number; 
            else if((e.getMessage()).contains(Label.Error_DUPLICATES_DETECTED))
            this.errorMsg = Label.DUPLICATES_DETECTED;    
            system.debug('$$$ create user account:' + e);
            Database.rollback(sp);
            return;
        }
    }
    
    @testvisible // -- Added by RT --
    private void createLead(){
        if(this.l == null){
            this.l = new Lead();   
        }
        l.ownerid = userId;
        l.LastName = this.lastName;
        l.FirstName = this.firstName;
        l.Email = this.email;
        l.Phone = this.phone;
        l.Description = this.enquiryinfo;
        l.Account_Type__c = 'Private';
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('UDAAN').getRecordTypeId();
        l.LeadSource = 'UDAAN';
        l.Rating = 'Warm';
        l.Type__c = 'Product';
        l.Sub_Type__c = 'Retail';
        l.Purchase_Type__c = 'New Vehicle'; // this field is mandatory when type is product;
        //  this.acc.Id        
        l.Account__c = personAccountId;
        l.Country_ISO_Code__c = market.toUpperCase();
        if(GATRACKID != null)
        l.GATRACKID__c = GATRACKID;
        if(GAUSERID != null)
        l.GAUSERID__c = GAUSERID;
        if(GACLIENTID != null)     
        l.GACLIENTID__c = GACLIENTID;  
        upsert l;
         system.debug('$$$lllll:' + l);

    }
    @testvisible
    private void createAccount(){
        if(this.acc == null){
            this.acc = new Account();   
        }
         this.acc.ownerid = userId;
        this.acc.LastName = this.lastName;
        if(this.CPF != null)
        this.acc.CPF__c = this.CPF;
        this.acc.FirstName = this.firstName;
        this.acc.PersonEmail = this.email;
        this.acc.Phone = this.phone;
        this.acc.PersonHasOptedOutOfEmail = this.emailOptedOut;
        this.acc.PersonLeadSource = 'UDAAN';
        this.acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        this.acc.Country_ISO_Code__c= market.toUpperCase();
        upsert acc;
        personAccountId = getChildAccIdByGoldenAcc(this.acc, null);
        //upsert acc;
        system.debug('$$$acc:' + acc);
    }
    
    
    public void createUser(){
        system.debug('----into create user::' ); 
        
        
        Savepoint sp = Database.setSavepoint();
        User u = new User();
        system.debug('----into create user::' ); 
        String brand = ApexPages.currentPage().getParameters().get('brand');
  
        try{
            if(!String.isEmpty(this.errorMsg)){
                return;
            }
            //this.acc.id 
            Contact con = [Select id from contact Where AccountId = :personAccountId  Limit 1];
            u.Username = this.email;
           
            u.Email = this.email;
            u.Phone = this.phone;
            if(this.CPF != null)
            u.CPF__c = this.CPF;
            u.ContactId = con.Id;
            u.ProfileId = ProfileDao.getInstance().getProfileId(Label.Udaan_User_Profile_Name);
            u.FirstName = this.firstName;
            u.LastName = this.lastName;
            u.Country_ISO_Code__c= market.toUpperCase();
            u.Alias = this.firstName.left(8);
            //u.CommunityNickname = firstName + lastName;
            u.DigestFrequency = 'N';
            u.EmailEncodingKey = 'UTF-8';
            u.TimeZoneSidKey = 'Europe/London';
            u.LocaleSidKey = 'en_GB';
            u.DefaultCurrencyIsoCode = 'GBP';
            u.IsActive = true;
            u.Udaan_Active__c = false;
            u.Is_new_for_Udaan__c = true;
            if('jp'.equals(this.language)){
                u.LanguageLocaleKey = 'ja';
            }else if('en'.equals(this.language)){
                u.LanguageLocaleKey = 'en_US';
            }else{    
                u.LanguageLocaleKey = 'en_US';
            }
           if(!JUDAANUtil.runningInASandbox())
            {
                String baseUrl = Site.getBaseRequestUrl();
                 //if(brand== 'jaguar')
                 //{
                 //u.UDAAN_URL__c =JUDAANMarketSettings__c.getValues(market).JG_Cname__c + 'ActivateUser?lang=' + this.language +'&id='; 
                 //system.debug('---- url'+u.UDAAN_URL__c ); 
                 // }
                 //else
                 //{
                 //u.UDAAN_URL__c =JUDAANMarketSettings__c.getValues(market).LR_Cname__c + 'ActivateUser?lang=' + this.language + '&id='; 
                 //system.debug('---- url'+u.UDAAN_URL__c );                                     
                 //}

                 u.UDAAN_URL__c = baseUrl + '/ActivateUser?brand=' + brand + '&market=' + market + '&lang=' + this.language +'&id=';
             }
            else
            {
                if(brand== 'jaguar')
                {
                string customPath=JUDAANMarketSettings__c.getValues(market).JG_Cname__c.replace('Udaan','Udaan/ActivateUser');
                u.UDAAN_URL__c =customPath+'&lang=' + this.language + '&id='; 
                system.debug('---- url'+u.UDAAN_URL__c );
                }
                else
                {
                string customPath=JUDAANMarketSettings__c.getValues(market).LR_Cname__c.replace('Udaan','Udaan/ActivateUser');
                u.UDAAN_URL__c =customPath+'&lang=' + this.language + '&id='; 
                system.debug('---- url'+u.UDAAN_URL__c );                                     
                } 
            }   
            //Site.validatePassword(u, this.password, this.password);
            //Site.createExternalUser(u,accId,this.password);
            System.debug('u :: '+u);
            
            insert u;
            System.setPassword(u.Id, this.password);
        }
        catch(InvalidParameterValueException ipve){
            this.errorMsg = Label.Password_Policy_Error_Message;
             system.debug('---register ex:' + ipve);
            Database.rollback(sp);
            return;
        }catch(Exception e){
            this.errorMsg = Label.Create_User_Error_Message;
            system.debug('---register ex:' + e);
            system.debug('$$$$ create user:' + e);
            Database.rollback(sp);
            return;
        }
    }
    
    @TestVisible
    private void setURLParameter(){
        if(this.dto.urlParameterMap == null){
            return;
        }
        Integer i = 0;
        for(String key : this.dto.urlParameterMap.keySet()){
            if(i == 0){
                this.dto.url += '?' + key + '=' + this.dto.urlParameterMap.get(key);
            }else{
                this.dto.url += '&' + key + '=' + this.dto.urlParameterMap.get(key);
            }
            ++i;
        }
        
    }
    
    public void forgotPassword(){
        String brand = ApexPages.currentPage().getParameters().get('brand');
     
        try{
            this.errorMsg = '';
            List<User> userList = [Select id,Forgot_Password__c From User Where UserName =: this.forgotPasswordMail AND isActive = true AND Udaan_Active__c = true];
            if(userList.size() == 0)
            {
                // Error
                this.errorMsg = Label.Forgot_Password_Error_Message;
                return;
            }
           User u = userList.get(0);
           system.debug('---u:' + u.Id);
           if(!JUDAANUtil.runningInASandbox())
           {       
                 //if(brand== 'jaguar'){
                 //    u.UDAAN_URL__c =JUDAANMarketSettings__c.getValues(market).JG_Cname__c + 'ResetPassword?lang='+this.language +'&id='+ u.Id; 
                 //    system.debug('---- url'+u.UDAAN_URL__c );          
                 //   }
                 // else{
                 //   u.UDAAN_URL__c =JUDAANMarketSettings__c.getValues(market).LR_Cname__c + 'ResetPassword?lang=' + this.language +'&id='+ u.Id; 
                 //     system.debug('---- url'+u.UDAAN_URL__c );                                     
                 //   }

                String baseUrl = Site.getBaseRequestUrl();
                u.UDAAN_URL__c = baseUrl + '/ResetPassword?brand=' + brand + '&market=' + market + '&lang=' + this.language +'&id=' + u.Id;
             }
            else{           
                 if(brand== 'jaguar'){
                    string customPath=JUDAANMarketSettings__c.getValues(market).JG_Cname__c.replace('Udaan','Udaan/ResetPassword');
                     u.UDAAN_URL__c =customPath+'&lang=' +  this.language + '&id='+ u.Id; 
                     system.debug('---- url'+u.UDAAN_URL__c );          
                    }
                  else{
                     string customPath=JUDAANMarketSettings__c.getValues(market).LR_Cname__c.replace('Udaan','Udaan/ResetPassword') ;
                     u.UDAAN_URL__c =customPath+'&lang='+ this.language+'&id='+ u.Id; 
                     system.debug('---- url'+u.UDAAN_URL__c );                                     
                    }
                   }              
             u.Forgot_Password__c = true;
               update u;
            }
            catch(Exception e){
            this.errorMsg = Label.Forgot_Password_Error_Message;
            system.debug('$$$forget password:' + e);
        }
    }
    
    public void registerUnDisabled(){
        this.registerDisabled = false;
    }
    
    public void registerDisabled(){
        this.registerDisabled = true;
    }
    
     public Id getChildAccIdByGoldenAcc(Account goldenRecord, Id retailerId) {
        
        List<Account> relatedAccounts = [SELECT Id FROM Account WHERE Primary_Account__c = :goldenRecord.Id AND Owner_Retailer__c = :retailerId AND Is_Primary__c = false];
        if(relatedAccounts.size() > 0){
            return relatedAccounts[0].Id; //there should only ever be one Account per Retailer per Golden Record
        }
        //there is no non-Primary account for this Golden Record so create one
        Account retailerAccount = goldenRecord.clone(false, false, false, false);
        retailerAccount.Owner_Retailer__c = goldenRecord.id;
        retailerAccount.Is_Primary__c = false;
        retailerAccount.Primary_Account__c = goldenRecord.Id;
        if(goldenRecord.RecordTypeId == goldIndividualRecordType){
            retailerAccount.RecordTypeId = individualRecordType;
        }
        else if(goldenRecord.RecordTypeId == goldCorporateRecordType){
            retailerAccount.RecordTypeId = corporateRecordType;
        }
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        system.debug('----insert'+Database.insert(retailerAccount, dml));
        return retailerAccount.Id;
    }
    
}