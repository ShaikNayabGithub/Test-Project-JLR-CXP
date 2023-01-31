/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/11/2019.
 */

public with sharing class SetCorporatePartnerResponseDto extends BaseResponseDto{

    public String ServicePlanId {get; set;}

    public String PricebookEntryId {get; set;}

    public String OpportunityLineItemId {get; set;}

}