public class FinanceUpload_Processor_F {
    public FinanceUpload_Processor Create()
    {
        CSVUpload_SObjectUpserter_F sObjectUpserterFactory = new CSVUpload_SObjectUpserter_F();
        CSVUpload_SimpleFieldSetter_F fieldSetterFactory = new CSVUpload_SimpleFieldSetter_F();

        FinanceUpload_ExistingRecordRetriever_F existingRecordRetrieverFactory = new FinanceUpload_ExistingRecordRetriever_F();
        CSVUpload_SimpleFieldSetter fieldSetter = fieldSetterFactory.Create(FinanceUpload_Constants.PROCESS_NAME);
        CSVUpload_SObjectUpserter sObjectUpserter = sObjectUpserterFactory.Create();

        FinanceUpload_SObjectBuilder_I accountBuilder = new FinanceUpload_AccountBuilder();
        FinanceUpload_SObjectBuilder_I assetBuilder = new FinanceUpload_AssetBuilder();
        FinanceUpload_SObjectBuilder_I contractBuilder = new FinanceUpload_ContractBuilder();

        FinanceUpload_SObjectCreator accountCreator = new FinanceUpload_SObjectCreator(fieldSetter, 
                accountBuilder, sObjectUpserter);
        FinanceUpload_SObjectCreator assetCreator = new FinanceUpload_SObjectCreator(fieldSetter, 
                assetBuilder, sObjectUpserter);
        FinanceUpload_SObjectCreator contractCreator = new FinanceUpload_SObjectCreator(fieldSetter, 
                contractBuilder, sObjectUpserter);

        FinanceUpload_ExistingRecordRetriever existingRecordRetriever = existingRecordRetrieverFactory.Create();
        //List is order dependent, be careful with dependencies:
        List<FinanceUpload_SObjectCreator> recordCreators = new List<FinanceUpload_SObjectCreator> { accountCreator,
                assetCreator, contractCreator };

        return new FinanceUpload_Processor(existingRecordRetriever, recordCreators);
    }
}