public class RetailAccountIdResolver{
    public void SetChildIds(Account childAccount)
    {
        Account extAccount = RetrieveAccount(childAccount.Primary_Dealer_Code__c,childAccount.Retailer_Type__c);
        if(extAccount != null && extAccount.Id != null){
            childAccount.Id = extAccount.Id;
            childAccount.Retailer_Type__c = extAccount.Retailer_Type__c;
        }
        if(childAccount.Id != null){ return; } 
        
        //childAccount.ParentId = RetrieveAccountId(childAccount.Secondary_Dealer_Code__c.right(7));//parent no longer maintained
    }
    
    
    private Account RetrieveAccount(string primaryDealerCode,String retailerType)
    {
        Logger.info(' Looking for dealer code:' + primaryDealerCode);
        Logger.info(' Looking for Retailer Type:' + retailerType);
        system.debug('primaryDealerCode --> '+primaryDealerCode);
        system.debug('retailerType1 --> '+retailerType);
        if(retailerType != null && retailerType.equalsIgnoreCase('Sales Dealer')){
            retailerType = 'Main Dealer';
        }
        system.debug('retailerTyp2 --> '+retailerType);
        
        List<Account> existingAccounts = [Select Id,Retailer_Type__c From Account Where 
                                          Primary_Dealer_Code__c=:primaryDealerCode 
                                          and Retailer_Type__c =: retailerType];
        if(existingAccounts.size() != 0){
            Logger.info(' Found dealer code: ' + primaryDealerCode + ' AccountId:' + existingAccounts[0].id);
            return existingAccounts[0];
        }else if(retailerType != null && retailerType.equalsIgnoreCase('After Sales Dealer')){
            List<Account> existingMainDealerList = [Select Id,Retailer_Type__c From Account Where 
                                                    Primary_Dealer_Code__c=:primaryDealerCode 
                                                    and Retailer_Type__c = 'Main Dealer'];
            if(existingMainDealerList.size() != 0){
                Logger.info(' After Sales Dealer matching with a Main Dealer on the Primary Dealer Code:' + primaryDealerCode + ' AccountId:' + existingMainDealerList[0].id);
                return existingMainDealerList[0];
            }
        } 
        Logger.info(' Did not find dealer code:' + primaryDealerCode);
        return null;
    }
}