@isTest
public class aopcom_ForgottenPasswordControllerTester {
    static testMethod void validateLoginPageController(){
        aopcom_ForgottenPasswordController controller=new aopcom_ForgottenPasswordController();
        controller.username='test';
        controller.forgotPassword();
    }
}