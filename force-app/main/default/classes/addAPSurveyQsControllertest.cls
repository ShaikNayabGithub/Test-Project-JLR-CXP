@IsTest
public class addAPSurveyQsControllertest {
@IsTest
    static void Test_getSUrveyDataOppId(){
        AP_Survey__c objAP_Survey = new AP_Survey__c(Active__c = true,Survey_Type__c='Purchase');
        insert objAP_Survey;
        AP_Survey_Question__c objAP_Survey_Question = new AP_Survey_Question__c(AP_Survey__c = objAP_Survey.id,Survey_Form_Page_No__c='1');
        insert objAP_Survey_Question;
        addAPSurveyQsController.getdata(objAP_Survey.id);
    }
}