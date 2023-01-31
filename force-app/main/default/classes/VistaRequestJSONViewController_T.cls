@isTest
public class VistaRequestJSONViewController_T  {

    static testMethod void loadpage() {

        Vista_Request__c request = new Vista_Request__c();
        request.Error_Log__c = 'code coverage';
        insert request;
        VistaRequestJSONViewController cc = new VistaRequestJSONViewController(new ApexPages.StandardController(request));

    }

    static testMethod void loadpage_extracoverage() {

        Vista_Request__c request = new Vista_Request__c();
        request.Vehicle_Orders__c = '[{"code":"coverage"}]';   
        insert request;
        VistaRequestJSONViewController cc = new VistaRequestJSONViewController(new ApexPages.StandardController(request));


    }

}