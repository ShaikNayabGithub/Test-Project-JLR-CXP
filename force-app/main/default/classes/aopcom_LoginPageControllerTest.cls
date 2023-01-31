@isTest
public class aopcom_LoginPageControllerTest {
    static testMethod void validateLoginPageController(){
        aopcom_LoginPageController login = new aopcom_LoginPageController();
        login.username='test';
        login.password='password';
        login.mail='test@test.com';
        login.phone='8383838383';
        login.urlCheckfront='url.checkfront.test';
        login.selectPhone();
        //login.forwardToCustomAuthPage();
        login.login();
    }
}