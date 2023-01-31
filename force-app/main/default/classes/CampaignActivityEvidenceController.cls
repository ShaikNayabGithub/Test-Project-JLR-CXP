public with sharing class CampaignActivityEvidenceController {

    @AuraEnabled
    Public Static void createEvidence(Campaign_Activity_Evidence__c cae){
        insert cae;
        
    }
    
}