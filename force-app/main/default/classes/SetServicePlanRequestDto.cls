/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/11/2019.
 */

global with sharing class SetServicePlanRequestDto extends BaseSetOpportunityLineItemRequestDto{

    @AuraEnabled
    global String ServicePlanId {get; set;} //Offers__c.

    @AuraEnabled
    global String ServicePlanType {
        get{
        return this.varServicePlanType;
    }
        set{
            if (getValidServicePlanTypes().contains(value.toLowerCase())){
                this.varServicePlanType = value;
            }
            else{
                throw new JlrCustomException(value + 'is not a valid');
            }
    }


    }

    private String varServicePlanType;

    private List<String> getValidServicePlanTypes(){
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Assignment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> vals = new List<String>();
        for (Schema.PicklistEntry entry : ple){
            vals.add(entry.getValue().toLowerCase());
        }
        return vals;
    }

}