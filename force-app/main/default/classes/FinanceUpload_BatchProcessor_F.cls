public class FinanceUpload_BatchProcessor_F implements FileUpload_BatchProcessor_FI {
    public String GetLabel() {
        return FinanceUpload_Constants.PROCESS_NAME;
    }

    public String GetName() {
        return FinanceUpload_Constants.PROCESS_NAME;
    }

    public Set<String> GetSupportedFileFormats() {
        return new Set<String> { 'csv' };
    }

    public Document GetTemplate() {
        List<Document> tempateList = [SELECT Id FROM Document WHERE DeveloperName = 'Finance_Template'];
        if(tempateList.Size() == 0) return null;
        else return tempateList[0];
    }


    public Database.Batchable<String> Create(Id attachmentId, Id apexJobId) {
        FinanceUpload_Processor_F processorFactory = new FinanceUpload_Processor_F();
        CSVUpload_DataCollection_FF dataCollectionFactoryFactory = new CSVUpload_DataCollection_FF();
        CSVUpload_RowValidator_F validatorFactory = new CSVUpload_RowValidator_F();

        CSVUpload_Processor_I processor = processorFactory.Create();
        CSVUpload_DataCollection_F dataCollectionFactory = dataCollectionFactoryFactory.Create();
        CSVUpload_RowValidator validator = validatorFactory.Create(FinanceUpload_Constants.PROCESS_NAME);

        return new CSVUpload_BatchProcessor_Batch(processor, dataCollectionFactory, validator, attachmentId, 
                apexJobId);
    }
}