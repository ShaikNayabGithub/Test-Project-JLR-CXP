/*
*  @Name : RDATriggerHandler 
*  @Author : Masthan Andela 
*  @JIRA Number: 
*  @Description : Handler Class for update the Opportunity fields related to Service plan and Loyalty points caliculation and DeferDecision

*/

public class OpportunityDeferDecisionValuesUpdater {    
    public static Id DerivativeRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
    
    public static void OpportunityUpdateOnPostInsert(List<OpportunityLineItem> triggerNewList){        
        List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();        
        for(OpportunityLineItem lineItem : triggerNewList){            
            if(lineItem.Asset__c != null) lineItemList.add(lineItem);
        }        
        if(lineItemList.size() > 0) opportunityUpdater(lineItemList);
    }
    
    public static void OpportunityUpdateOnPostUpdate(List<OpportunityLineItem> triggerNewList, Map<Id,OpportunityLineItem> triggerOldMap){
        List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>();
        for(OpportunityLineItem lineItem : triggerNewList){ 
            if(lineItem.Asset__c != triggerOldMap.get(lineItem.Id).Asset__c && lineItem.Asset__c != null)  lineItemList.add(lineItem);
        }
        if(lineItemList.size() > 0) opportunityUpdater(lineItemList);
    }
    
    public static void opportunityUpdater(List<OpportunityLineItem> triggerNewList){
        List<String> CPCList = new List<String>();
        List<Id> schemeIdList = new List<Id>();
        List<Id> productIdList = new List<Id>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        Map<Id,Loyalty_points__c> loyaltiMap = new Map<Id,Loyalty_points__c>();
        Map<String,Product2> servicePlanMap = new Map<String,Product2>();        
        List<OpportunitylineItem> OpportunitylineItemList = [SELECT Id,Product2Id, OpportunityId,Opportunity.Account.IsPersonAccount, Opportunity.Account.Corporate_Programme_Code__c,
                                                             Opportunity.Account.Loyalty_Scheme__c, Asset__r.Derivative__c,Asset__r.Product2Id, Asset__r.Model_Year__c,
                                                             Asset__r.Product2.Specification_Pack_Alternative__c, Asset__r.Product2.Transmission__c, Asset__r.Engine__c, 
                                                             Asset__r.Wheel_Base__c, Asset__r.Product2.Engine_Capacity_Alternative__c, Asset__r.Wheels_Driven__c, Asset__r.Fuel_Type__c,
                                                             Asset__r.Exterior_Colour__c, Asset__r.Body_Style__c,Asset__r.Interior_Color__c, Asset__r.Power_Output_Value__c,Asset__r.VIN__c
                                                             FROM OpportunitylineItem   WHERE Id IN :triggerNewList ];
        for(OpportunitylineItem singleLineItem : OpportunitylineItemList){
            if(singleLineItem.Opportunity.Account.Loyalty_Scheme__c != null) schemeIdList.add(singleLineItem.Opportunity.Account.Loyalty_Scheme__c);
            if(singleLineItem.Asset__r.Derivative__c != null)  productIdList.add(singleLineItem.Asset__r.Derivative__c);
            if(singleLineItem.Opportunity.Account.Corporate_Programme_Code__c != null) CPCList.add(singleLineItem.Opportunity.Account.Corporate_Programme_Code__c);
        }
        /*for(Product2 singleProduct : [SELECT Id, Product__c, Service_Plan_Type__c,Corporate_Programme_Code__c FROM Product2 WHERE Product__c IN :productIdList AND 
                                      RecordtypeId =: ServiceplanrectypeId AND (Corporate_Programme_Code__c IN :CPCList OR Service_Plan_Type__c ='Free Service')]){
                                          String key;
                                          if(singleProduct.Corporate_Programme_Code__c != null)   key=(''+singleProduct.Corporate_Programme_Code__c).toLowercase();
                                          else key = singleProduct.Product__c;
                                          servicePlanMap.put(key,singleProduct);
                                      }*/
        for(Loyalty_points__c loyaltyPoints : [SELECT Id, Number_of_Points__c, Offer_End_Date__c, Is_Eligible__c, Corporate_multiplier__c, Bonus_Points__c,Offer_Start_Date__c,
                                               Individual_multiplier__c, Product__c, Loyalty_Scheme__c FROM Loyalty_points__c WHERE Product__c IN :productIdList AND
                                               Loyalty_Scheme__c IN : schemeIdList AND  Offer_End_Date__c >= :system.Date.today() AND Offer_Start_Date__c <= :system.Date.today()]){
                                                   loyaltiMap.put(loyaltyPoints.Product__c,loyaltyPoints);
                                               }
        for(OpportunitylineItem singleLineItem : OpportunitylineItemList){
            Opportunity opp = new Opportunity(Id =singleLineItem.OpportunityId);
            if(singleLineItem.Asset__c != null) {
               Id productId = singleLineItem.Asset__r.Derivative__c;
                if(productId != null && loyaltiMap.get(productId) != null && loyaltiMap.get(productId).Loyalty_Scheme__c == singleLineItem.Opportunity.Account.Loyalty_Scheme__c &&
                   !TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Loyalty_Points_Calculation_Disabled__c )
                    opp = pointsUpdate(opp,loyaltiMap.get(productId), singleLineItem.Opportunity.Account.IsPersonAccount);
                Opp.Model_Year__c = singleLineItem.Asset__r.Model_Year__c;
                Opp.Specification__c = singleLineItem.Asset__r.Product2.Specification_Pack_Alternative__c;
                Opp.Transmission__c = singleLineItem.Asset__r.Product2.Transmission__c;
                Opp.Engine__c =singleLineItem.Asset__r.Engine__c;
                Opp.Wheel_Base__c = singleLineItem.Asset__r.Wheel_Base__c;
                Opp.Engine_Capacity__c = singleLineItem.Asset__r.Product2.Engine_Capacity_Alternative__c;
                Opp.Wheels_Driven__c = singleLineItem.Asset__r.Wheels_Driven__c;
                Opp.Fuel_Type__c = singleLineItem.Asset__r.Fuel_Type__c;
                Opp.Exterior_Colour__c = singleLineItem.Asset__r.Exterior_Colour__c;
                Opp.Body_Style__c = singleLineItem.Asset__r.Body_Style__c;
                Opp.Interior_Colour__c = singleLineItem.Asset__r.Interior_Color__c;
                Opp.Power__c = singleLineItem.Asset__r.Power_Output_Value__c;
                Opp.VIN__c= singleLineItem.Asset__r.VIN__c;
                Opp.Is_Defer_Decision__c = false;
                Opp.Product__c = singleLineItem.Asset__r.Product2Id;
                /*if(singleLineItem.Opportunity.Account.Corporate_Programme_Code__c != null && servicePlanMap.get(singleLineItem.Opportunity.Account.Corporate_Programme_Code__c.toLowerCase()) != null)
                    Opp.Service_Plan__c = servicePlanMap.get(singleLineItem.Opportunity.Account.Corporate_Programme_Code__c.toLowerCase()).Id;
                else if(servicePlanMap.get(productId) != null) 
                    Opp.Service_Plan__c = servicePlanMap.get(productId).Id;*/
                updateOpportunityList.add(Opp);  
            } 
        }
        if(updateOpportunityList.size() > 0) update updateOpportunityList;        
    } 
    
