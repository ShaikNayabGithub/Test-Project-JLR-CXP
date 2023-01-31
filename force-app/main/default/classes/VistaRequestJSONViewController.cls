public class VistaRequestJSONViewController  {

    public Vista_Request__c record {get;set;}
    public string body {get;set;}  

    public VistaRequestJSONViewController(ApexPages.StandardController controller) {
        this.record = (Vista_Request__c) controller.getRecord(); 
        Vista_Request__c r = [ select Error_Log__c, Vehicle_Orders__c from Vista_Request__c where id = : this.record.id]; 
        this.body = StringUtil.formatJSONoutput(r.Vehicle_Orders__c);

        if (String.isNotEmpty(r.Error_Log__c)) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,r.Error_Log__c));        
        }
            
    }

}