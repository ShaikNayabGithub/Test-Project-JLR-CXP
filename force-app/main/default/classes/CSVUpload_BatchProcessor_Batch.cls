global class CSVUpload_BatchProcessor_Batch implements Database.batchable<String> {
    private final CSVUpload_ResultsLogger resultsLogger = new CSVUpload_ResultsLogger();

    private final CSVUpload_Processor_I processor;
    private final CSVUpload_DataCollection_F dataCollectionFactory;
    private final CSVUpload_RowValidator validator;

    private final Id attachmentId;
    private final Id apexJobId;


    public CSVUpload_BatchProcessor_Batch(CSVUpload_Processor_I processor, 
            CSVUpload_DataCollection_F dataCollectionFactory, CSVUpload_RowValidator validator,
            Id attachmentId, Id apexJobId)
    {
        this.processor = processor;
        this.dataCollectionFactory = dataCollectionFactory;
        this.validator = validator;
        this.attachmentId = attachmentId;
        this.apexJobId = apexJobId;
        
        System.debug('processor: '+processor);
        
    }


    global Iterable<String> start(Database.BatchableContext batchableContext)
    {
        ContentVersion conVer = [SELECT VersionData FROM ContentVersion WHERE Id =: attachmentId];
      
        String uploadType;
        
       // String csvFileString = attachment.Body.toString().replaceAll('\\r\\\n', '\n');
       //String csvFileString = attachment.Body.toString().replaceAll('\\r\\\n', '\n').replaceAll('-','/');
   
   
        String csvFileString = conVer.VersionData.toString();
        CSVIterator csvIterator = new CSVIterator(csvFileString, CSVParser.LF);
        
        if(processor instanceof FinanceUpload_Processor)
            uploadType='Finance';
            else
        if(processor instanceof ServiceUpload_Processor)
            uploadType='Service';
           
        
            String headerString = csvIterator.next();
     
            Apex_Job__c apexJob = new Apex_Job__c(Id = apexJobId,
            Status__c = ApexJobUtilities.PROCESSING_STATUS,
            File_Header__c = headerString,
            job_type__c=uploadType
        );
        update apexJob;
        
        return csvIterator;
    }
    

    global void execute(Database.BatchableContext info, List<String> csvRows)
    {
        CSVUpload_DataCollection dataCollection;

        try {
            dataCollection = this.dataCollectionFactory.Construct(this.apexJobId, info.getChildJobId(), csvRows);

            this.validator.Validate(dataCollection);
            this.processor.Process(dataCollection);
            this.resultsLogger.LogResults(dataCollection);
        }
        catch (Exception e) {
            dataCollection.ApexJob.Status__c = ApexJobUtilities.FAILED_STATUS;
            dataCollection.ApexJob.Results_Log__c = String.valueOf(DateTime.now()) + ' ' + e.getMessage() + 
                    '\n' + e.getStackTraceString();
            upsert dataCollection.ApexJob;
        }
    }


    global void finish(Database.BatchableContext info) 
    {
        Apex_Job__c apexJob = new Apex_Job__c(Id = apexJobId,
            Status__c = ApexJobUtilities.PROCESSED_STATUS,
            Failure_Count__c = 0,
            Records_Deleted__c = 0,
            Records_Inserted__c = 0,
            Records_Updated__c = 0,
            Accounts_inserted__c=0,
            contracts_inserted__c=0,
            Assets_Inserted__c=0
        );

        List<Apex_Job__c> childJobs = [SELECT Failure_Count__c, Records_Deleted__c, Records_Inserted__c,Records_Updated__c,accounts_inserted__c,contracts_inserted__c,assets_inserted__c 
                FROM Apex_Job__c WHERE Parent_Job__c =: apexJobId];
        for(Apex_Job__c childJob : childJobs) {
            apexJob.Failure_Count__c += childJob.Failure_Count__c;
            apexJob.Records_Deleted__c += childJob.Records_Deleted__c;
            apexJob.Records_Inserted__c += childJob.Records_Inserted__c;
            apexJob.Records_Updated__c += childJob.Records_Updated__c;
            apexJob.accounts_inserted__C+=childJob.accounts_inserted__c;
            apexJob.contracts_inserted__c+=childJob.contracts_inserted__c;
            apexJob.assets_inserted__c+=childJob.assets_inserted__c;
        }
        
        update apexJob;
    }
}