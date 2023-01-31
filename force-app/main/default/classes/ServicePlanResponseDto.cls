/**
 * Created by caleb@argologic.com.au on 27/07/2020.
 */

public with sharing class ServicePlanResponseDto
{
    @AuraEnabled
    public string ServicePlanId {get; set;}

    @AuraEnabled
    public string ServicePlanName {get; set;}

    @AuraEnabled
    public string ServicePlanType {get; set;}

    @AuraEnabled
    public string ServicePlanContractId {get; set;}

    public ServicePlanResponseDto(OpportunityLineItem oli)
    {
        this.ServicePlanName = oli.Product2.Name;
        this.ServicePlanType = oli.Assignment_Type__c;
        this.ServicePlanId = oli.Product2Id;
    }

    public ServicePlanResponseDto(Service_Plan_Contract__c spc)
    {
        this.ServicePlanName = spc.Service_Plan_Product__r.Name;
        this.ServicePlanType = 'Existing';
        this.ServicePlanId = spc.Service_Plan_Product__c;
        this.ServicePlanContractId = spc.Id;
    }
}