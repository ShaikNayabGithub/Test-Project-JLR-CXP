public class FinanceContractHandler {    
    
    public void PostUpdate(List<Contract> contracts, Map<Id, Contract> oldMap) {
        SetCustomerJourneyToRenew(contracts, oldMap);
    } 

    private void SetCustomerJourneyToRenew(List<Contract> newContracts, Map<Id, Contract> oldMap) {
        //determine whether Asset listed on the Contract still belongs to the Account listed on the Contract
        List<Contract> affectedContracts = new List<Contract>();
        Set<Id> assetIds = new Set<Id>();
        for(Contract c : newContracts){
            if(oldMap != null && oldMap.containsKey(c.Id) && c.Customer_Journey_Stage_Update__c == 'Renew' && oldMap.get(c.Id).Customer_Journey_Stage_Update__c != 'Renew'){
                if(c.Asset__c != null){
                    assetIds.add(c.Asset__c);
                    affectedContracts.add(c);
                }
            }
        }
        if(assetIds.isEmpty()){
            return;
        }
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        for(Asset ass : [SELECT Id, AccountId FROM Asset WHERE Id IN :assetIds]){
            assetMap.put(ass.Id, ass);
        }
        Set<Id> accountIds = new Set<Id>();
        for(Contract c : affectedContracts){
            Id assetAccount = null;
            if(assetMap.containsKey(c.Asset__c)){
                assetAccount = assetMap.get(c.Asset__c).AccountId;
            }
            if(c.AccountId != null && c.AccountId == assetAccount){
                accountIds.add(c.AccountId);
            }
        }
        if(accountIds.isEmpty()){
            return;
        }
        List<Account> accountsToUpdate = new List<Account>();
        for(Account acc : [SELECT Id, Customer_Journey_Stage__c FROM Account WHERE Id IN :accountIds]){
            acc.Customer_Journey_Stage__c = 'Renew';
            accountsToUpdate.add(acc);
        }
        update accountsToUpdate;
    }
    

}