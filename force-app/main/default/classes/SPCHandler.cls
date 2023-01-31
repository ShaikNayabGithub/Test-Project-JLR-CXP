/*--
||      Name : SPCTrigger
||      Author: JLR
||      Created Date : 14/July/2020
||      Modified By: Suhan Jain @Ntt Data
||      Modified Date : 14/July/2020
--*/
public class SPCHandler {
    public static String Complimentary = Label.SPC_Complimentary;
    
    public static void PreInsert(List<Service_Plan_Contract__c> currenstSPC)
    {
        set<Id> assetIdSet= New Set<Id>();
        Map<Id,Asset> assetSPCMap = New Map<Id,Asset>();
        for(Service_Plan_Contract__c singleSpc:currenstSPC)
        {
            if(singleSpc.Vehicle_Id__c !=null)
                assetIdSet.add(singleSpc.Vehicle_Id__c);
        }  
        
        assetSPCMap=New Map<Id,Asset>([select id, (select id, Start_Date__c, End_Date__c, Country_ISO_Code__c from Service_Plan_Contracts__r where Cancellation_Date__c=null  Order By End_Date__c DESC) from asset where ID IN :assetIdSet]);
        
        for(Service_Plan_Contract__c newSPC:currenstSPC)
        {
            if(assetSPCMap.containsKey(newSPC.Vehicle_Id__c) 
               && !assetSPCMap.get(newSPC.Vehicle_Id__c).Service_Plan_Contracts__r.isEmpty())
            {
                for(Service_Plan_Contract__c oldSPC:assetSPCMap.get(newSPC.Vehicle_Id__c).Service_Plan_Contracts__r)
                {
                    if( newSPC.Country_ISO_Code__c== oldSPC.Country_ISO_Code__c &&
                       ((newSPC.Start_Date__c >= oldSPC.Start_Date__c && newSPC.Start_Date__c <= oldSPC.End_Date__c) 
                        || (newSPC.End_Date__c >= oldSPC.Start_Date__c && newSPC.End_Date__c <= oldSPC.End_Date__c)
                        || (newSPC.Start_Date__c <= oldSPC.Start_Date__c && newSPC.End_Date__c >= oldSPC.End_Date__c)))
                    {
                        newSPC.adderror(system.label.SPC_Duplicate_validation_Erorr);
                        break;  
                    }
                }
            }
        }  
    }
    
    public static void setPriceForServiceContract(List<Service_Plan_Contract__c> servicePlanConForInsertLst){
        system.debug('servicePlanConForInsertLst --> '+servicePlanConForInsertLst);
        map<id,Service_Plan_Contract__c> assetMap = new map<id,Service_Plan_Contract__c>();
        for(Service_Plan_Contract__c spc : servicePlanConForInsertLst){
            if(spc.Vehicle_Id__c != null
               && spc.Assignment_Type__c == Complimentary
               && spc.Service_Plan_Product__c != null
               && spc.Country_ISO_Code__c != null){
                   assetMap.put(spc.Vehicle_Id__c,spc);
               }
        }
        system.debug('assetMap --> '+assetMap);
        if(!assetMap.isEmpty()){
            map<String,Service_Plan_Contract__c> productMap = new map<String,Service_Plan_Contract__c>();
            for(Asset assetIns : [select id,product2id,product2.productcode from Asset where id in:assetMap.keyset()]){
                productMap.put(assetIns.product2.productcode,assetMap.get(assetIns.Id));
            }
            
            system.debug('productMap --> '+productMap);
            
            if(!productMap.isEmpty()){
                map<id,Product_Price_Service_Plan__c> servicePlanMap = new map<id,Product_Price_Service_Plan__c>();
                for(Product_Price_Service_Plan__c prodSpc : [select id,Service_Plan_Price__c,CurrencyIsoCode,Pricebook__c,Derivative_Product_Code__c,Country_ISO_Code__c,Product_Description__c
                                                             from Product_Price_Service_Plan__c
                                                             where 
                                                             Derivative_Product_Code__c in:productMap.keyset()
                                                             AND Country_ISO_Code__c != null
                                                             AND Service_Plan_Price__c != null
                                                             AND Product_Description__c != null
                                                             AND Derivative_Product_Code__c != null
                                                             AND Product_Description__r.isActive = true]){
                                                                 if(productMap.containskey(prodSpc.Derivative_Product_Code__c)
                                                                    && productMap.get(prodSpc.Derivative_Product_Code__c).Country_ISO_Code__c == prodSpc.Country_ISO_Code__c){
                                                                        String assetId = productMap.get(prodSpc.Derivative_Product_Code__c).Vehicle_Id__c;
                                                                        servicePlanMap.put(assetId,prodSpc); 
                                                                    }
                                                             }
                
                system.debug('servicePlanMap --> '+servicePlanMap);
                if(servicePlanMap != null
                   && !servicePlanMap.isEmpty()){
                       for(Service_Plan_Contract__c spc : servicePlanConForInsertLst){
                           if(spc.Vehicle_Id__c != null
                              && spc.Assignment_Type__c == Complimentary
                              && spc.Service_Plan_Product__c != null
                              && spc.Country_ISO_Code__c != null
                              && servicePlanMap.containskey(spc.Vehicle_Id__c)
                              && servicePlanMap.get(spc.Vehicle_Id__c) != null){                                  
                                  Product_Price_Service_Plan__c proSerPlan = servicePlanMap.get(spc.Vehicle_Id__c);
                                  if(proSerPlan.Country_ISO_Code__c == spc.Country_ISO_Code__c){
                                      spc.Retail_Purchase_Price__c = proSerPlan.Service_Plan_Price__c;
                                      spc.CurrencyIsoCode  = proSerPlan.CurrencyIsoCode;
                                      system.debug('Retail_Purchase_Price__c --> '+spc.Retail_Purchase_Price__c);
                                  }                                  
                              }
                       }
                   }
            }
        }
    }
}