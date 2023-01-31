public class DealerDB_UpsertAccountHandler{
    private final DealerDb_AccountValidationRule_I accountValidator;
    private final RetailAccountIdResolver retailAccountIdResolver;
    
    public DealerDB_UpsertAccountHandler(DealerDb_AccountValidationRule_I accountValidator, RetailAccountIdResolver retailAccountIdResolver)
    {
        this.accountValidator = accountValidator;
        this.retailAccountIdResolver = retailAccountIdResolver;
    }


    public void UpsertAccount(DealerDBService.RetailerAccount retailerAccount)
    {
        this.accountValidator.Validate(retailerAccount);

        Account account = retailerAccount.ToSFAccount();
        this.retailAccountIdResolver.SetChildIds(account);

        try{
            Logger.Info('Upserting account:' + JSON.Serialize(account));
            upsert account;
            update new Account(Id=account.Id,IsPartner=true);
            }
        catch(Exception e){
         
             Logger.Info('Exception type name:' + e.getTypeName());
             account = retailerAccount.ToSFAccount();
             this.retailAccountIdResolver.SetChildIds(account);
             upsert account;
             update new Account(Id=account.Id,IsPartner=true);
                             
        }   
        
    }
}