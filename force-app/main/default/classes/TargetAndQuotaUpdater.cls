public class TargetAndQuotaUpdater {
    public static Id DemoOrLoanRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Demonstrator_Loan_Quota').getRecordTypeId();
    public static Id salestargetRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Sales_Target').getRecordTypeId();
    public static Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
    public static Id dealerOwnedRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Dealer_Owned').getRecordTypeId();
    public static Id OUVRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('OUV').getRecordTypeId();
    public static Id newRetailRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    public static Id onSellRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    public static User loggedInUser = [SELECT Id, Contact.AccountId, profile.Name FROM User WHERE Id = :userinfo.getUserId() AND ContactId != null];
    
    public static void calculateTargetAndQuota(List<RDA__c> updatedRDAList, Map<Id,Asset> assetMap){
        Set<String> brandIdList = new Set<String>();
        Set<String> modelNameList = new Set<String>();
       Set<Id> assetIdForOnsell = new Set<Id>();
   Map<String,Rda__c> assetToExistingRDAMap = new Map<String,Rda__c>();        
        Map<String,Target_Quota__c> targetQuotaMap = new Map<String,Target_Quota__c>();
        String currentMonthName; // for now just one = DateTime.now().format('MMMMM');
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());
        for(RDA__c updatedRDA : updatedRDAList){
            if(updatedRDA.RecordTypeId == onSellRecordTypeId ){
                assetIdForOnsell.add(updatedRDA.Asset__c);
            }
            
            
            if(assetMap.get(updatedRDA.Asset__c) !=null) {
                brandIdList.add(assetMap.get(updatedRDA.Asset__c).Brand__c);
                modelNameList.add(assetMap.get(updatedRDA.Asset__c).Derivative__r.Model_Alternative__c);
              
            }
            if(updatedRDA.Handover_Date__c != null){
                currentMonthName=   ((DateTime)updatedRDA.Handover_Date__c).format('MMMMM');  
            }else{
                currentMonthName=  DateTime.now().format('MMMMM');   
            } 
            
        }
        
        if(assetIdForOnsell != null && assetIdForOnsell.size() > 0 ){
           // Map<Id, RDA__c> onDealerOwnedRdas = new Map<Id, RDA__c>([SELECT Id,Handover_Date__c, Common_Sale_Type__c, RecordTypeId FROM Rda__c WHERE ID in :assetIdForOnsell AND RecordtypeId = :dealerOwnedRecordTypeId ]);
                List<RDA__c> onDealerOwnedRdas = [SELECT Id,Handover_Date__c,Asset__c, Common_Sale_Type__c, RecordTypeId FROM Rda__c WHERE Asset__c in :assetIdForOnsell AND RecordtypeId = :dealerOwnedRecordTypeId  and Common_Sale_Type__c != null ];
            if(onDealerOwnedRdas !=  null && onDealerOwnedRdas.size() > 0){
                for(RDA__c dealerownedrda : onDealerOwnedRdas){
                  if(!assetToExistingRDAMap.ContainsKey(dealerownedrda.Asset__c) ){
                    assetToExistingRDAMap.put(dealerownedrda.Asset__c, dealerownedrda);
                }else{
                    RDA__c oneinthere = assetToExistingRDAMap.get(dealerownedrda.Asset__c);
                    if(dealerownedrda.Handover_Date__c > oneinthere.Handover_Date__c){
                        assetToExistingRDAMap.remove(oneinthere.Asset__c);
                         assetToExistingRDAMap.put(dealerownedrda.Asset__c, dealerownedrda);
                        
                    }
                }  
                }
                
            }
          
                
            }
        system.debug('assetToExistingRDAMap '+assetToExistingRDAMap);
                
        
        //:loggedInUser.Contact.AccountId
        List<Target_Quota__c> quotaList =[SELECT Id, Name, RecordTypeId, April_Actual__c, April_Remaining__c, April_Target__c, August_Actual__c, August_Remaining__c,
                                          August_Target__c, Dealer_Loan_Actual__c, Target_Month_Target__c, Dealer_Loan_Remaining__c, Dealer_Loan_Vehicle_Quota__c, 
                                          December_Actual__c, December_Remaining__c, December_Target__c, Demonstrator_Actual__c, Target_Month_Actual__c, Demonstrator_Remaining__c, 
                                          Demonstrator_Vehicle_Quota__c, FY__c, February_Actual__c, February_Remaining__c, February_Target__c, January_Actual__c, January_Remaining__c,
                                          January_Target__c, July_Actual__c, July_Remaining__c, July_Target__c, June_Actual__c, June_Remaining__c, June_Target__c, Make__c, 
                                          March_Actual__c, March_Remaining__c, March_Target__c, Target_Month_Remaining__c, Maximum_Stock__c, May_Actual__c, May_Remaining__c,
                                          May_Target__c, Model__c, November_Actual__c, November_Remaining__c, November_Target__c, October_Actual__c, October_Remaining__c, 
                                          October_Target__c, Quarter_1_Actual__c, Quarter_1_Remaining__c, Quarter_1_Target__c, Quarter_2_Actual__c, Quarter_2_Remaining__c, 
                                          Quarter_2_Target__c, Quarter_3_Actual__c, Quarter_3_Remaining__c, Quarter_3_Target__c, Quarter_4_Actual__c, Quarter_4_Remaining__c, 
                                          Quarter_4_Target__c, Target_Quarter_Target__c, Target_Quarter_Actual__c, Remaining_Allowance__c, Retailer__c, September_Actual__c, 
                                          September_Remaining__c, September_Target__c, Total_First_RDA_s_for_Demo_Loan_Vehicle__c, Total_Second_RDA_s_for_Demo_Loan_Vehicle__c,
                                          Year__c, Year_to_Date_Actual__c, Year_to_Date_Remaining__c, Year_to_Date_Target__c, Quarter_1_Demonstrator_Vehicle_Quota__c,
                                          Quarter_2_Demonstrator_Vehicle_Quota__c, Quarter_3_Demonstrator_Vehicle_Quota__c, Quarter_4_Demonstrator_Vehicle_Quota__c, 
                                          Quarter_1_Demonstrator_Actual__c, Quarter_2_Demonstrator_Actual__c, Quarter_3_Demonstrator_Actual__c, Quarter_4_Demonstrator_Actual__c,
                                          Quarter_1_Dealer_Loan_Vehicle_Quota__c, Quarter_2_Dealer_Loan_Vehicle_Quota__c, Quarter_3_Dealer_Loan_Vehicle_Quota__c, 
                                          Quarter_4_Dealer_Loan_Vehicle_Quota__c, Quarter_1_Dealer_Loan_Actual__c, Quarter_2_Dealer_Loan_Actual__c, Quarter_3_Dealer_Loan_Actual__c,
                                          Quarter_4_Dealer_Loan_Actual__c, Quarter_1_Demonstrator_Remaining__c, Quarter_2_Demonstrator_Remaining__c, 
                                          Quarter_3_Demonstrator_Remaining__c, Quarter_4_Demonstrator_Remaining__c, Quarter_1_Dealer_Loan_Remaining__c,
                                          Quarter_2_Dealer_Loan_Remaining__c, Quarter_3_Dealer_Loan_Remaining__c, Quarter_4_Dealer_Loan_Remaining__c, Total_In_Stock__c,
                                          Total_Actual__c, Demonstrator_In_Stock__c, Dealer_Loan_In_Stock__c, Target_Quarter_Remaining__c, Model__r.Name
                                          FROM Target_Quota__c WHERE Retailer__c =:loggedInUser.Contact.AccountId  AND (Make__c IN :brandIdList OR Model__r.Name IN :modelNameList)
                                          AND (RecordtypeId = :maximumStockRecordTypeId OR  Year__c = :''+financialDetails.financailYear)]; 
        System.debug('quotaList '+quotaList);
        for(Target_Quota__c quota: quotaList ){
            if(quota.RecordtypeId == maximumStockRecordTypeId){
               
                if(quota.Model__c != null){
                    targetQuotaMap.put('maximumstock-'+quota.Model__r.Name.toLowerCase(), quota);
              
                     System.debug('GONE TO Model '+quota);
                }else{
                   targetQuotaMap.put('maximumstock-'+quota.Make__c, quota);  
                }
            }else if(quota.RecordtypeId == DemoOrLoanRecordTypeId && quota.Year__c == ''+financialDetails.financailYear){
                targetQuotaMap.put('Quota-'+quota.Model__r.Name.toLowerCase(), quota);                
            }else if(quota.RecordtypeId == salestargetRecordTypeId && quota.Year__c == ''+financialDetails.financailYear){
                targetQuotaMap.put('Target-'+quota.Model__r.Name.toLowerCase(), quota);                 
            }
        }
        system.debug('targetQuotaMap  '+json.serializePretty(targetQuotaMap));
        if(targetQuotaMap.values().size() >0){
            for(RDA__c updatedRDA : updatedRDAList){
                if(assetMap.get(updatedRDA.Asset__c) !=null && assetMap.get(updatedRDA.Asset__c).Derivative__c != null && 
                   assetMap.get(updatedRDA.Asset__c).Derivative__r.Model_Alternative__c.toLowerCase() != null) {
                        Asset currentAsset = assetMap.get(updatedRDA.Asset__c);
                       String typeOfSale;
                       if(updatedRDA.Common_Sale_Type__c != null){typeOfSale = RDAController.getVehicleTypeSetter(updatedRDA.Common_Sale_Type__c);}else{typeOfSale = RDAController.getVehicleTypeSetter(currentAsset.Common_Sale_Type__c);}
                     
                     //  String typeOfSale = RDAController.getVehicleTypeSetter(currentAsset.Common_Sale_Type__c);
                       if(updatedRDA.RecordtypeId == newRetailRecordTypeId){
                           String targetMapKey = 'Target-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                           string targetFieldName = currentMonthName+'_Actual__c';
                           if(targetQuotaMap.containsKey(targetMapKey)){
                               targetQuotaMap.get(targetMapKey).put(targetFieldName, calculation(updatedRDA,targetQuotaMap,targetMapKey,targetFieldName)); 
                           }
                       }else if(updatedRDA.RecordtypeId == dealerOwnedRecordTypeId){
                           system.debug('Dealer Owned Recordtype');
                           String targetMapKey = 'Target-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                           string targetFieldName = currentMonthName+'_Actual__c';
                           if(targetQuotaMap.containsKey(targetMapKey)){
                               targetQuotaMap.get(targetMapKey).put(targetFieldName, calculation(updatedRDA,targetQuotaMap,targetMapKey,targetFieldName));  
                           }
                           if(typeOfSale.equalsIgnoreCase('Demonstrator')){
                               system.debug('In demonstrator');
                               String quotaMapKey = 'Quota-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                               string quotaFieldName = 'Quarter_'+financialDetails.Quarter+'_Demonstrator_Actual__c';
                               String maxMapKey = 'maximumstock-'+currentAsset.Brand__c;
                               String maxMapModelKey = 'maximumstock-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                               system.debug('maxMapModelKey '+ maxMapModelKey);
                               string maxFieldName = 'Demonstrator_Actual__c';  
                               if(targetQuotaMap.containsKey(quotaMapKey)){
                                   targetQuotaMap.get(quotaMapKey).put(quotaFieldName, calculation(updatedRDA,targetQuotaMap,quotaMapKey,quotaFieldName));
                               }
                               if(targetQuotaMap.containsKey(maxMapKey)){
                                   targetQuotaMap.get(maxMapKey).put(maxFieldName, calculation(updatedRDA,targetQuotaMap,maxMapKey,maxFieldName));   
                               }
                               if(targetQuotaMap.containsKey(maxMapModelKey)){
                                    system.debug('found key model ');
                                   targetQuotaMap.get(maxMapModelKey).put(maxFieldName,calculation(updatedRDA,targetQuotaMap,maxMapModelKey,maxFieldName));
                               }
                           }else if(typeOfSale.equalsIgnoreCase('Dealer Loan')){    
                               String quotaMapKey = 'Quota-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                               string quotaFieldName = 'Quarter_'+financialDetails.Quarter+'_Dealer_Loan_Actual__c';
                               String maxMapKey = 'maximumstock-'+currentAsset.Brand__c;
                               String maxMapModelKey = 'maximumstock-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                               string maxFieldName = 'Dealer_Loan_Actual__c';    
                               if(targetQuotaMap.containsKey(quotaMapKey)){
                                   targetQuotaMap.get(quotaMapKey).put(quotaFieldName, calculation(updatedRDA,targetQuotaMap,quotaMapKey,quotaFieldName));
                               }
                               if(targetQuotaMap.containsKey(maxMapKey)){
                                   targetQuotaMap.get(maxMapKey).put(maxFieldName, calculation(updatedRDA,targetQuotaMap,maxMapKey,maxFieldName));                        
                               }
                               if(targetQuotaMap.containsKey(maxMapModelKey)){
                                   targetQuotaMap.get(maxMapModelKey).put(maxFieldName,calculation(updatedRDA,targetQuotaMap,maxMapModelKey,maxFieldName));
                               }
                           }
                       }else if(updatedRDA.RecordtypeId == onSellRecordTypeId && assetToExistingRDAMap.ContainsKey(updatedRDA.Asset__c)){
                           //check exisiting Dealerowned 
                           System.debug('HERE IN ONSELL');
                           
                           RDA__c existingDealerOwned = assetToExistingRDAMap.get(updatedRDA.Asset__c);
                      string     typeOfSaleFound = RDAController.getVehicleTypeSetter(existingDealerOwned.Common_Sale_Type__c);
                             System.debug('existingDealerOwned '+existingDealerOwned);
                              System.debug('typeOfSaleFound '+typeOfSaleFound);
                           if(typeOfSaleFound.equalsIgnoreCase('Demonstrator')){                        
                               String maxMapKey = 'maximumstock-'+currentAsset.Brand__c;
                               String maxMapModelKey = 'maximumstock-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                               string maxFieldName = 'Demonstrator_Actual__c';
                               if(targetQuotaMap.containsKey(maxMapKey)){
                                   targetQuotaMap.get(maxMapKey).put(maxFieldName,calculation(updatedRDA,targetQuotaMap,maxMapKey,maxFieldName));
                               }
                               if(targetQuotaMap.containsKey(maxMapModelKey)){
                                   system.debug('maxMapModelKey yuhp '+maxMapModelKey);
                                   targetQuotaMap.get(maxMapModelKey).put(maxFieldName,calculation(updatedRDA,targetQuotaMap,maxMapModelKey,maxFieldName));
                               }
                           }else if(typeOfSaleFound.equalsIgnoreCase('Dealer Loan')){                        
                               String maxMapKey = 'maximumstock-'+currentAsset.Brand__c;
                               String maxMapModelKey = 'maximumstock-'+currentAsset.Derivative__r.Model_Alternative__c.toLowerCase();
                               string maxFieldName = 'Dealer_Loan_Actual__c';       
                               if(targetQuotaMap.containsKey(maxMapKey)){
                                   targetQuotaMap.get(maxMapKey).put(maxFieldName,calculation(updatedRDA,targetQuotaMap,maxMapKey,maxFieldName));
                               }
                               if(targetQuotaMap.containsKey(maxMapModelKey)){
                                   targetQuotaMap.get(maxMapModelKey).put(maxFieldName,calculation(updatedRDA,targetQuotaMap,maxMapModelKey,maxFieldName));
                               }
                               
                           }    
                       }
                   }
            }
               system.debug('targetQuotaMap.values() '+ targetQuotaMap.values());
            if(targetQuotaMap.values().size() > 0) update targetQuotaMap.values();
        }
    }
    
    public static Integer calculation(RDA__c updatedRDA, Map<String,Target_Quota__c> targetQuotaMap , String mapKey, String fieldName){ 
        system.debug('Calculation');
        system.debug('updatedRDA '+updatedRDA);
          system.debug('targetQuotaMap '+targetQuotaMap);
         system.debug('Orig mapKey '+mapKey);
           system.debug('Orig fieldName '+fieldName);
        system.debug('updatedRDA,status '+updatedRDA.Submitted_Status__c);
        Integer currentValue = Integer.valueof(targetQuotaMap.get(mapKey).get(fieldName));
        currentValue = currentValue == null ? 0 :currentValue;
        system.debug('Orig Value '+currentValue);
        if(updatedRDA.RecordtypeId == onSellRecordTypeId){
            if(updatedRDA.Submitted_Status__c == 'Submitted'){
                currentValue = currentValue - 1;
            }
            if(updatedRDA.Submitted_Status__c != 'Completed' && updatedRDA.Submitted_Status__c != 'Submitted'){
                currentValue = currentValue + 1;
            }
        } 
        else{
            
            if(updatedRDA.Submitted_Status__c == 'Submitted'){
                currentValue = currentValue + 1;
            }
            if(updatedRDA.Submitted_Status__c != 'Completed' && updatedRDA.Submitted_Status__c != 'Submitted'){
                currentValue = currentValue - 1;
            }
            
            
            //  currentValue = updatedRDA.Submitted_Status__c == 'Submitted' ? currentValue+1 : currentValue-1;
        } 
        system.debug('currentValue '+currentValue);
        return currentValue;
    }
}