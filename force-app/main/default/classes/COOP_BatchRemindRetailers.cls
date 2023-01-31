global class COOP_BatchRemindRetailers implements Database.Batchable<sObject>, Database.Stateful {
    private OrgWideEmailAddress owa = [select id from OrgWideEmailAddress where DisplayName='noreply@i.jaguar-landrover.com' limit 1];
    Private EmailTemplate templateId = [Select id from EmailTemplate where name = 'Activities Need Attention'];
    Public Set<Id> setUsr = new set<Id>();

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Id rtId= Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Retailer').getRecordTypeId(); 
        
        String query =  'Select id, createdbyId from CooP_Campaign_Activity__c where Campaign__r.recordtypeid =: rtId AND End_Date__c = THIS_MONTH AND (Status__c =\'Activity Created\' OR Status__c = \'Activity Needs Modification\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CooP_Campaign_Activity__c> cmpList) {
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(CooP_Campaign_Activity__c cmp : cmpList) 
        {
            
            if(!setUsr.contains(cmp.createdbyId))
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(templateId.Id);
                mail.setTargetObjectId(cmp.createdbyId);
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