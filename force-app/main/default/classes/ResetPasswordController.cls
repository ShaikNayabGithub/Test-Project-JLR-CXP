public without sharing class ResetPasswordController {
    public CreateSavedVehicleDto dto {get; set;}
    public string password {get; set;}
    public string confirmPassword {get; set;}
    public string errorMessage {get; set;}
    public boolean errorFlag {get; set;}
    public String errorMsgCSS {get; set;}
    public String inputFormCSS {get; set;}
    public String language {get; set;}
    public String brandvalue {get; set;}
    
    @TestVisible
    private static Integer availabilityTime = Integer.valueOf(Label.Availability_Time_Of_Activate_Mail);
    
    @TestVisible
    private List<User> userList;
    
    public ResetPasswordController(){
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
    
    public PageReference init(){
        
        try{
            this.dto = new CreateSavedVehicleDto();
            this.errorFlag = false;
            this.errorMsgCSS = 'u-hidden-visually';
            String uId = ApexPages.CurrentPage().getParameters().get('id');

            //uId = SiteCrypto.DecryptIdHex(uId);

            this.userList = UserDao.getUdaanActiveUserById(uId);
            if(this.userList.get(0).LastModifiedDate < DateTime.now().addHours( -1 * availabilityTime)){
                this.errorFlag = true;
                this.errorMessage = Label.Change_Password_Page_Expired_Error_Message;
                this.errorMsgCSS = '';
                this.inputFormCSS = 'u-hidden-visually';
                system.debug('1');
                return JUDAANUtil.brandCheck();
            }
            system.debug('2');
            return JUDAANUtil.brandCheck();
        }catch(exception e){
            this.errorFlag = true;
            this.errorMessage = Label.ChangePassword_Failed_Error_Message;
            this.errorMsgCSS = '';
            this.inputFormCSS = 'u-hidden-visually';
            system.debug('---ex:' + e);
            return JUDAANUtil.brandCheck();
        }
    }
    
    public void changePassword(){
        
        try{
            this.errorFlag = false;
            this.errorMessage = '';
            
            // Presence of user check
            if(this.userList.Size() == 0){
                this.errorFlag = true;
                this.errorMessage = Label.ChangePassword_Failed_Error_Message;
            // Empty check
            }else if(String.isEmpty(this.password) || String.isEmpty(this.confirmPassword)){
                this.errorFlag = true;
                this.errorMessage = Label.Not_Input_Error_Message;
            // Match check
            }else if(!this.password.equals(this.confirmPassword)){
                this.errorFlag = true;
                this.errorMessage = Label.Password_Mismatch_Error_Message;
            }else{
                // Change password
                System.setPassword(this.userList.get(0).Id, this.password);
            }
        }catch(InvalidParameterValueException ipve){
            this.errorFlag = true;
            this.errorMessage = Label.Password_Policy_Error_Message;
        }catch(Exception e){
            this.errorFlag = true;
            this.errorMessage = Label.ChangePassword_Failed_Error_Message;
        }
        
    }
}