public without sharing class TransferServicePlanController {
    
    @AuraEnabled
    Public static AssetDetail getAssetDetails(string assetId,String prodId){
        system.debug('assetId --> '+assetId);
        system.debug('prodId --> '+prodId);
        AssetDetail assetDetailsOb = new AssetDetail();
        assetDetailsOb.hasActiveServicePlan = false;
        assetDetailsOb.showConfirmScreen = false;
        //  searchText = searchText+'%';
        List<Asset> asses = [SELECT Id,Product2.Product_Description__c, is_New_Vehicle__c, Name, Model__c,Brand__c, Brand__r.Name, Model__r.Name, Product2.Model_Year__c,Account.Country_Iso_code__c,
                             AccountId, AccountCountryCode__c, Registration_Number__c, VIN__c,  Handover_Date__c, Warranty_End_Date__c, Warranty_Start_Date__c, Extended_Warranty_End_Date__c, Original_Handover_Date__c,
                             Derivative__r.Name, Derivative__r.Service_Plan__c, Derivative__r.Service_Plan__r.Service_Plan_Type__c, Derivative__r.Service_Plan__r.Name, Model_Year__c, toLabel(Transmission__c), Exterior_Colour__c, Model_Code__c,Vista_Status__c,Common_Sale_Type__c,Sale_Type_Code__c
                             FROM Asset WHERE ID=:assetId ];
        if(asses == null || asses.isEmpty()) throw new AuraHandledException('Vehicle is not Accessible or not shared with your user'); 
        Asset assIns = asses.get(0);
        if(assIns != null 
           && assIns.AccountCountryCode__c != null){
               List<string> APMarketCountryIsoCode = new List<string>();
               List<string> JPMarketCountryIsoCode = new List<string>();
               
               If(string.isNotBlank(system.label.CXP_AUTO_SPC_ON_HANDOVER) && 
                  string.isNotEmpty(system.label.CXP_AUTO_SPC_ON_HANDOVER)){
                      APMarketCountryIsoCode= system.label.CXP_AUTO_SPC_ON_HANDOVER.split(';');
                      system.debug('APMarketCountryIsoCode --> '+APMarketCountryIsoCode); 
                  } If(string.isNotBlank(system.label.CXP_AUTO_SPC_ON_HANDOVER_New) && 
                       string.isNotEmpty(system.label.CXP_AUTO_SPC_ON_HANDOVER_New)){
                           JPMarketCountryIsoCode= system.label.CXP_AUTO_SPC_ON_HANDOVER_New.split(';');
                           system.debug('JPMarketCountryIsoCode --> '+JPMarketCountryIsoCode); 
                       }
               
               system.debug('Model --> '+assIns.Model__c);
               system.debug('AccountCountryCode --> '+assIns.AccountCountryCode__c);
               system.debug('Brand --> '+assIns.Brand__c);
               
               if(APMarketCountryIsoCode.contains(assIns.AccountCountryCode__c)){
                   
               }else if(JPMarketCountryIsoCode.contains(assIns.AccountCountryCode__c)
                        && assIns.Model__c != null
                        && assIns.AccountCountryCode__c != null
                        && assIns.Brand__c != null){
                            id extServPlanId;
                            for(Service_Plans_Model__c spm : [select 
                                                              id,Auto_Add_Extended_Plan__c,Brand__c,Complementary_Service_Plan__c,
                                                              Extended_Service_Plan__r.Months__c,
                                                              Extended_Service_Plan__r.CurrencyIsoCode,
                                                              Extended_Service_Plan__r.Service_Interval_Distance__c,
                                                              Extended_Service_Plan__r.Service_Interval_Time__c,
                                                              Extended_Service_Plan__r.Number_of_Services__c,
                                                              Model__c,Region_or_Market__c
                                                              FROM Service_Plans_Model__c
                                                              WHERE Brand__c =: assIns.Brand__c
                                                              AND Extended_Service_Plan__c != null
                                                              AND Region_or_Market__c =: assIns.AccountCountryCode__c
                                                              AND Model__c =: assIns.Model__c limit 1]){
                                                                  extServPlanId = spm.Extended_Service_Plan__c;
                                                              }
                            if(extServPlanId != null){
                                map<Id,PricebookEntry> PricebookEntryMap = new map<Id,PricebookEntry>();
                                for(PricebookEntry pbe :[SELECT Product2Id, 
                                                         Pricebook2Id, 
                                                         PriceBook2.Country_ISO_Code__c,
                                                         CurrencyIsoCode,
                                                         UnitPrice 
                                                         from PricebookEntry 
                                                         WHERE 
                                                         IsActive = TRUE AND 
                                                         (Product2Id =: prodId OR Product2Id =: extServPlanId)
                                                         AND PriceBook2.Country_ISO_Code__c =: assIns.AccountCountryCode__c]){
                                                             PricebookEntryMap.put(pbe.Product2Id,pbe);
                                                         }
                                system.debug('1 --> '+PricebookEntryMap.containskey(prodId));
                                system.debug('2 --> '+PricebookEntryMap.containskey(extServPlanId));
                                if(extServPlanId != null){
                                    assetDetailsOb.existingServicePlanId = extServPlanId;
                                }
                                if(prodId != null){
                                    assetDetailsOb.newServicePlanId = prodId;
                                }
                                if(PricebookEntryMap.containskey(prodId)){
                                    assetDetailsOb.existingServicePlanPrice = PricebookEntryMap.get(prodId).UnitPrice;
                                    assetDetailsOb.currencyIsoCode = PricebookEntryMap.get(prodId).CurrencyIsoCode;
                                }
                                if(PricebookEntryMap.containskey(extServPlanId)){
                                    assetDetailsOb.newServicePlanPrice = PricebookEntryMap.get(extServPlanId).UnitPrice;
                                    assetDetailsOb.currencyIsoCode = PricebookEntryMap.get(extServPlanId).CurrencyIsoCode;
                                }
                                system.debug('newServicePlanPrice --> '+assetDetailsOb.newServicePlanPrice);
                                system.debug('existingServicePlanPrice --> '+assetDetailsOb.existingServicePlanPrice);
                                if(assetDetailsOb.newServicePlanPrice != null 
                                   && assetDetailsOb.existingServicePlanPrice != null){
                                       if(assetDetailsOb.existingServicePlanPrice < assetDetailsOb.newServicePlanPrice){
                                           assetDetailsOb.upliftChargeAmount = assetDetailsOb.newServicePlanPrice - assetDetailsOb.existingServicePlanPrice;
                                           assetDetailsOb.showConfirmScreen = true;
                                           assetDetailsOb.refund = false;
                                       }else  if(assetDetailsOb.existingServicePlanPrice == assetDetailsOb.newServicePlanPrice){
                                           assetDetailsOb.upliftChargeAmount = 0; 
                                           assetDetailsOb.refund = false;
                                       }else  if(assetDetailsOb.existingServicePlanPrice > assetDetailsOb.newServicePlanPrice){
                                           assetDetailsOb.refund = true;
                                       }
                                   }
                            }
                        }
           }
        
        assetDetailsOb.spcs =  [SELECT Id,  Name, Cancellation_Date__c, 
                                Contract_Term_Months__c, Disposal_Date__c, End_Date__c, Mileage_Months__c, Actual_End_Date__c, Mileage__c, Months__c, Policy_Number__c, Retailer_Id__c, Service_Plan_Product__c,Service_Plan_Product__r.Name, Service_Plan_Type__c, Start_Date__c,  
                                Vehicle_Id__c, Assignment_Type__c, Corporate_Partner__c,Corporate_Partner__r.Name, Retail_Purchase_Price__c,Country_ISO_Code__c,
                                Service_Plan_Incremental__c, Service_Plan_Reference__c, Month_Submitted__c, RDA__c, Is_Active__c FROM Service_Plan_Contract__c  WHERE Vehicle_Id__c = :asses[0].id ORDER BY Start_Date__c ASC];
        
        for(Service_Plan_Contract__c spc : assetDetailsOb.spcs){
            if(spc.Service_Plan_Type__c !='Complimentary Service' && spc.Cancellation_Date__c == null){
                assetDetailsOb.hasActiveServicePlan = true;
                // break;
            } 
            if(spc.Actual_End_Date__c != null){
                assetDetailsOb.startDate=spc.Actual_End_Date__c+1;
            }
        }
        assetDetailsOb.Asset = asses[0];
        return assetDetailsOb;
    }
    
    
    @AuraEnabled
    Public static List<Asset> getAssetVehicleDetails(string searchText){
        system.debug('searchText --> '+searchText);
        searchText = String.escapeSingleQuotes(searchText);
        searchText = '%'+searchText+'%';   
        system.debug('searchText1 --> '+searchText);
        List<Asset> assetList = [SELECT Id, Name FROM Asset WHERE (Registration_Number__c LIKE :searchText OR VIN__c LIKE :searchText OR Name Like :searchText) Limit 10];
        return assetList;
    }
    
    
    @AuraEnabled
    Public static void transferServicePlan(string assetId, string servicePlanId,String servicePlanContId, Date StartDate,decimal upliftChargeAmount,Boolean refund){
        system.debug('assetId --> '+assetId);
        system.debug('servicePlanId --> '+servicePlanId);
        system.debug('servicePlanContId --> '+servicePlanContId);
        system.debug('StartDate --> '+StartDate);
        system.debug('upliftChargeAmount --> '+upliftChargeAmount);
        system.debug('refund --> '+refund);
        
        Product2 servicePlan = [select 
                                id,Service_Plan__c,Months__c,Mileage_Months__c,Miles_Kilometers__c,Mileage_Measure__c,
                                Number_of_Services__c,Service_Interval_Distance__c,Service_Interval_Time__c,Service_Plan_Type__c
                                from Product2 where id =: servicePlanId];
        
        List<Service_Plan_Contract__c> spcList = [select Id,Service_Plan_Uplift_Charge__c,Service_Plan_Length_Check__c,Service_Plan_Incremental__c,Vehicle_Id__r.VIN__c,Retail_Purchase_Price__c,Total_Purchase_Price__c, Vehicle_Id__c, End_Date__c,Service_Plan_Product__c,Service_Plan_Product__r.Months__c, Start_Date__c, Previous_Asset__c, Transferred_by__c, Transfer_date__c from Service_Plan_Contract__c Where Id=:servicePlanContId];
        if(spcList == null || spcList.isEmpty()) throw new AuraHandledException(Label.SPC_Service_Plan_Error);
        Service_Plan_Contract__c spc = spcList.get(0);
        spc.Previous_Asset__c=spc.Vehicle_Id__c;
        spc.Vehicle_Id__c=assetId;
        spc.Start_Date__c= StartDate;
        if(spc.Start_Date__c != null && SPC.Service_Plan_Product__c != null && SPC.Service_Plan_Product__r.Months__c != null){
            spc.End_Date__c= spc.Start_Date__c.addMonths(SPC.Service_Plan_Product__r.Months__c.intValue()).addDays(-1);
        }
        spc.Transfer_date__c= system.today();
        spc.Transferred_by__c=userinfo.getUserId();
        spc.Service_Plan_Uplift_Charge__c = upliftChargeAmount;
        spc.Service_Plan_Uplift_Status__c = 'Charge Due';
        spc.Service_Plan_Contract_Status__c = 'Transferred';
        if(spc.Service_Plan_Uplift_Charge__c != null && spc.Retail_Purchase_Price__c != null){
            spc.Total_Purchase_Price__c = spc.Service_Plan_Uplift_Charge__c+spc.Retail_Purchase_Price__c;
        }
        
        spc.Mileage_Months_SPC__c = servicePlan.Mileage_Months__c;
        if(servicePlan.Miles_Kilometers__c != null
           && servicePlan.Mileage_Measure__c != null){
               spc.Mileage_SPC__c = String.valueOf(servicePlan.Miles_Kilometers__c)+' '+String.valueOf(servicePlan.Mileage_Measure__c);
           }
        spc.Months_spc__c = servicePlan.Months__c;
        spc.Service_Plan_Type_SPC__c = servicePlan.Service_Plan_Type__c;
        if(spc.Vehicle_Id__c != null && spc.Vehicle_Id__r.VIN__c != null && spc.Service_Plan_Incremental__c != null){
            spc.Service_Plan_Reference_spc__c = spc.Vehicle_Id__r.VIN__c.mid(4,2)+'-CXP-'+spc.Vehicle_Id__r.VIN__c.right(6)+'-'+spc.Service_Plan_Incremental__c;
        }
        if(spc.End_Date__c != null && spc.Start_Date__c != null){
            spc.Service_Plan_Length_Check_SPC__c = (spc.End_Date__c.daysBetween(spc.Start_Date__c))/365;
        }
        
        update spc;
        
        Service_Plan_Contract__c updatedSpc = [select id,Service_Plan_Reference__c,Service_Plan_Incremental__c,Service_Plan_Length_Check__c 
                                               from Service_Plan_Contract__c where id =: spc.Id];
        if(updatedSpc.Service_Plan_Reference__c != null){
            spc.Service_Plan_Reference_spc__c  = updatedSpc.Service_Plan_Reference__c;
        }
        if(updatedSpc.Service_Plan_Length_Check__c != null){
            spc.Service_Plan_Length_Check_SPC__c = updatedSpc.Service_Plan_Length_Check__c;
        }
       
        update spc;
    } 
    
    public class AssetDetail {
        @AuraEnabled public Asset asset;
        @AuraEnabled public List<Service_Plan_Contract__c> spcs;
        @AuraEnabled public Boolean hasActiveServicePlan;
        @AuraEnabled public Date startDate;
        @AuraEnabled public decimal existingServicePlanPrice;
        @AuraEnabled public decimal newServicePlanPrice;
        @AuraEnabled public String existingServicePlanId;
        @AuraEnabled public String newServicePlanId;
        @AuraEnabled public decimal upliftChargeAmount;
        @AuraEnabled public boolean showConfirmScreen;
        @AuraEnabled public boolean refund;
        @AuraEnabled public String currencyIsoCode;
    }
}