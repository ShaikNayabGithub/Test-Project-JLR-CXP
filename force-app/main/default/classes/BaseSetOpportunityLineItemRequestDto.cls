/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/11/2019.
 */

global with sharing virtual class BaseSetOpportunityLineItemRequestDto {

    @AuraEnabled
    global String OpportunityId { get; set; }


    @AuraEnabled
    global List<String> TypeNames{get; set;}

    @AuraEnabled
    global Decimal Qty { get; set; }

    @AuraEnabled
    global Decimal TotalPrice { get; set; }

    @AuraEnabled
    global String PricebookEntryId { get; set; }

    @AuraEnabled
    global String PricebookId {
        get {
            if (String.isBlank(this.varPricebookId)) {
                if (String.isBlank(this.OpportunityId)) {
                    InvalidParameterValueException ex = new InvalidParameterValueException(this.OpportunityId, 'OpportunityId cannot be null');
                    throw ex;
                }
                this.varPricebookId = [SELECT Pricebook2Id FROM Opportunity WHERE Id = :this.OpportunityId LIMIT 1].Pricebook2Id;
            }
            return this.varPricebookId;
        }
        set {
            this.varPricebookId= value;
        }
    }

    private String varPricebookId;
}