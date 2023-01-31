/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 18/10/2019.
 */

public with sharing abstract class BaseVariantRequestDto  extends BaseRequestDto{

    @AuraEnabled
    public String OpportunityId {get; set;}

    @AuraEnabled
    public String Pricebook2Id {
        get {
            if (String.isBlank(this.varPricebookId)) {
                if (String.isBlank(this.OpportunityId)) {
                    InvalidParameterValueException ex = new InvalidParameterValueException(this.OpportunityId, 'OpportunityId cannot be null');
                    throw ex;
                }
                this.varPricebookId = [SELECT Pricebook2Id FROM Opportunity WHERE Id = :this.OpportunityId LIMIT 1].Pricebook2Id;
            }
            System.debug('PricebookId: ' + this.varPricebookId);
            return this.varPricebookId;
        }
        set {
            this.varPricebookId= value;
        }
    }

    private String varPricebookId;


}