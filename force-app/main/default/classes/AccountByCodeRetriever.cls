public class AccountByCodeRetriever {
    public Account Retrieve(string accountCode)
    {
    	if(String.isEmpty(accountCode)){return new Account();}
        List<Account> accounts = [Select Id From Account where Secondary_Dealer_Code__c = :accountCode Limit 1];
        
        if(accounts.Size() > 0){ return accounts[0]; }
        return new Account();
    }
}