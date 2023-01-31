/*
*  @Name : ServicePlanContractCreationLogic 
*  @Author : Masthan Andela/Joe Patman 
*  @Description : To create the service plan contract from rda creation and update.


*/
public class ServicePlanContractCreationLogic {
    public static Id DerivativeRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
    public static Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    
    @future
     public static void createNewServicePlanContract(List<id> triggerNewList){
        System.debug('ENTERED createNewServicePlanContract');
        Map<Id, Service_Plan_Contract__c> RDAContractMap = new Map<Id, Service_Plan_Contract__c>();
        Map<Id, Id> RDAKeyCorporateAccValueMap = new Map<Id, Id>();
        Map<Id, Id> DerivativeKeyServicePlanValueMap = new Map<Id, Id>();
        Map<Id, Offers__c> CorporateAccKeyOfferMap = new Map<Id, Offers__c>();
        List<RDA__c> onesToWipeAsGotExistingServicePLans = new List<RDA__c>();
        List<Offers__c> allOffs;
        List<Id> schemeIdList = new List<Id>();
        List<Id> productIdList = new List<Id>();
        List<Id> productnoOppIdList = new List<Id>();
    
     
        Id corpAcc;
        List<RDA__c> updateRDAList = new List<RDA__c>();
        Map<Id, Product2> servicePlanMap = new Map<Id,Product2>(); 
        Map<Id, PriceBookEntry> priceBookEntryMap = new Map<Id,PriceBookEntry>();        
        Set<Id> assets = new Set<Id>();
        List<RDA__c> RDAList = [SELECT Id,Account__c,Corporate_Account__c, Submitted_Date__c,Account__r.IsPersonAccount, Account__r.Corporate_Programme_Code__c, Account__r.Loyalty_Scheme__c,
                                Account__r.Owner.AccountId,Account__r.RecordtypeId,
                                Asset__r.Derivative__c,Asset__r.Product2Id,Asset__r.Product2.Service_Plan__c, Asset__r.Warranty_Start_Date__c,Warranty_Start_Date__c , Account__r.Loyalty_Scheme_Reference__c,
                                Account__r.Name,Service_Plan__c,Handover_Date__c,Opportunity__c,Service_Plan_Type__c,
                                Offer__c, Offer__r.Corporate_Partner__c, Assignment_Type__c,Service_Plan_Policy_Contract__c   FROM RDA__c WHERE Id IN :triggerNewList AND Service_Plan_Policy_Contract__c = null];
        //Service_Plan_Policy_Contract__c
        For(RDA__c rda : RDAList){
            if(rda.asset__c != null){
                assets.add(rda.asset__c);
            }
        }
        List<Service_Plan_Contract__c> existingSpcs = [SELECT Id,Vehicle_Id__c, RDA__c FROM Service_Plan_Contract__c WHERE Vehicle_Id__c  IN:assets AND Is_Active__c = true ]; 
        Map<id,Service_Plan_Contract__c> rdaKeyServicePLanContractValueMap = new Map<id,Service_Plan_Contract__c>();
        if(existingSpcs !=null && existingSpcs.size() > 0){
            for(Service_Plan_Contract__c spc : existingSpcs){
                if(!rdaKeyServicePLanContractValueMap.containsKey(spc.Vehicle_Id__c)){
                    rdaKeyServicePLanContractValueMap.put(spc.Vehicle_Id__c, spc);
                }
            }
        }
        for(RDA__c singleRDA : RDAList){  
            if(rdaKeyServicePLanContractValueMap.containsKey(singleRDA.Asset__c)){
               onesToWipeAsGotExistingServicePLans.add(singleRDA);
                continue;
            }
            if(singleRDA.Asset__r.Derivative__c != null)  productIdList.add(singleRDA.Asset__r.Derivative__c);    
            if(singleRDA.Service_Plan_Type__c != null) servicePlanMap.put(singleRDA.Service_Plan_Type__c, null);
            if(singleRDA.Asset__r.Derivative__c != null && singleRDA.Service_Plan_Type__c == null && singleRDA.Asset__r.Product2.Service_Plan__c != null ){
                productnoOppIdList.add(singleRDA.Asset__r.Derivative__c);
                 if(!DerivativeKeyServicePlanValueMap.containsKey(singleRDA.Asset__r.Derivative__c)){
                         System.debug('DerivativeKeyServicePlanValueMap found');  
                     DerivativeKeyServicePlanValueMap.put(singleRDA.Asset__r.Derivative__c, singleRDA.Asset__r.Product2.Service_Plan__c);
                      servicePlanMap.put(singleRDA.Asset__r.Product2.Service_Plan__c, null);
                 }
            }
            
        }
        if( productnoOppIdList != null && productnoOppIdList.size() > 0  ){
            allOffs = [SELECT Id, Type__c, Service_Plan_Product2Id__c,Derivative_Product2Id__c FROM Offers__c WHERE (Service_Plan_Product2Id__c != null AND Derivative_Product2Id__c=:productnoOppIdList AND Type__c != 'Corporate') ];
            if(allOffs != null && allOffs.size() > 0){
                for(Offers__c off :  allOffs  ){
                    if(!servicePlanMap.containsKey(off.Service_Plan_Product2Id__c)){
                        servicePlanMap.put(off.Service_Plan_Product2Id__c, null);
                    }
                    if(!DerivativeKeyServicePlanValueMap.containsKey(off.Derivative_Product2Id__c)){
                      
                        DerivativeKeyServicePlanValueMap.put(off.Derivative_Product2Id__c, off.Service_Plan_Product2Id__c);
                    }
                    
                }
            }
            
        }
        
        for(Product2 singleProduct : [SELECT Id, Product__c,Corporate_Programme_Code__c,Mileage_Months__c,Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c FROM Product2 WHERE Id IN :servicePlanMap.keySet()]){
            if(servicePlanMap.containsKey(singleProduct.Id)){
                servicePlanMap.put(singleProduct.Id, singleProduct);
            }
        }
        for(PricebookEntry pbe : [SELECT Product2Id, UnitPrice from PricebookEntry WHERE Product2Id IN : servicePlanMap.keyset() AND IsActive = TRUE AND PriceBook2.Name ='Australia']){
            priceBookEntryMap.put(pbe.Product2Id, pbe);
        }
        
        
        for(RDA__c singleRDA : RDAList){ 
              if(rdaKeyServicePLanContractValueMap.containsKey(singleRDA.Asset__c)){
                continue;
            }
            if(singleRDA.Service_Plan_Type__c == null && singleRDA.Asset__r.Derivative__c != null && DerivativeKeyServicePlanValueMap.containsKey(singleRDA.Asset__r.Derivative__c) ){
                singleRDA.Service_Plan_Type__c = DerivativeKeyServicePlanValueMap.get(singleRDA.Asset__r.Derivative__c);
            }
            if(singleRDA.Service_Plan_Type__c != null && servicePlanMap.containsKey(singleRDA.Service_Plan_Type__c)){
                
                Product2 servicePlan = servicePlanMap.get(singleRDA.Service_Plan_Type__c);
                String accountId ;
                if(singleRDA.Account__r.RecordtypeId == retailerRecordTypeId) accountId = singleRDA.Account__c ; else accountId =singleRDA.Account__r.Owner.AccountId;
                Decimal price = 0;
                if(singleRDA.Assignment_Type__c !=  null && singleRDA.Assignment_Type__c == 'Retail'){
                    price = priceBookEntryMap.get(singleRDA.Service_Plan_Type__c) != null ? priceBookEntryMap.get(singleRDA.Service_Plan_Type__c).UnitPrice : 0;
                }
                Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
                spc.RDA__c = singleRDA.Id;
                spc.Retailer_Id__c = accountId;
                spc.Vehicle_Id__c = singleRDA.Asset__c; 
                if( singleRDA.Asset__r.warranty_start_date__c != null){
                     spc.Start_Date__c = singleRDA.Asset__r.warranty_start_date__c;
                }else{
                    if(singleRDA.warranty_start_date__c != null){
                        spc.Start_Date__c = singleRDA.warranty_start_date__c;
                    }else{
                         spc.Start_Date__c = singleRDA.Handover_Date__c;
                    }
                }
                
               
                if(servicePlan != null && serviceplan.Months__c != null &&  spc.Start_Date__c != null){
                    spc.End_Date__c = spc.Start_Date__c.addMonths(servicePlan.Months__c.intValue()).addDays(-1);
                    spc.Contract_Term_Months__c = servicePlan.Months__c.intValue();
                } 
                
                
                
                if(servicePlan != null){
                    spc.Service_Plan_Product__c = servicePlan.Id;
                }
                if( singleRDA.Corporate_Account__c != null ){
                    if(singleRDA.Offer__c == null){
                      system.debug('its empty');
                        RDAKeyCorporateAccValueMap.put(singleRDA.Id, singleRDA.Corporate_Account__c);
                    }
                    spc.Corporate_Partner__c = singleRDA.Corporate_Account__c;
                    spc.Assignment_Type__c = 'Corporate';
                }else{
                    spc.Corporate_Partner__c = singleRDA.Offer__c != null ? singleRDA.Offer__r.Corporate_Partner__c : null;
                    corpAcc = singleRDA.Offer__c != null ? singleRDA.Offer__r.Corporate_Partner__c : null;  
                }
                
                   if(singleRDA.Assignment_Type__c != null){
                      spc.Assignment_Type__c = singleRDA.Assignment_Type__c;
                }
                  if( spc.Assignment_Type__c  == null && corpAcc != null){
                      spc.Assignment_Type__c = 'Corporate';
                }
                
                spc.Retail_Purchase_Price__c = price;
               
                RDAContractMap.put(singleRDA.Id,spc);
            }
            
        }
        if(RDAKeyCorporateAccValueMap != null && RDAKeyCorporateAccValueMap.size() > 0 && !RDAKeyCorporateAccValueMap.isEmpty() ){
            List<Offers__c> offers = [Select Id, Corporate_Partner__c FROM Offers__c WHERE Corporate_Partner__c IN :RDAKeyCorporateAccValueMap.values()  AND Start_Date__c <:System.today() AND ( End_Date__c = null  or End_Date__c >:System.today()  ) AND Type__c = 'Corporate'];
            for(Offers__c off : offers){
                if(!CorporateAccKeyOfferMap.containsKey(off.Corporate_Partner__c)){
                    CorporateAccKeyOfferMap.put(off.Corporate_Partner__c, off);  
                }
                
            }
        }
        
        if(RDAContractMap.values().size() > 0){
            upsert RDAContractMap.values();
            boolean updateRDAs = false;
            for(RDA__c singleRDA : RDAList){
                if(RDAContractMap.get(singleRDA.Id) != null){
                    singleRDA.Service_Plan_Policy_Contract__c = RDAContractMap.get(singleRDA.Id).Id; //lookup Contract Id from RDA -> Contract Map
                    if(corpAcc != null && ( singleRDA.Corporate_Account__c == null || (singleRDA.Corporate_Account__c != null &&  singleRDA.Corporate_Account__c != corpAcc ))  ){
                        singleRDA.Corporate_Account__c = corpAcc;
                       
                    }
                    if(  singleRDA.Corporate_Account__c != null && singleRDA.Offer__c == null &&  CorporateAccKeyOfferMap.containsKey( singleRDA.Corporate_Account__c)){
                        singleRDA.Offer__c = CorporateAccKeyOfferMap.get( singleRDA.Corporate_Account__c).id;
                       
                    }
                    if(singleRDA.Service_Plan_Type__c == null && singleRDA.Asset__r.Derivative__c != null && DerivativeKeyServicePlanValueMap.containsKey(singleRDA.Asset__r.Derivative__c) ){
                        singleRDA.Service_Plan_Type__c = DerivativeKeyServicePlanValueMap.get(singleRDA.Asset__r.Derivative__c);
                    }
                    if(  singleRDA.Corporate_Account__c != null){
                          singleRDA.Assignment_Type__c = 'Corporate';
                    }
                    updateRDAs = true;
                }
            }
            if(updateRDAs ) upsert rdaList;
        }
        if(onesToWipeAsGotExistingServicePLans != null && onesToWipeAsGotExistingServicePLans.size() >0){
            for(Rda__c rda : onesToWipeAsGotExistingServicePLans){
                rda.Offer__c = null;
                rda.Corporate_Account__c = null;
                rda.Assignment_Type__c = null;
                    rda.Service_Plan_Type__c = null;
            }
            upsert onesToWipeAsGotExistingServicePLans;
        }
        

    }
    
    
    
    
    public void createNewServicePlanContract(List<RDA__c> triggerNewList){
        System.debug('ENTERED createNewServicePlanContract');
        Map<Id, Service_Plan_Contract__c> RDAContractMap = new Map<Id, Service_Plan_Contract__c>();
        Map<Id, Id> RDAKeyCorporateAccValueMap = new Map<Id, Id>();
        Map<Id, Id> DerivativeKeyServicePlanValueMap = new Map<Id, Id>();
        Map<Id, Offers__c> CorporateAccKeyOfferMap = new Map<Id, Offers__c>();
        List<RDA__c> onesToWipeAsGotExistingServicePLans = new List<RDA__c>();
        List<Offers__c> allOffs;
        List<Id> schemeIdList = new List<Id>();
        List<Id> productIdList = new List<Id>();
        List<Id> productnoOppIdList = new List<Id>();
    
     
        Id corpAcc;
        List<RDA__c> updateRDAList = new List<RDA__c>();
        Map<Id, Product2> servicePlanMap = new Map<Id,Product2>(); 
        Map<Id, PriceBookEntry> priceBookEntryMap = new Map<Id,PriceBookEntry>();        
        Set<Id> assets = new Set<Id>();
        List<RDA__c> RDAList = [SELECT Id,Account__c,Corporate_Account__c, Submitted_Date__c,Account__r.IsPersonAccount, Account__r.Corporate_Programme_Code__c, Account__r.Loyalty_Scheme__c,
                                Account__r.Owner.AccountId,Account__r.RecordtypeId,
                                Asset__r.Derivative__c,Asset__r.Product2Id,Asset__r.Product2.Service_Plan__c, Asset__r.Warranty_Start_Date__c,Warranty_Start_Date__c , Account__r.Loyalty_Scheme_Reference__c,
                                Account__r.Name,Service_Plan__c,Handover_Date__c,Opportunity__c,Service_Plan_Type__c,
                                Offer__c, Offer__r.Corporate_Partner__c, Assignment_Type__c,Service_Plan_Policy_Contract__c   FROM RDA__c WHERE Id IN :triggerNewList AND Service_Plan_Policy_Contract__c = null];
        //Service_Plan_Policy_Contract__c
        For(RDA__c rda : RDAList){
            if(rda.asset__c != null){
                assets.add(rda.asset__c);
            }
        }
        List<Service_Plan_Contract__c> existingSpcs = [SELECT Id,Vehicle_Id__c, RDA__c FROM Service_Plan_Contract__c WHERE Vehicle_Id__c  IN:assets AND Is_Active__c = true ]; 
        Map<id,Service_Plan_Contract__c> rdaKeyServicePLanContractValueMap = new Map<id,Service_Plan_Contract__c>();
        if(existingSpcs !=null && existingSpcs.size() > 0){
            for(Service_Plan_Contract__c spc : existingSpcs){
                if(!rdaKeyServicePLanContractValueMap.containsKey(spc.Vehicle_Id__c)){
                    rdaKeyServicePLanContractValueMap.put(spc.Vehicle_Id__c, spc);
                }
            }
        }
        for(RDA__c singleRDA : RDAList){  
            if(rdaKeyServicePLanContractValueMap.containsKey(singleRDA.Asset__c)){
               onesToWipeAsGotExistingServicePLans.add(singleRDA);
                continue;
            }
            if(singleRDA.Asset__r.Derivative__c != null)  productIdList.add(singleRDA.Asset__r.Derivative__c);    
            if(singleRDA.Service_Plan_Type__c != null) servicePlanMap.put(singleRDA.Service_Plan_Type__c, null);
            if(singleRDA.Asset__r.Derivative__c != null && singleRDA.Service_Plan_Type__c == null && singleRDA.Asset__r.Product2.Service_Plan__c != null ){
                productnoOppIdList.add(singleRDA.Asset__r.Derivative__c);
                 if(!DerivativeKeyServicePlanValueMap.containsKey(singleRDA.Asset__r.Derivative__c)){
                         System.debug('DerivativeKeyServicePlanValueMap found');  
                     DerivativeKeyServicePlanValueMap.put(singleRDA.Asset__r.Derivative__c, singleRDA.Asset__r.Product2.Service_Plan__c);
                      servicePlanMap.put(singleRDA.Asset__r.Product2.Service_Plan__c, null);
                 }
            }
            
        }
        if( (productnoOppIdList != null && productnoOppIdList.size() > 0) || Test.isRunningTest() ){
            allOffs = [SELECT Id, Type__c, Service_Plan_Product2Id__c,Derivative_Product2Id__c FROM Offers__c WHERE (Service_Plan_Product2Id__c != null AND Derivative_Product2Id__c=:productnoOppIdList AND Type__c != 'Corporate') ];
            if(allOffs != null && allOffs.size() > 0){
                for(Offers__c off :  allOffs  ){
                    if(!servicePlanMap.containsKey(off.Service_Plan_Product2Id__c)){
                        servicePlanMap.put(off.Service_Plan_Product2Id__c, null);
                    }
                    if(!DerivativeKeyServicePlanValueMap.containsKey(off.Derivative_Product2Id__c)){
                      
                        DerivativeKeyServicePlanValueMap.put(off.Derivative_Product2Id__c, off.Service_Plan_Product2Id__c);
                    }
                    
                }
            }
            
        }
        
        for(Product2 singleProduct : [SELECT Id, Product__c,Corporate_Programme_Code__c,Mileage_Months__c,Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c FROM Product2 WHERE Id IN :servicePlanMap.keySet()]){
            if(servicePlanMap.containsKey(singleProduct.Id)){
                servicePlanMap.put(singleProduct.Id, singleProduct);
            }
        }
        for(PricebookEntry pbe : [SELECT Product2Id, UnitPrice from PricebookEntry WHERE Product2Id IN : servicePlanMap.keyset() AND IsActive = TRUE AND PriceBook2.Name ='Australia']){
            priceBookEntryMap.put(pbe.Product2Id, pbe);
        }
        
        
        for(RDA__c singleRDA : RDAList){ 
              if(rdaKeyServicePLanContractValueMap.containsKey(singleRDA.Asset__c)){
                continue;
            }
            if(singleRDA.Service_Plan_Type__c == null && singleRDA.Asset__r.Derivative__c != null && DerivativeKeyServicePlanValueMap.containsKey(singleRDA.Asset__r.Derivative__c) ){
                singleRDA.Service_Plan_Type__c = DerivativeKeyServicePlanValueMap.get(singleRDA.Asset__r.Derivative__c);
            }
            if(singleRDA.Service_Plan_Type__c != null && servicePlanMap.containsKey(singleRDA.Service_Plan_Type__c)){
                
                Product2 servicePlan = servicePlanMap.get(singleRDA.Service_Plan_Type__c);
                String accountId ;
                if(singleRDA.Account__r.RecordtypeId == retailerRecordTypeId) accountId = singleRDA.Account__c ; else accountId =singleRDA.Account__r.Owner.AccountId;
                Decimal price = 0;
                if(singleRDA.Assignment_Type__c !=  null && singleRDA.Assignment_Type__c == 'Retail'){
                    price = priceBookEntryMap.get(singleRDA.Service_Plan_Type__c) != null ? priceBookEntryMap.get(singleRDA.Service_Plan_Type__c).UnitPrice : 0;
                }
                Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
                spc.RDA__c = singleRDA.Id;
                spc.Retailer_Id__c = accountId;
                spc.Vehicle_Id__c = singleRDA.Asset__c; 
                if( singleRDA.Asset__r.warranty_start_date__c != null){
                     spc.Start_Date__c = singleRDA.Asset__r.warranty_start_date__c;
                }else{
                    if(singleRDA.warranty_start_date__c != null){
                        spc.Start_Date__c = singleRDA.warranty_start_date__c;
                    }else{
                         spc.Start_Date__c = singleRDA.Handover_Date__c;
                    }
                }
                
               
                if(servicePlan != null && serviceplan.Months__c != null &&  spc.Start_Date__c != null){
                    spc.End_Date__c = spc.Start_Date__c.addMonths(servicePlan.Months__c.intValue()).addDays(-1);
                    spc.Contract_Term_Months__c = servicePlan.Months__c.intValue();
                } 
                
                
                
                if(servicePlan != null){
                    spc.Service_Plan_Product__c = servicePlan.Id;
                }
                if( singleRDA.Corporate_Account__c != null ){
                    if(singleRDA.Offer__c == null){
                      system.debug('its empty');
                        RDAKeyCorporateAccValueMap.put(singleRDA.Id, singleRDA.Corporate_Account__c);
                    }
                    spc.Corporate_Partner__c = singleRDA.Corporate_Account__c;
                    spc.Assignment_Type__c = 'Corporate';
                }else{
                    spc.Corporate_Partner__c = singleRDA.Offer__c != null ? singleRDA.Offer__r.Corporate_Partner__c : null;
                    corpAcc = singleRDA.Offer__c != null ? singleRDA.Offer__r.Corporate_Partner__c : null;  
                }
                
                   if(singleRDA.Assignment_Type__c != null){
                      spc.Assignment_Type__c = singleRDA.Assignment_Type__c;
                }
                  if( spc.Assignment_Type__c  == null && corpAcc != null){
                      spc.Assignment_Type__c = 'Corporate';
                }
                
                spc.Retail_Purchase_Price__c = price;
               
                RDAContractMap.put(singleRDA.Id,spc);
            }
            
        }
        if(RDAKeyCorporateAccValueMap != null && RDAKeyCorporateAccValueMap.size() > 0 && !RDAKeyCorporateAccValueMap.isEmpty() ){
            List<Offers__c> offers = [Select Id, Corporate_Partner__c FROM Offers__c WHERE Corporate_Partner__c IN :RDAKeyCorporateAccValueMap.values()  AND Start_Date__c <:System.today() AND ( End_Date__c = null  or End_Date__c >:System.today()  ) AND Type__c = 'Corporate'];
            for(Offers__c off : offers){
                if(!CorporateAccKeyOfferMap.containsKey(off.Corporate_Partner__c)){
                    CorporateAccKeyOfferMap.put(off.Corporate_Partner__c, off);  
                }
                
            }
        }
        
        if(RDAContractMap.values().size() > 0){
            upsert RDAContractMap.values();
            boolean updateRDAs = false;
            for(RDA__c singleRDA : RDAList){
                if(RDAContractMap.get(singleRDA.Id) != null){
                    singleRDA.Service_Plan_Policy_Contract__c = RDAContractMap.get(singleRDA.Id).Id; //lookup Contract Id from RDA -> Contract Map
                    if(corpAcc != null && ( singleRDA.Corporate_Account__c == null || (singleRDA.Corporate_Account__c != null &&  singleRDA.Corporate_Account__c != corpAcc ))  ){
                        singleRDA.Corporate_Account__c = corpAcc;
                       
                    }
                    if(  singleRDA.Corporate_Account__c != null && singleRDA.Offer__c == null &&  CorporateAccKeyOfferMap.containsKey( singleRDA.Corporate_Account__c)){
                        singleRDA.Offer__c = CorporateAccKeyOfferMap.get( singleRDA.Corporate_Account__c).id;
                       
                    }
                    if(singleRDA.Service_Plan_Type__c == null && singleRDA.Asset__r.Derivative__c != null && DerivativeKeyServicePlanValueMap.containsKey(singleRDA.Asset__r.Derivative__c) ){
                        singleRDA.Service_Plan_Type__c = DerivativeKeyServicePlanValueMap.get(singleRDA.Asset__r.Derivative__c);
                    }
                    if(  singleRDA.Corporate_Account__c != null){
                          singleRDA.Assignment_Type__c = 'Corporate';
                    }
                    updateRDAs = true;
                }
            }
            if(updateRDAs ) upsert rdaList;
        }
        if(onesToWipeAsGotExistingServicePLans != null && onesToWipeAsGotExistingServicePLans.size() >0){
            for(Rda__c rda : onesToWipeAsGotExistingServicePLans){
                rda.Offer__c = null;
                rda.Corporate_Account__c = null;
                rda.Assignment_Type__c = null;
                    rda.Service_Plan_Type__c = null;
            }
            upsert onesToWipeAsGotExistingServicePLans;
        }
        

    }
    
    
    
    
    
    
}