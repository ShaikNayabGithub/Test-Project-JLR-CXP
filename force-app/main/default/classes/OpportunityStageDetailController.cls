public class OpportunityStageDetailController {
    @AuraEnabled
    public static List<fieldWrap> getStageFieldNames(String opportunityId) {
        List<String> fieldList = new List<String>();
        List<fieldWrap> fieldWrapList = new List<fieldWrap>();
        Opportunity currentOpportunity = [SELECT Id,StageName FROM Opportunity WHERE Id =:opportunityId];
        system.debug(currentOpportunity);
        try{
            Opportunity_Stage_Details__mdt stageDetails = [SELECT Label,Field_API_Names__c FROM Opportunity_Stage_Details__mdt WHERE Label =:currentOpportunity.StageName LIMIT 1];
            system.debug(stageDetails);
            fieldList.addAll(stageDetails.Field_API_Names__c.split(','));
            for(String str : fieldList){
                fieldWrap fwrap = new fieldWrap();
                fwrap.fieldName = str;
                if(fwrap.fieldName == 'Brand__c' || fwrap.fieldName == 'Primary_Model_Interest__c'){
                    fwrap.isAvailable = true;
                }else{
                    fwrap.isAvailable = false;
                }
                fieldWrapList.add(fwrap);
            }
        }catch(Exception e){
            system.debug('Error'+ e.getMessage());
        }
        return fieldWrapList;
    }
    
    @AuraEnabled
    public static boolean isOpportunityClosed(String opportunityId) {
        Opportunity currentOpportunity = [SELECT IsClosed FROM Opportunity WHERE Id=:opportunityId];
        return currentOpportunity.IsClosed;
    }
    
    public class fieldWrap{
        public fieldWrap(){}
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isAvailable;
    }
    
}