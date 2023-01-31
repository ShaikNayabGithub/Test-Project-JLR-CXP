/**
 * Created by caleb@argologic.com.au on 11/02/2020.
 */

public with sharing class GetOpportunityInfoResponseDto extends BaseResponseDto
{
    @AuraEnabled
    public Boolean HasDerivativeSelected {get; set;}

    @AuraEnabled
    public Boolean HasAssetSelected {get; set;}

    @AuraEnabled
    public string AccountId {get; set;}

    @AuraEnabled
    public Boolean IsClosed {get; set;}
}