global class COOP_BatchClaimsReminder implements Database.Batchable<sObject>, database.Stateful {
    private OrgWideEmailAddress owa = [select id from OrgWideEmailAddress where DisplayName='noreply@i.jaguar-landrover.com' limit 1];
    Private EmailTemplate templateId = [Select id from EmailTemplate where name = 'Activity Evidence Submission Reminder Email'];
    Public Set<string> setUsr = new set<string>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Id rtId= Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Retailer').getRecordTypeId(); 
        String query =  'Select id, createdbyId, Submitting_User_Email__c, Submitted_Evidence_Count__c, (select id from Campaign_Activity_Evidence__r LIMIT 1) from CooP_Campaign_Activity__c where Campaign__r.recordtypeid =: rtId AND Campaign__r.StartDate =LAST_FISCAL_QUARTER AND Campaign__r.EndDate=LAST_FISCAL_QUARTER  AND Status__c =\'Activity Approved\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CooP_Campaign_Activity__c> cmpList) {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(CooP_Campaign_Activity__c cmp : cmpList) 
        {
            if( !setUsr.contains(cmp.createdbyId) && 
               (cmp.Submitted_Evidence_Count__c > 0 || cmp.Campaign_Activity_Evidence__r.isEmpty()) )
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templateId.Id);
                mail.settargetobjectid(cmp.createdbyId);
                //mail.setToAddresses(New List<String> {UserId});
                mail.setSaveAsActivity(false);
                mail.setOrgWideEmailAddressId(owa.id);
                allmsg.add(mail);
                setUsr.add(cmp.createdbyId); 
            }
            
        }
        try {
            
            if(!allmsg.isEmpty() && !Test.isRunningTest())
                Messaging.sendEmail(allmsg,false);
        } catch(Exception e) {
            System.debug(e);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}