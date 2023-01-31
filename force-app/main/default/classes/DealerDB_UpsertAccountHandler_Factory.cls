public class DealerDB_UpsertAccountHandler_Factory{
    public static DealerDB_UpsertAccountHandler Create()
    {
        List<DealerDb_AccountValidationRule_I> accountValidators = new List<DealerDb_AccountValidationRule_I>();
        DealerDb_AccountValidationRule_I mandatoryRule = new DealerDb_AccountMandatoryFieldsRule();
        accountValidators.add(mandatoryRule);
        DealerDb_AccountValidator accountValidator = new DealerDb_AccountValidator(accountValidators);//refactor

        RetailAccountIdResolver retailAccountIdResolver = new RetailAccountIdResolver();

        return new DealerDB_UpsertAccountHandler(accountValidator, retailAccountIdResolver);
    }
}