    public static Opportunity pointsUpdate(Opportunity updatedOpportunity, Loyalty_points__c loyaltypoints, Boolean isPersonAccount){
        if(loyaltypoints.Is_Eligible__c && loyaltypoints.Offer_End_Date__c >= system.Date.today() && loyaltypoints.Offer_Start_Date__c <= system.Date.today()){
            if(isPersonAccount)
                updatedOpportunity.Bonus_Points__c = loyaltypoints.Bonus_Points__c + (loyaltypoints.Bonus_Points__c * (loyaltypoints.Individual_multiplier__c - 1)) + (loyaltypoints.Number_of_Points__c * (loyaltypoints.Individual_multiplier__c - 1));
            else
                updatedOpportunity.Bonus_Points__c = loyaltypoints.Bonus_Points__c + (loyaltypoints.Bonus_Points__c * (loyaltypoints.Corporate_multiplier__c - 1)) + (loyaltypoints.Number_of_Points__c * (loyaltypoints.Corporate_multiplier__c - 1));
            updatedOpportunity.Offer_End_Date__c = loyaltypoints.Offer_End_Date__c;
            updatedOpportunity.Loyalty_Points__c=loyaltypoints.Number_of_Points__c;
        } else if( !loyaltypoints.Is_Eligible__c && loyaltypoints.Offer_End_Date__c >= system.Date.today() && loyaltypoints.Offer_Start_Date__c <= system.Date.today()){
            updatedOpportunity.Offer_End_Date__c = loyaltypoints.Offer_End_Date__c;
            updatedOpportunity.Loyalty_Points__c=loyaltypoints.Number_of_Points__c;
            updatedOpportunity.Bonus_Points__c = 0;
        } else {
            updatedOpportunity.Offer_End_Date__c = null;
            updatedOpportunity.Loyalty_Points__c=0;
            updatedOpportunity.Bonus_Points__c = 0;
        }
        return updatedOpportunity;
    }
    
    public static void OpportunityUpdateOnPostDelete(List<OpportunityLineItem> triggerOldList){
        Map<Id, Opportunity> opportunityUpdateMap = new Map<Id, Opportunity>();
        for(OpportunityLineItem lineItem: triggerOldList){  
            opportunityUpdateMap.put(lineItem.OpportunityId, new Opportunity(Id= lineItem.OpportunityId, Model_Year__c = '',  Specification__c = '', Transmission__c = '', Engine__c = '',  
                                                      Wheel_Base__c = '', Engine_Capacity__c = '', Wheels_Driven__c = '', Fuel_Type__c = '', Exterior_Colour__c = '', 
                                                      Body_Style__c = '', Interior_Colour__c = '',  Power__c = '',  VIN__c= '',  Is_Defer_Decision__c = false,Loyalty_points__c=0,
                                                      Bonus_points__c=0, Offer_End_Date__c = null, Service_Plan__c = null));            
        } 
        if(opportunityUpdateMap.size() >0) update opportunityUpdateMap.values(); 
    }
}