public class FirstOpportunityProduct_LC_Controller {

  @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityProducts(Id oppId) {
        List<OpportunityLineItem> oppProducts = [SELECT Id, Name FROM OpportunityLineItem WHERE OpportunityId = :oppId];
        return oppProducts;
    }
    
}