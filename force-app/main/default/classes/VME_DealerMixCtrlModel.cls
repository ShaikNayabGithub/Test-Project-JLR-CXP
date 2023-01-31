public class VME_DealerMixCtrlModel {
    
    public static List<Account> getDealersList(String retailerRTId, String currentVMECountry){ //, String dealerNameSearchValue
        //dealerNameSearchValue   = '%'+dealerNameSearchValue+'%';
        DateTime dt =Datetime.now();
        Date tradingDate =dt.date();
        return [Select Id, Name, Dealer_CI_Code__c, Retailer_Status__c, Region_or_Market__c ,Stopped_Trading__c
                from Account 
                where RecordTypeId =: retailerRTId AND Country_ISO_Code__c!=null AND Country_ISO_Code__c =: currentVMECountry AND Retailer_Status__c!='Not Trading' AND Retailer_Status__c!=null  AND Retailer_Status__c!=' ' AND (Stopped_Trading__c>=:tradingDate OR Stopped_Trading__c=:null)
               AND Retailer_Type__c!=null AND (Retailer_Type__c=:'Main dealer' OR Retailer_Type__c=:'Satellite (Sales)' OR Retailer_Type__c=:'Sales Dealer') AND (Queue_ID__c=:'' OR Queue_ID__c=:null) AND Dealer_CI_Code__c!=null AND Dealer_CI_Code_2__c!=null];
    }


    public static List<Account> getDealersList(Set<String> accountIdSet){
        DateTime dt =Datetime.now();
        Date tradingDate =dt.date();
        return [Select Id, Name, Dealer_CI_Code__c, Retailer_Status__c, Region_or_Market__c ,Stopped_Trading__c
                from Account 
                where Id IN: accountIdSet AND Retailer_Status__c!='Not Trading' AND Retailer_Status__c!=null  AND Retailer_Status__c!=' '  AND (Stopped_Trading__c>=:tradingDate OR Stopped_Trading__c=:null) 
                AND Retailer_Type__c!=null AND (Retailer_Type__c=:'Main dealer' OR Retailer_Type__c=:'Satellite (Sales)' OR Retailer_Type__c=:'Sales Dealer') AND (Queue_ID__c=:'' OR Queue_ID__c=:null)  AND Dealer_CI_Code__c!=null AND Dealer_CI_Code_2__c!=null];
    }


    public static List<VME_Schemes__c> getChildSchemesRelatedToScheme(String schemeId){
        return [Select Id, VME_Parent_Scheme__c, VME_Retailer__c
                from VME_Schemes__c 
                where VME_Parent_Scheme__c =: schemeId AND VME_Retailer__c != null  AND VME_Parent_Scheme__c!=null ];
    }
}