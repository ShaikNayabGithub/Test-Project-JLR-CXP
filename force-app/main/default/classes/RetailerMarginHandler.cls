public without sharing class RetailerMarginHandler {
    
    public static void execute(List<OpportunityLineItem> oppLineItems) {
        System.debug('execugin RetailerMarginHandler');
        List<opportunityRetailerMarginUpdate> oppMarginsToUpdate = new List<opportunityRetailerMarginUpdate>();
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        for(OpportunityLineItem oli : oppLineItems) {
            System.debug(JSON.serializePretty(oli));
            if(oli.Derivative_Retailer_Margin__c != null) {
                System.debug('oli Derivative_Retailer_Margin__c not null' );
                opportunityRetailerMarginUpdate ormu = new opportunityRetailerMarginUpdate();
                ormu.opportunityId = oli.OpportunityId;
                ormu.retailerMargin = oli.Derivative_Retailer_Margin__c;
                oppMarginsToUpdate.add(ormu);

                oppsToUpdate.put(oli.OpportunityId, new Opportunity(Id = oli.OpportunityId, Retailer_Margin__c = oli.Derivative_Retailer_Margin__c));

            }
        }

        if(oppMarginsToUpdate.size() > 0) {
            update oppsToUpdate.values();
            propogateToOpportunity(JSON.serialize(oppMarginsToUpdate));
        }

    }

    //@future
    public static void propogateToOpportunity(String oppRetailerMarginUpdatesJson) {
        List<opportunityRetailerMarginUpdate>  ormus = (List<opportunityRetailerMarginUpdate>) JSON.deserialize(oppRetailerMarginUpdatesJson, List<RetailerMarginHandler.opportunityRetailerMarginUpdate>.class);
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        for(opportunityRetailerMarginUpdate ormu : ormus) {
            oppsToUpdate.put(ormu.opportunityId, new Opportunity(Id = ormu.opportunityId, Retailer_Margin__c = ormu.retailerMargin));
        }

        update oppsToUpdate.values();
    }

    public class opportunityRetailerMarginUpdate {
        public String opportunityId;
        public Decimal retailerMargin;
    }


}