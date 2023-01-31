public with sharing class aopcom_ForgottenPasswordController {
    public String username {get; set;}   
       
    public aopcom_ForgottenPasswordController() {}
  
    public  PageReference forgotPassword() {
      boolean success = Site.forgotPassword(username);
      PageReference pr = Page.aopcom_LoginPage;
      pr.setRedirect(true);
      
      if (success) {        
        return pr;
      }
      return null;
    }
}