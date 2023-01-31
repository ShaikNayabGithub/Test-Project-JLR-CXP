/**
 * Created by caleb on 10/09/2019.
 */

public with sharing class CreateAssetRequestDto
{
    @AuraEnabled
    public String name;

    @AuraEnabled
    public String derivativeProduct2Id;

    @AuraEnabled
    public String accountId;

    @AuraEnabled
    public string currencyIsoCode;

    @AuraEnabled
    public string assetRecordType;
}