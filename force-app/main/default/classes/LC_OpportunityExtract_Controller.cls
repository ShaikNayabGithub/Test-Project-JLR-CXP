public class LC_OpportunityExtract_Controller {

    @AuraEnabled
    public static List<OpportunityLineItem> getLineItems(Id oppId) {
    	//'Product_Model_Code_Hidden__c', 'Product_Brand_Hidden__c', 'Product_Derivative_Hidden__c', 'Quantity'
    	List<OpportunityLineItem> olis = [SELECT Product_Model_Code_Hidden__c, Product_Brand_Hidden__c,
                                          Product_Derivative_Hidden__c, Quantity FROM OpportunityLineItem WHERE OpportunityId = :oppId];
        if(olis == null || olis.isEmpty()){
        	return null;
        }
        return olis;
    }
    
}