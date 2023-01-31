/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/12/2019.
 */

public with sharing class SetOpportunityAssetResponseDto extends BaseResponseDto{

    @AuraEnabled
    public Boolean DoesLosePriceProtection;

    @AuraEnabled
    public Boolean WillRemoveAssetFromOpps;

    @AuraEnabled
    public List<SetAssetOpportunityDto> DuplicateOpportunities;
}