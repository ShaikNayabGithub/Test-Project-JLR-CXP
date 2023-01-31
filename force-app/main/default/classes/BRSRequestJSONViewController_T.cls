@isTest
public class BRSRequestJSONViewController_T  {

    static testMethod void loadpage() {

        BRS_Request__c request = TestClass_BRSRequestCreator.Create();
        request.Error_Message__c = 'code coverage';
        update request;
        BRSRequestJSONViewController cc = new BRSRequestJSONViewController(new ApexPages.StandardController(request));

    }

    static testMethod void loadpage_extracoverage() {

        BRS_Request__c request = TestClass_BRSRequestCreator.Create(); 
        request.Models__c = '[{"code":"coverage"},{"code":"coverage"}]'; 
        request.Derivatives__c = '[{"code":"coverage"},{"code":"coverage"}]';
        request.Features__c = '[{"code":"coverage"},{"code":"coverage"}]'; 
        update request;
        BRSRequestJSONViewController cc = new BRSRequestJSONViewController(new ApexPages.StandardController(request));

    }
}