public class BRSRequestJSONViewController  {

    public BRS_Request__c record {get;set;}
    public List<String> body {get;set;} 

    public BRSRequestJSONViewController(ApexPages.StandardController controller) {
        this.record = (BRS_Request__c) controller.getRecord(); 
        BRS_Request__c r = [ select Error_Message__c, Models__c, Derivatives__c, Features__c from BRS_Request__c where id = : this.record.id];
        body = new list<string>();
        body.add(StringUtil.formatJSONoutput(r.Models__c));
        body.add(StringUtil.formatJSONoutput(r.Derivatives__c));
        body.add(StringUtil.formatJSONoutput(r.Features__c));

        if (String.isNotEmpty(r.Error_Message__c)) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,r.Error_Message__c));        
        }
            
    }

}