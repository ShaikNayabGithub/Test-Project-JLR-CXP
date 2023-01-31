public with sharing class lwcApexController {
    @AuraEnabled
    public static void createLead(String leadData){
        Lead newLead = (Lead) JSON.deserialize(leadData,Lead.class);
        insert newLead;
    }
}