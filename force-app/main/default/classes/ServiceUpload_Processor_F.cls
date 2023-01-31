public class ServiceUpload_Processor_F {
    public ServiceUpload_Processor Create()
    {
        CSVUpload_SObjectUpserter_F sObjectUpserterFactory = new CSVUpload_SObjectUpserter_F();
        CSVUpload_SimpleFieldSetter_F fieldSetterFactory = new CSVUpload_SimpleFieldSetter_F();

        FinanceUpload_ExistingRecordRetriever_F existingRecordRetrieverFactory = new FinanceUpload_ExistingRecordRetriever_F();
        CSVUpload_SimpleFieldSetter fieldSetter = fieldSetterFactory.Create('Service');
        CSVUpload_SObjectUpserter sObjectUpserter = sObjectUpserterFactory.Create();

        FinanceUpload_SObjectBuilder_I accountBuilder = new FinanceUpload_AccountBuilder();
        FinanceUpload_SObjectBuilder_I assetBuilder = new FinanceUpload_AssetBuilder();
        FinanceUpload_SObjectBuilder_I eventBuilder = new ServiceUpload_EventBuilder ();
        FinanceUpload_SObjectBuilder_I serviceItemsBuilder = new ServiceUpload_EventBuilder ();

        FinanceUpload_SObjectCreator accountCreator = new FinanceUpload_SObjectCreator (fieldSetter, 
                accountBuilder, sObjectUpserter);
        FinanceUpload_SObjectCreator assetCreator = new FinanceUpload_SObjectCreator (fieldSetter, 
                assetBuilder, sObjectUpserter);
        FinanceUpload_SObjectCreator servicesCreator = new FinanceUpload_SObjectCreator (fieldSetter, 
                eventBuilder, sObjectUpserter);

        FinanceUpload_ExistingRecordRetriever existingRecordRetriever = existingRecordRetrieverFactory.Create();
        //List is order dependent, be careful with dependencies:
        List<FinanceUpload_SObjectCreator > recordCreators = new List<FinanceUpload_SObjectCreator > { accountCreator,
                assetCreator, servicesCreator};

        return new ServiceUpload_Processor(existingRecordRetriever, recordCreators);
    }
}