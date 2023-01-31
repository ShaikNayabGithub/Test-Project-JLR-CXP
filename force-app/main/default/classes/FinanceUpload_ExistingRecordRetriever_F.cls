public class FinanceUpload_ExistingRecordRetriever_F {
    public FinanceUpload_ExistingRecordRetriever Create()
    {
        FinanceUpload_AssetRetriever assetRetriever = new FinanceUpload_AssetRetriever();
        FinanceUpload_AccountRetriever accountRetriever = new FinanceUpload_AccountRetriever();
        FinanceUpload_ContactRetriever contactRetriever = new FinanceUpload_ContactRetriever();
        FinanceUpload_LeadRetriever leadRetriever = new FinanceUpload_LeadRetriever();
        FinanceUpload_ContractRetriever contractRetriever = new FinanceUpload_ContractRetriever();
        FinanceUpload_AssetMapper assetMapper = new FinanceUpload_AssetMapper();
        FinanceUpload_AccountMapper accountMapper = new FinanceUpload_AccountMapper();
        FinanceUpload_ContractMapper contractMapper = new FinanceUpload_ContractMapper();

        return new FinanceUpload_ExistingRecordRetriever(assetRetriever, accountRetriever, contactRetriever,
            leadRetriever, contractRetriever, assetMapper, accountMapper, contractMapper);
    }
}