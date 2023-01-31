/**
 * Created by caleb on 4/09/2019.
 */

public with sharing class GetServicePlansRequestDto extends BaseRequestDto
{
    public GetServicePlansRequestDto()
    {
        TypeNames = new List<String>();
    }

    public GetServicePlansRequestDto(List<String> typeNames, String variantId)
    {
        this(typeNames);
        this.VariantId = variantId;
    }

    public GetServicePlansRequestDto(List<String> typeNames, String variantId, String servicePlanId, String corporatePartnerId)
    {
        this(typeNames, variantId, servicePlanId);
        this.CorporatePartnerId = corporatePartnerId;
    }

    public GetServicePlansRequestDto(List<String> typeNames, String variantId, String servicePlanId)
    {
        this(typeNames, variantId);
        this.ServicePlanId = servicePlanId;
    }

    public GetServicePlansRequestDto(List<String> typeNames)
    {
        this.TypeNames = typeNames;
    }

    @AuraEnabled
    public List<String> TypeNames {get; set;}

    @AuraEnabled
    public String OpportunityId {get; set;}

    @AuraEnabled
    public String Pricebook2Id {get; set;}

    @AuraEnabled
    public String VariantId {get; set;}

    @AuraEnabled
    public String ServicePlanId {get; set;}

    @AuraEnabled
    public String CorporatePartnerId {get; set;}
}