public class LC_RDACancellation_Controller {
    
    @AuraEnabled
    public static String CancelRDA(Id rdaId) {
        RDA__c rda = new RDA__c(Id=rdaId, Submitted_Status__c='Cancelled');
        try{
            update rda;
        }
        catch(Exception e){
            return e.getMessage();
        }
        return 'Success';
    }
    
}