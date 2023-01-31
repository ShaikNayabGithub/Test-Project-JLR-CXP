public class RDALoyaltypointsCaliculation {
    public static Boolean isLoyaltyPointsCaliculated = false;
    public static Id DerivativeRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
    public static Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    
    public static void LoyaltypointsCaliculation(List<RDA__c> triggerNewList) {
        List<Id> CPCList = new List<Id>();
        List<Id> schemeIdList = new List<Id>();
        List<Id> productIdList = new List<Id>();
        List<RDA__c> updateRDAList = new List<RDA__c>();
        List<Loyalty_Points_Transaction__c> updateLPTList = new List<Loyalty_Points_Transaction__c>();        
        Map<Id, Service_Plan_Contract__c> RDAContractMap = new Map<Id, Service_Plan_Contract__c>();
        Map<Id, Loyalty_points__c> loyaltiMap = new Map<Id,Loyalty_points__c>();
        Map<Id, Product2> servicePlanMap = new Map<Id,Product2>();  
        Map<Id, PriceBookEntry> priceBookEntryMap = new Map<Id,PriceBookEntry>();         
        List<RDA__c> RDAList = [SELECT Id,Account__c, Submitted_Date__c,Account__r.IsPersonAccount, Account__r.Corporate_Programme_Code__c, Account__r.Loyalty_Scheme__c,Account__r.Owner.AccountId,Account__r.RecordtypeId,
                                Asset__r.Derivative__c,Asset__r.Product2Id,Account__r.Loyalty_Scheme_Reference__c, Account__r.Name,Service_Plan__c,Handover_Date__c,Opportunity__c,Service_Plan_Type__c,
                                Offer__c, Offer__r.Corporate_Partner__c, Assignment_Type__c,
                                (SELECT Id,Transaction_Delivery_Status__c FROM Loyalty_Points_Transactions__r WHERE Transaction_Delivery_Status__c ='Waiting to be Sent' LIMIT 1) 
                                FROM RDA__c WHERE Id IN :triggerNewList];
        for(RDA__c singleRDA : RDAList){
            if(singleRDA.Account__r.Loyalty_Scheme__c != null) schemeIdList.add(singleRDA.Account__r.Loyalty_Scheme__c);
            if(singleRDA.Asset__r.Derivative__c != null)  productIdList.add(singleRDA.Asset__r.Derivative__c);
            if(singleRDA.Account__r.Corporate_Programme_Code__c != null) CPCList.add(singleRDA.Account__r.Corporate_Programme_Code__c);
            if(singleRDA.Service_Plan_Type__c != null) servicePlanMap.put(singleRDA.Service_Plan_Type__c, null);
            
        }
        for(Product2 singleProduct : [SELECT Id, Product__c,Corporate_Programme_Code__c,Mileage_Months__c,Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c FROM Product2 WHERE Id IN :servicePlanMap.keySet()]){
            if(servicePlanMap.containsKey(singleProduct.Id)){
                servicePlanMap.put(singleProduct.Id, singleProduct);
            }
        }
        for(PricebookEntry pbe : [SELECT Product2Id, UnitPrice from PricebookEntry WHERE Product2Id IN : servicePlanMap.keyset() AND IsActive = TRUE AND PriceBook2.Name ='Australia']){
            priceBookEntryMap.put(pbe.Product2Id, pbe);
        }
        for(Loyalty_points__c loyaltyPoints : [SELECT Id, Number_of_Points__c, Offer_End_Date__c, Is_Eligible__c, Corporate_multiplier__c, Bonus_Points__c,Offer_Start_Date__c, 
                                               Individual_multiplier__c, Product__c, Loyalty_Scheme__c FROM Loyalty_points__c WHERE Product__c IN :productIdList AND
                                               Loyalty_Scheme__c IN : schemeIdList AND  Offer_End_Date__c >= :system.Date.today() AND Offer_Start_Date__c <= :system.Date.today()]){
                                                   loyaltiMap.put(loyaltyPoints.Product__c,loyaltyPoints);
                                               }
        for(RDA__c singleRDA : RDAList){
            Loyalty_Points_Transaction__c LPT = new Loyalty_Points_Transaction__c();
            if(singleRDA.Loyalty_Points_Transactions__r.size() > 0)  LPT.Id = singleRDA.Loyalty_Points_Transactions__r[0].Id;           
            LPT.Transaction_Date__c = singleRDA.Submitted_Date__c;
            LPT.Transaction_Delivery_Status__c ='Waiting to be Sent';
            LPT.Account_Name__c = singleRDA.Account__r.Name;
            LPT.RDA__c = singleRDA.Id;
            LPT.Loyalty_Scheme_Reference__c = singleRDA.Account__r.Loyalty_Scheme_Reference__c; 
            Id productId ; 
            if(singleRDA.Asset__c != null && singleRDA.Asset__r.Derivative__c != null) {
                productId = singleRDA.Asset__r.Derivative__c;
                if(productId != null && loyaltiMap.get(productId) != null && loyaltiMap.get(productId).Loyalty_Scheme__c == singleRDA.Account__r.Loyalty_Scheme__c && !TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Loyalty_Points_Calculation_Disabled__c ){
                    LPT = pointsUpdate_New(LPT,loyaltiMap.get(productId), singleRDA.Account__r.IsPersonAccount);
                }
               if(LPT.Base_Points__c  > 0 && LPT.Bonus_Points__c > 0) updateLPTList.add(LPT);
            }
          /*removed to seperate class
            if(singleRDA.Service_Plan_Type__c != null && servicePlanMap.containsKey(singleRDA.Service_Plan_Type__c)){
                Product2 servicePlan = servicePlanMap.get(singleRDA.Service_Plan_Type__c);
                String accountId ;
                if(singleRDA.Account__r.RecordtypeId == retailerRecordTypeId) accountId = singleRDA.Account__c ; else accountId =singleRDA.Account__r.Owner.AccountId;
                Decimal price = 0;
                if(singleRDA.Assignment_Type__c !=  null && singleRDA.Assignment_Type__c == 'Retail'){
                    price = priceBookEntryMap.get(singleRDA.Service_Plan_Type__c) != null ? priceBookEntryMap.get(singleRDA.Service_Plan_Type__c).UnitPrice : 0;
                }
                
                //Mileage_Months__c, Mileage_Measure__c, Mile_Kilometers__c, Months__c, Service_Plan_Type__c, Indicator__c, Transferable__c can all be populated as formula field from Service Plan
                
                
                Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
                spc.Retailer_Id__c = accountId;
                spc.Vehicle_Id__c = singleRDA.Asset__c; 
                spc.Start_Date__c = singleRDA.Handover_Date__c;
                if(servicePlan != null && serviceplan.Months__c != null && singleRDA.Handover_Date__c != null){
                    spc.End_Date__c = singleRDA.Handover_Date__c.addMonths(servicePlan.Months__c.intValue()).addDays(-1);
                    spc.Contract_Term_Months__c = servicePlan.Months__c.intValue();
                }              
                if(servicePlan != null){
                    spc.Service_Plan_Product__c = servicePlan.Id;
                }
                spc.Corporate_Partner__c = singleRDA.Offer__c != null ? singleRDA.Offer__r.Corporate_Partner__c : null;
                spc.Retail_Purchase_Price__c = price;
                spc.Assignment_Type__c = singleRDA.Assignment_Type__c;
                RDAContractMap.put(singleRDA.Id,spc);
            
            }*/
        }
        if(updateLPTList.size() > 0) upsert updateLPTList; 
       /*
        if(RDAContractMap.values().size() > 0){
            upsert RDAContractMap.values();
            boolean updateRDAs = false;
            for(RDA__c singleRDA : RDAList){
                if(RDAContractMap.get(singleRDA.Id) != null){
                    singleRDA.Service_Plan_Policy_Contract__c = RDAContractMap.get(singleRDA.Id).Id; //lookup Contract Id from RDA -> Contract Map
                    updateRDAs = true;
                }
            }
            if(updateRDAs) upsert rdaList;
        }*/
        isLoyaltyPointsCaliculated = true;
    } 
    
    public static Loyalty_Points_Transaction__c pointsUpdate_New(Loyalty_Points_Transaction__c updatedLPT, Loyalty_points__c loyaltypoints, Boolean isPersonAccount){
        if(loyaltypoints.Is_Eligible__c && loyaltypoints.Offer_End_Date__c >= system.Date.today() && loyaltypoints.Offer_Start_Date__c <= system.Date.today()){
            if(isPersonAccount){
                updatedLPT.Bonus_Points__c = loyaltypoints.Bonus_Points__c + (loyaltypoints.Bonus_Points__c * (loyaltypoints.Individual_multiplier__c - 1)) + (loyaltypoints.Number_of_Points__c * (loyaltypoints.Individual_multiplier__c - 1));
                updatedLPT.Multiplier__c = loyaltypoints.Individual_multiplier__c;
            } else{
                updatedLPT.Bonus_Points__c = loyaltypoints.Bonus_Points__c + (loyaltypoints.Bonus_Points__c * (loyaltypoints.Corporate_multiplier__c - 1)) + (loyaltypoints.Number_of_Points__c * (loyaltypoints.Corporate_multiplier__c - 1));
                updatedLPT.Multiplier__c = loyaltypoints.Corporate_multiplier__c;
            }
            updatedLPT.Base_Points__c = loyaltypoints.Number_of_Points__c;
        }
        else if( !loyaltypoints.Is_Eligible__c && loyaltypoints.Offer_End_Date__c >= system.Date.today() && loyaltypoints.Offer_Start_Date__c <= system.Date.today()){
            updatedLPT.Base_Points__c = loyaltypoints.Number_of_Points__c;
            updatedLPT.Bonus_Points__c = 0;
        }
        else {
            updatedLPT.Base_Points__c = 0;
            updatedLPT.Bonus_Points__c = 0;
        }
        return updatedLPT;
    }
    
}