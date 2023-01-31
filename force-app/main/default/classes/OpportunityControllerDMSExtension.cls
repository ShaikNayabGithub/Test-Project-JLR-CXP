public without sharing class OpportunityControllerDMSExtension {
    private final Opportunity opportunity;
    private boolean requestSent = false;
    public Boolean CalledByLightning = false;
    public UpdateDMSResponse Response {get;set;}

    public OpportunityControllerDMSExtension(ApexPages.StandardController stdController) {
        this.opportunity = (Opportunity)stdController.getRecord();
    }

    public OpportunityControllerDMSExtension(Opportunity opportunity){
        this.opportunity = opportunity;
    }

    @AuraEnabled
    public static UpdateDMSResponse SendToDMS(ID opportunityId){



        List<Opportunity> opportunities = [SELECT Id
        FROM Opportunity
        WHERE Id =: opportunityId];

        if(opportunities.size() == 0){
            UpdateDMSResponse response = new UpdateDMSResponse();
            response.ErrorMessage = 'Id not found';
            return response;
        }

        OpportunityControllerDMSExtension ctl = new OpportunityControllerDMSExtension(opportunities[0]);
        ctl.CalledByLightning = true;
        ctl.UpdateDMS();
        return ctl.response;
    }


    public class UpdateDMSResponse{
        @AuraEnabled
        public String ErrorMessage {get;set;}
        @AuraEnabled
        public String SuccessMessage {get;set;}
        @AuraEnabled
        public Boolean IsSuccess {get;set;}

        public UpdateDMSResponse(){
            IsSuccess  =false;
        }
    }

    public void UpdateDMS()
    {
        Response = new UpdateDMSResponse();
        System.debug('Update DMS Call');
        System.debug('this.opportunity');
        System.debug(this.opportunity);
        List<Opportunity> relatedAccount = [Select account.country_iso_code__c, account.Country_ISO_Code__pc
        FROM Opportunity where id =: this.opportunity.id];


        if(relatedAccount.size() == 1 && relatedAccount[0].account != null &&  relatedAccount[0].account.Country_ISO_Code__c == 'BR'){
            ResetDMSStatus();
            return;
        }
        
        if(relatedAccount.size() == 1 && relatedAccount[0].account != null &&  relatedAccount[0].account.Country_ISO_Code__c == 'KR' || relatedAccount[0].account.Country_ISO_Code__pc == 'KR'){
            QuoteEventController.publishEvent(this.opportunity.id);
            System.debug('Korea DMS Called');
            return;
        } else {
            System.debug('Korea DMS Not Called');
        }
        

        if(this.requestSent){ return; }
        this.requestSent = true;
        try
        {
            DMSUpdater_Factory dmsUpdaterFactory = new DMSUpdater_Factory();
            DMSUpdater dmsUpdater = dmsUpdaterFactory.Create();
            dmsUpdater.UpdateDMSSystems(opportunity);
            response.IsSuccess = true;
            AddMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, System.Label.DMSUpdateSuccessful));
            response.SuccessMessage = System.Label.DMSUpdateSuccessful;
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            AddMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            response.ErrorMessage = e.getMessage();
        }
        catch(Exception e)
        {
            system.debug(e.getStackTraceString());
            AddMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.Unhandled_Exception + ' ' + e.getMessage()));
            response.ErrorMessage = System.label.Unhandled_Exception + ' ' +  e.getMessage();
        }
        this.requestSent = false;
    }

    private void AddMessage(ApexPages.Message msg){
        if(!CalledByLightning)
            ApexPAges.addMessage(msg);
    }

    public void ResetDMSStatus(){

        opportunity opp = [select isWon, DMS_Opportunity_ID__c, dms_reason__c,TimeLastSentToDMS__c from Opportunity where id =:this.opportunity.id];

        if(!opp.IsWon){
            AddMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.Label.DMSOpportunityNotAtCorrectStage));
            response.ErrorMessage = System.Label.DMSOpportunityNotAtCorrectStage;
            return;
        }

        if(String.isNotBlank(opp.DMS_Opportunity_ID__c)){
            AddMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.DMSAlreadyHasDMSId));
            response.ErrorMessage = System.Label.DMSAlreadyHasDMSId;
            return;
        }

        if(String.isBlank(opp.dms_reason__c)){
            AddMessage(new ApexPages.message(ApexPages.Severity.INFO, System.Label.DMSIsProcessing));
            response.ErrorMessage = System.Label.DMSIsProcessing;
            return;
        }

        opp.TimeLastSentToDMS__c = null;
        opp.dms_reason__c = null;
        update opp;
        AddMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, System.Label.DMSReset));
        response.ErrorMessage = System.Label.DMSReset;
    }
}