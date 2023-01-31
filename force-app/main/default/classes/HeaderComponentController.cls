public without sharing class HeaderComponentController{
    private Set<String> brandSwitchDisabledPageName = new Set<String>{'VehicleSingle', 'CheckOut', 'SGCheckout', 'ActivateUser', 'ResetPassword','APOVehicleSingle'};
    public  Boolean brandSwitchDisabled {get; set;}
    public CreateSavedVehicleDto dto {get; set;}
    public String language{get; set;}
    public String brandvalue {get;set;}
    public String langs { get; set; }
    public String defaultLanguage { get; set; }
    public String MainSiteJG { get; set; }
    public String MainSiteLR { get; set; }
    public String DXLinkJG { get; set; }
    public String DXLinkLR { get; set; }
    public String CnameJG { get; set; }
    public String CnameLR { get; set; }  
    public boolean IsAPO { get; set; }
    public boolean APOAvailable { get; set; }      
    public String logoutJGURL { get; set; }  
    public String logoutLRURL { get; set; }  
    public User loginUser{get; set;} 
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String phone { get; set; }
    public String CPF { get; set; }
    public String errorMsg {get; set;}
    public String updateAccountflag {get; set;}
    public Boolean emailOptedOut { get; set; }
    public boolean isVehicleAvailable { get; set; }
    /*COSA-27 Feedback to OSA*/
    public string isFeedbackSaved { get; set; }
    public string comment { get; set; }
    public string isCommentBlank { get; set;}
    public string isFeedbackcommited { get; set;}
    
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
    
    public HeaderComponentController() {
        System.debug('HeaderComponentController constructor starts');
        IsAPO=JUDAANUtil.getAPOorNot();
        system.debug('::IsAPO 1::'+IsAPO);
        APOAvailable=JUDAANMarketSettings__c.getValues(market).APO_available__c;
        logoutJGURL =JUDAANMarketSettings__c.getValues(market).JG_Cname__c.split('\\?')[0];
        logoutLRURL =JUDAANMarketSettings__c.getValues(market).LR_Cname__c.split('\\?')[0];
        isFeedbackSaved = 'false';
        if(ApexPages.CurrentPage().getParameters().containsKey('lang')){
            this.language = ApexPages.CurrentPage().getParameters().get('lang');
        } else {
            //this.language = System.label.DEFAULT_LANGUAGE;
            this.language = JUDAANUtil.getDefaultLanguage();
        }
        if(this.language != 'ja' && this.language != 'en' && this.language != 'pt_BR') {
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('brand')){
            this.brandvalue = ApexPages.currentPage().getParameters().get('brand');
        } else {
            this.brandvalue = 'landrover';
        }
        
        if(this.brandvalue != 'landrover' && this.brandvalue != 'jaguar' ) {
            this.brandvalue = 'landrover';
        }
        langs = JUDAANUtil.getSupportedLanguages();
        DefaultLanguage = JUDAANUtil.getDefaultLanguage();
        // market = JUDAANUtil.getSimpleMarket();
        setMarketDetails();
        CustomerAccountController custAccObj = new CustomerAccountController();
        Integer foundCount = custAccObj.getSavedVehicle1();
        System.debug('Header Component foundCount :: '+foundCount);
        if(foundCount > 0)
            isVehicleAvailable = true;
        else
            isVehicleAvailable = false;  
        this.setBrandSwitchDisabled();
        System.debug('HeaderComponentController constructor ends');
    }
    
    // Code to enable switch between New / APO Vehicles
    public String selectedVehicleType { get {
        if(String.isBlank(selectedVehicleType)) {
            String pageName = ApexPages.currentPage().getUrl().substringAfter('apex/').split('\\?')[0];
            if(String.isNotBlank(pageName)) {
                if(pageName.equalsIgnoreCase('VehicleSearch')) {
                    selectedVehicleType = 'VehicleSearch';
                } else if(pageName.equalsIgnoreCase('APOVehicleSearch')) {
                    selectedVehicleType = 'APOVehicleSearch';
                } 
            }
        }
        return selectedVehicleType;
    } set; }
    
    public Boolean getVehicleTypeSwitch() {
        Boolean displaySwitch = false;
        if(market != null && market.equalsIgnoreCase('th')) {
            // Enable switch
            if(String.isNotBlank(selectedVehicleType) && (selectedVehicleType.equalsIgnoreCase('VehicleSearch') || selectedVehicleType.equalsIgnoreCase('APOVehicleSearch'))) {
                displaySwitch = true;
            } 
        }
        return displaySwitch;
    } 
    
    public List < SelectOption > getVehicleTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('VehicleSearch', Label.NEW_VEHICLES));
        options.add(new SelectOption('APOVehicleSearch', Label.APPROVED_PRE_OWNED));
        return options;
    }
    
    public PageReference switchVehicleTypePage() {
        PageReference pref = null;
        if(String.isNotBlank(selectedVehicleType)) {
            pref = new PageReference(Site.getBaseRequestUrl() + '/' + selectedVehicleType);
            pref.getParameters().put('brand', brandvalue);
            pref.getParameters().put('market', market);
            pref.getParameters().put('lang', language);
            pref.setRedirect(true);
        }
        System.debug('### switchVehicleTypePage.PageReference - ' + pref);
        return pref;
    }
    
    public void setMarketDetails() {
        JUDAANMarketSettings__c msetting = JUDAANMarketSettings__c.getValues(market);
        MainSiteJG = msetting.Main_site_JG_Link__c;
        MainSiteLR = msetting.Main_site_LR_Link__c;
        DXLinkJG = msetting.DX_JG_Link__c;
        DXLinkLR = msetting.DX_LR_Link__c;
        CnameJG = msetting.JG_Cname__c;
        CnameLR = msetting.LR_Cname__c;
    }
    
    
    private void setBrandSwitchDisabled(){
        String currentPageName = this.getCurrentPageName();
        this.brandSwitchDisabled = false;
        for(String disabledPageName : brandSwitchDisabledPageName){
            if(currentPageName == disabledPageName){
                this.brandSwitchDisabled = true;
                break;
            }
        }
    }
   
    public PageReference goVehicleSearchPage() {
        PageReference pageref;
        if(JUDAANUtil.getAPOorNot() == true) {
            pageref= Page.APOVehicleSearch;
        }
        else {
            pageref= Page.VehicleSearch;
        }
        pageref.getParameters().put('brand', this.brandvalue);
        pageref.getParameters().put('lang', this.language);
        pageref.getParameters().put('market', market);
        pageref.setRedirect(true);
        return pageref;
    }
    
    public PageReference changeLanguage(){
        PageReference pageref = this.getCurrentPageReference();
        
        if(System.label.DEFAULT_LANGUAGE == this.language ){
            pageref.getParameters().put('lang', 'en');
        } else if(market == 'br') {
             if(this.language == 'en')
              pageref.getParameters().put('lang', 'pt_BR');   
             else if(this.language == 'pt_BR')
              pageref.getParameters().put('lang', 'en'); 
            else
              pageref.getParameters().put('lang', 'pt_BR');
        } 
        else {
            pageref.getParameters().put('lang', System.label.DEFAULT_LANGUAGE);
        }
        
        /*if(JUDAANUtil.RunningInASandbox()){
            if(ApexPages.currentPage().getParameters().containsKey('market')){
                pageref.getParameters().put('market', ApexPages.currentPage().getParameters().get('market'));
            }
        }*/
        if(ApexPages.currentPage().getParameters().containsKey('model')){
            pageref.getParameters().put('model', ApexPages.currentPage().getParameters().get('model'));
        }
        if(ApexPages.currentPage().getParameters().containsKey('id')){
            pageref.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
        }
        if(ApexPages.currentPage().getParameters().containsKey('vid')){
            pageref.getParameters().put('vid', ApexPages.currentPage().getParameters().get('vid'));
        }
        if(ApexPages.currentPage().getParameters().containsKey('svid')){
            pageref.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));
        }
        if(ApexPages.currentPage().getParameters().containsKey('id1')){
            pageref.getParameters().put('id1', ApexPages.currentPage().getParameters().get('id1'));
        }
        if(ApexPages.currentPage().getParameters().containsKey('id2')){
            pageref.getParameters().put('id2', ApexPages.currentPage().getParameters().get('id2'));
        }
        if(ApexPages.currentPage().getParameters().containsKey('id3')){
            pageref.getParameters().put('id3', ApexPages.currentPage().getParameters().get('id3'));
        }
        pageref.getParameters().put('market', market);
        pageref.getParameters().put('brand', this.brandvalue);
        pageref.setRedirect(true);
        return pageref;
    }
    
    private PageReference getCurrentPageReference(){
        
        PageReference pageref = new PageReference('/' + this.getCurrentPageName());
        return pageref;
        
    }
    
    private String getCurrentPageName(){
        String url = ApexPages.currentPage().getUrl();
        url = url.substringAfterLast('/');
        url = url.substringBefore('?');
        return url;
    }
    
    public PageReference brandSwitch() {
        PageReference pageref;
        String pageName;
        if(getCurrentPageName() != 'customeraccountpage') {
            if(JUDAANUtil.getAPOorNot() == true) { //brandSwitchDisabled){
                pageName = 'APOVehicleSearch';
            } else {
                pageName = 'VehicleSearch'; //this.getCurrentPageName();
            }
        }
        else {
            pageName = 'customeraccountpage';
        }
        
        String baseUrl = Site.getBaseRequestUrl();
        if(baseUrl.contains('jaguar')) {
            if(baseUrl.contains('jaguarbrasil'))
                baseUrl = baseUrl.replace('jaguarbrasil', 'landrover');
            else
                baseUrl = baseUrl.replace('jaguar', 'landrover');
        }
        else {
            if(market == 'br'){
                baseUrl = baseUrl.replace('landrover', 'jaguarbrasil');
                if(baseUrl.contains('landroverbrasil'))
                    baseUrl = baseUrl.replace('landroverbrasil', 'jaguar');
            }
            else 
                baseUrl = baseUrl.replace('landrover', 'jaguar');
        }
        
        system.debug('---base url:' + baseUrl);
        pageref = new PageReference(baseUrl + '/' + pageName);
        pageref.getParameters().put('brand', this.brandvalue == 'jaguar' ? 'landrover' : 'jaguar');
        pageref.getParameters().put('lang', this.language);
        pageref.getParameters().put('market', market);
        pageref.setRedirect(true);
        system.debug('---page:' + pageref);
        return pageref;
    }
    
     /* **************************************************
    Method Name: APOSwitch
    Input Parameters: 
    Return Type: PageReference 
    Method Description: Method to check , if this is APO page or not.
   ****************************************************** */  
    public PageReference APOSwitch() {
        PageReference pageref;
        String pageName;
        if(JUDAANUtil.getAPOorNot() == true) { //brandSwitchDisabled){
            pageName ='VehicleSearch';
        } else {
            pageName ='VehicleSearch'; //APOVehicleSearch;
        }

        pageref = new PageReference(Site.getBaseRequestUrl() + '/' + pageName);
        pageref.getParameters().put('brand', this.brandvalue);
        pageref.getParameters().put('lang', this.language);
        pageref.getParameters().put('market', market);
        pageref.setRedirect(true);
        return pageref;
    }


    public PageReference mainSite() {
        PageReference pageref;
        if('jaguar' == this.brandvalue){
            pageref= new PageReference(MainSiteJG);
        }else{
            pageref= new PageReference(MainSiteLR);
        }
        pageref.setRedirect(true);
        return pageref;
    }
    
   
    public void setImplClassToDto(){
        this.dto.createSavedVehicle = null;
        this.dto.urlParameterMap = new Map<String, String>();
        this.dto.urlParameterMap.put('brand', this.brandvalue);
        this.dto.urlParameterMap.put('lang', this.language);
        this.dto.urlParameterMap.put('market', market);
        if(JUDAANUtil.getAPOorNot() == true || JUDAANUtil.IsAPO())
            this.dto.url = '/CustomerAccountPage';
        else    
            this.dto.url = '/CustomerAccountPage_New';
    }
    
    public PageReference goAccountPage(){
        PageReference p;
        if(JUDAANUtil.getAPOorNot() == true)
            p = Page.CustomerAccountPage;
        else
            p = Page.CustomerAccountPage_New;    
        p.getParameters().put('brand', this.brandvalue);
        p.getParameters().put('lang', this.language);
        p.getParameters().put('market', market);
        p.setRedirect(true);
        return p;
    }
    
    /* 
     **************************************************
    Method Name: saveAccountDetails
    Input Parameters: 
    Return Type: void 
    Method Description: Method to update , account details .
   ****************************************************** */
    public void getLoginUser() {
        List<User> uList = UserDao.getUdaanActiveUserById(UserInfo.getUserId());
        for(User u : uList) {
            this.loginUser = u;
        }
    }
    
    public void saveAccountDetails() {
        System.debug('---Inside saveAccountDetails :: '+UserInfo.getUserId());
        Account accDetailObj = new Account();
        Savepoint sp = Database.setSavepoint();
        try {
            errorMsg = '';
            updateAccountflag = 'true';
            System.debug('UserInfo.getUserId :: '+UserInfo.getUserId()); 
            
            getLoginUser();
            if(!String.isEmpty(this.phone ) && ( this.phone.length() > 11 || this.phone.length() < 10) && market.toUpperCase() == 'JP'){
                  this.errorMsg = Label.Japan_Phone;
                  this.updateAccountflag = 'fail';
                  return;
              }
            if(!String.isEmpty(this.phone ) && ( this.phone.length() <8 || this.phone.length() >= 13 ) && market.toUpperCase() == 'BR'){
                  this.errorMsg = Label.Brazil_Phone_Number;
                  return;
              }
            // unique CPF check
            if(!String.isEmpty(this.CPF)) {
                List<User> userCPFList = UserDao.getUserCPF(this.CPF);
                System.debug('userCPFList :: '+userCPFList);
                if(userCPFList != null && userCPFList.size() > 0) {
                    System.debug('userCPFList1 :: '+userCPFList.size());
                    this.errorMsg = Label.CPF_Error_Message;
                    return;
                }
            }
            // Requrire Check
            if(!String.isEmpty(this.CPF) && !this.CPF.isNumeric()) {
                this.errorMsg = Label.CPF_Message;
                return;
            }
            if(!String.isEmpty(this.CPF) && this.CPF.length() != 11) {
                this.errorMsg = Label.CPF_Message;
                return;
            }
            if(!String.isEmpty(this.phone ) && ( this.phone.length() > 8 || this.phone.length() < 8) && (market.toUpperCase() == 'HK' || market.toUpperCase() == 'SG')){
                  this.errorMsg = Label.HongKong_Singapore_Phone_Number;
                  this.updateAccountflag = 'fail';
                  return;
              }
            System.debug('--loginUser account id :: '+this.loginUser.AccountId);
            Account accountDetails =  UserDao.getAccountDetails(this.loginUser.AccountId,brandvalue);
            if(!String.isEmpty(this.firstName) && accountDetails.FirstName != this.firstName)
                accDetailObj.FirstName = this.firstName;
            if(!string.isEmpty(this.lastName) && accountDetails.LastName != this.lastName)
                accDetailObj.LastName = this.lastName;
            if(!String.isEmpty(this.phone) && accountDetails.Phone != this.phone)
                accDetailObj.Phone = this.phone;
            
            if(!String.isEmpty(this.CPF) && accountDetails.CPF__c != this.CPF)
                accDetailObj.CPF__c = this.CPF;
            //if(!String.isEmpty(accDetailObj.FirstName) || !String.isEmpty(accDetailObj.lastName) || !String.isEmpty(accDetailObj.phone))
            if(accountDetails.PersonHasOptedOutOfEmail != this.emailOptedOut)
                accDetailObj.PersonHasOptedOutOfEmail = this.emailOptedOut; 
            if(accDetailObj != null)  
                accDetailObj.Id = this.loginUser.AccountId;
            
            //if(accDetailObj != null)
            update accDetailObj;
            System.debug('---accDetailObj :: '+accDetailObj);
            errorMsg = Label.Account_Updated_Success;    
            updateAccountflag = 'Success';
            System.debug('errorMsg :: '+errorMsg);
            return;
        }
        catch(Exception e) {
            this.errorMsg = Label.Create_User_Error_Message;
            this.updateAccountflag = 'fail';
            System.debug('errorMsg1 :: '+errorMsg);
            Database.rollback(sp);
            return;
        }
        
    }
    
    public void getSubmittedFeedback() {
        getLoginUser();
        isFeedbackcommited = 'false';
        List<case> idCaseList = [Select id from case where AccountId =: this.loginUser.AccountId AND origin = 'OSA Feedback'];
        if(idCaseList != null && idCaseList.size()>0)
            isFeedbackcommited = 'true';
    }
    
    
    public Boolean isSuccess { get; set; }
    
    public void submitFeedback() {
        // Set default value
        
        isCommentBlank = 'false';
        isSuccess = false;
        
        if(String.isBlank(comment)) {
            isCommentBlank = 'true'; 
        }
        
        if(!Test.isRunningTest()) {
            isSuccess = reCaptcha.verify(
                ApexPages.currentPage().getParameters().get('g-recaptcha-response')
            );
        } else {
            isSuccess = true;
        }
        
        if(isSuccess && isCommentBlank == 'false') {
            getLoginUser();
            String nscEmail = '';
            String queueName = '';
            String countryCode = '';
            
            if(market == 'jp') {
                nscEmail = Label.JUDAAN_NSC_Email;
                queueName = 'Japan CRC Queue';
                countryCode = 'JP';
            }
            else if(market =='sg') { 
                nscEmail = Label.SUDAAN_NSC_Email;
                queueName = 'Singapore CRC Queue';
                countryCode = 'SG';
            }
            else if ( market =='hk') {
                nscEmail = Label.SUDAAN_NSC_Email;
                queueName = 'Singapore CRC Queue';
                countryCode = 'HK';
            }
            
            EnquiryformAPOSingle objFeedback = new EnquiryformAPOSingle();
            isFeedbackSaved = objFeedback.createCaseforFeedback(comment, nscEmail, brandvalue, this.loginUser.AccountId, queueName, countryCode); 
        }
    }
}