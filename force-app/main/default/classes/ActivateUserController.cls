public without sharing class ActivateUserController {
    public String language {get;set;}
    public String errorMsg {get;set;}
    public String errorMsgCSS {get; set;}
    public String thankyouMsgCSS {get; set;}
    public CreateSavedVehicleDto dto {get; set;}
	public string showactivatMsg {get; set;}
    public String brandvalue {get; set;}
    
    @TestVisible
    private static Integer availabilityTime = Integer.valueOf(Label.Availability_Time_Of_Activate_Mail);
    
    public ActivateUserController(){
        this.errorMsgCSS = 'u-hidden-visually';
        this.thankyouMsgCSS = '';
		showactivatMsg = '';
        // Get RequestParameters
        if(ApexPages.CurrentPage().getParameters().containsKey('lang')){
            this.language = ApexPages.CurrentPage().getParameters().get('lang');
        }else{
            this.language =System.label.DEFAULT_LANGUAGE;
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('brand')){
            this.brandvalue = ApexPages.currentPage().getParameters().get('brand');
        }else{
            this.brandvalue = 'landrover';
        }
        
        if(this.brandvalue != 'landrover' && this.brandvalue != 'jaguar' ){
            this.brandvalue = 'landrover';
        }
    }
    
    
    public PageReference activateUser(){
        try{
            String userId = ApexPages.CurrentPage().getParameters().get('id');
            this.dto = new CreateSavedVehicleDto();
            
            // Not Found User Error
            List<User> uList = UserDao.getUserById(userId);
            if(uList.size() == 0){
                this.errorMsg =  Label.Activate_User_Error_Message;
                this.errorMsgCSS = '';
                this.thankyouMsgCSS = 'u-hidden-visually';
                return JUDAANUtil.brandCheck();
            }
            
            if(uList.get(0).isActive && uList.get(0).Udaan_Active__c){
                return JUDAANUtil.brandCheck();
            }
            
            // Availability Time Over
            if(uList.get(0).LastModifiedDate < DateTime.now().addHours( -1 * availabilityTime)){
                this.errorMsg = Label.Activate_User_Expired_Error_Message;
                this.errorMsgCSS = '';
                this.thankyouMsgCSS = 'u-hidden-visually';
                return JUDAANUtil.brandCheck();
            }
            showactivatMsg  = String.format(Label.Account_activated, new String[]{ApexPages.currentPage().getParameters().get('brand').toUpperCase()});
            uList.get(0).isActive = true;
            uList.get(0).Udaan_Active__c = true;
            update uList;
			
            return JUDAANUtil.brandCheck();
            
        }catch(Exception e){
            this.errorMsg = Label.Activate_User_Error_Message;
            this.errorMsgCSS = '';
            this.thankyouMsgCSS = 'u-hidden-visually';
            return JUDAANUtil.brandCheck();
        }
    }
}