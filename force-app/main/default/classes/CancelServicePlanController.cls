public without sharing class CancelServicePlanController {
    
    @AuraEnabled
    public static list<Service_Plan_Contract__c> getAllServicePlan(string assetId)
    {
        user u=[select id, contact.AccountId from user where id=:userInfo.getUserId()];
        List<Service_Plan_Contract__c> servicePlanContractList =  [select id, Name,CurrencyIsoCode,Retail_Purchase_Price__c, Service_Plan_Product__r.Name, Assignment_Type__c from Service_Plan_Contract__c
                                                                   where 
                                                                   Auto_Added__c = FALSE 
                                                                   AND Vehicle_Id__c=:assetId 
                                                                   AND Is_Active__c = FALSE 
                                                                   AND Cancellation_Date__c=null 
                                                                   AND End_Date__c >: System.Today() 
                                                                   AND Retailer_Id__c=:u.contact.AccountId];
        if(servicePlanContractList != null && !servicePlanContractList.isEmpty()){
            return servicePlanContractList;
        }
        return null;
    }
    
    @AuraEnabled
    public static void cancelSelectedSpc(string spcId, date cancelDate)
    {
        if(cancelDate==null){
            cancelDate=system.today();
        }
        Service_Plan_Contract__c spc= new Service_Plan_Contract__c();
        spc.id=spcId;
        spc.Cancellation_Date__c=cancelDate;
        spc.Service_Plan_Contract_Status__c = 'Cancelled - Awaiting refund';
        spc.refund__c = true;
        update spc;     
    }
}