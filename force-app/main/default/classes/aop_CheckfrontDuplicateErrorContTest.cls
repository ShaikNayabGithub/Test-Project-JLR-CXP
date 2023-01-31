@isTest
public class aop_CheckfrontDuplicateErrorContTest {
    
    static testMethod void SetLanguageSetsLanguageValue()
    {
        aopCheckfrontDuplicateErrorController controller = new aopCheckfrontDuplicateErrorController();
        controller.setLanguage('renderrrr');
        system.assertEquals('renderrrr', controller.getLanguage());
    }

}