public class RetailerQuotaTargetController {  
    public static Id DemoOrLoanRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Demonstrator_Loan_Quota').getRecordTypeId();
    public static Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
   
      public static User loggedInUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userinfo.getUserId()];
    
    @AuraEnabled
    public static Map<String, QuotaTargetWrapper> getRetailerQuotaTarget() {
        Map<String, QuotaTargetWrapper> returnWrapperMap = new Map<String,QuotaTargetWrapper>{'jaguar' => new QuotaTargetWrapper(), 'land rover' => new QuotaTargetWrapper()};
          
     try{
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());
       for(Target_Quota__c quota : [SELECT Demonstrator_Actual_Quarter__c, Demonstrator_Quota_Quarter__c, Dealer_Quota_Quarter__c, 
                                    Dealer_Actual_Quarter__c, Maximum_Stock__c, Total_Actual__c, RecordtypeId, Make__r.Name, Year__c, Model__r.Make__r.Name,
                                     Quarter_4_Demonstrator_Vehicle_Quota__c, Quarter_1_Demonstrator_Vehicle_Quota__c,Quarter_2_Demonstrator_Vehicle_Quota__c,Quarter_3_Demonstrator_Vehicle_Quota__c,
                                    Quarter_4_Dealer_Loan_Vehicle_Quota__c, Quarter_1_Dealer_Loan_Vehicle_Quota__c, Quarter_2_Dealer_Loan_Vehicle_Quota__c,Quarter_3_Dealer_Loan_Vehicle_Quota__c,
                                    Quarter_4_Demonstrator_Actual__c, Quarter_1_Demonstrator_Actual__c, Quarter_3_Demonstrator_Actual__c, Quarter_2_Demonstrator_Actual__c,
                                    Quarter_4_Dealer_Loan_Actual__c, Quarter_1_Dealer_Loan_Actual__c, Quarter_3_Dealer_Loan_Actual__c, Quarter_2_Dealer_Loan_Actual__c 
                                    FROM Target_Quota__c WHERE Retailer__c =:loggedInUser.Contact.AccountId AND
                                    ((RecordtypeId = :maximumStockRecordTypeId) OR (RecordtypeId =: DemoOrLoanRecordTypeId AND Year__c =:''+financialDetails.financailYear))
                                     AND (Make__r.Name IN ('Jaguar', 'Land Rover') OR Model__r.Make__r.Name IN ('Jaguar', 'Land Rover')) ]){
                                         system.debug(quota);
                                             if(quota.RecordtypeId == maximumStockRecordTypeId && quota.Model__c == null){
                                                returnWrapperMap.get(quota.Make__r.Name.toLowerCase()).maxStock = (Integer)quota.Maximum_Stock__c;
                                                 returnWrapperMap.get(quota.Make__r.Name.toLowerCase()).stockActual = (Integer)quota.Total_Actual__c;                                             
                                             }
                                         system.debug(quota.RecordtypeId == DemoOrLoanRecordTypeId);
                                         if(quota.RecordtypeId == DemoOrLoanRecordTypeId){
                                                    system.debug('&&&&'); 
                                                    system.debug(quota.Model__r.Make__r.Name); 
                                                    system.debug( returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase())); 
                                                    system.debug( returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).demoQuota); 
                                                    returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).demoQuota =  returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).demoQuota + Integer.valueOf(quota.Demonstrator_Quota_Quarter__c);
                                                    system.debug( returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).demoQuota);
                                                     returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).dealerLoanQuota =  returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).dealerLoanQuota + Integer.valueOf(quota.Dealer_Quota_Quarter__c);
                                                     returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).demoQuotaActual = returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).demoQuotaActual+ Integer.valueOf(quota.Demonstrator_Actual_Quarter__c);
                                                     returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).dealerLoanQuotaActual = returnWrapperMap.get(quota.Model__r.Make__r.Name.toLowerCase()).dealerLoanQuotaActual+Integer.valueOf(quota.Dealer_Actual_Quarter__c);
                                                 }     
                                         }
        }catch(exception exp){
            
        }
        
        return returnWrapperMap;
    }
      
    
    
    public class QuotaTargetWrapper{
         @AuraEnabled Public Integer demoQuota =0;
         @AuraEnabled Public Integer dealerLoanQuota =0;
         @AuraEnabled Public Integer demoQuotaActual =0;
         @AuraEnabled Public Integer dealerLoanQuotaActual =0;
         @AuraEnabled Public Integer maxStock =0;
         @AuraEnabled Public Integer stockActual =0;
    }

}