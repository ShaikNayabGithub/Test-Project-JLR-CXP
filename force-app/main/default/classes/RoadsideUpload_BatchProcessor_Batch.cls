global class RoadsideUpload_BatchProcessor_Batch implements Database.batchable<String> {
   
    private final Id attachmentId;
    private final Id apexJobId;

    public RoadsideUpload_BatchProcessor_Batch(Id attachmentId, Id apexJobId)
    {
      this.attachmentId = attachmentId;
      this.apexJobId = apexJobId;
    }


    global Iterable<String> start(Database.BatchableContext batchableContext)
    {
      ContentVersion conVer = [SELECT VersionData FROM ContentVersion WHERE Id =: attachmentId];
      String csvFileString = conVer.VersionData.toString();
      
      csvFileString+=CSVPARSER.LF;
      
      CSVIterator csvIterator = new CSVIterator(csvFileString, CSVParser.lf);

      String headerString = csvIterator.next();
      
      System.debug('headerString: '+headerString);

      Apex_Job__c apexJob = new Apex_Job__c(Id = apexJobId,
        Status__c = ApexJobUtilities.PROCESSING_STATUS,
        File_Header__c = headerString,
        job_type__c='Roadside'
      );
      update apexJob;
      
      return csvIterator;
  }
  
  
  global void execute(Database.BatchableContext info, List<String> csvRows)
  {
        RoadsideUpload_RecordCollection recordCollection;

        try {
            RoadsideUpload_RecordCollection_FF recordCollectionFactoryFactory = new RoadsideUpload_RecordCollection_FF();
            RoadsideUpload_RecordCollection_F recordCollectionFactory = recordCollectionFactoryFactory.Create();
            recordCollection = recordCollectionFactory.Construct(apexJobId, info.getChildJobId(), csvRows);

            RoadsideUpload_Processor_F processorFactory = new RoadsideUpload_Processor_F();
            RoadsideUpload_Processor processor = processorFactory.Create();
            RoadsideUpload_ResultsLogger resultsLogger = new RoadsideUpload_ResultsLogger();
            
            processor.Process(recordCollection);

            resultsLogger.LogResults(recordCollection);
        }
        catch (Exception e) {
            recordCollection.ApexJob.Status__c = ApexJobUtilities.FAILED_STATUS;
            recordCollection.ApexJob.Results_Log__c = String.valueOf(DateTime.now()) + ' ' + e.getMessage() + 
                    '\n' + e.getStackTraceString();
            upsert recordCollection.ApexJob;
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
            accounts_inserted__c=0,
            contracts_inserted__c=0,
            assets_inserted__c=0,
            events_inserted__c=0
        );

        List<Apex_Job__c> childJobs = [SELECT Failure_Count__c, Records_Deleted__c, Records_Inserted__c,Records_Updated__c,accounts_inserted__c,contracts_inserted__c,assets_inserted__c,events_inserted__c
                FROM Apex_Job__c WHERE Parent_Job__c =: apexJobId];
                
        System.debug('childJobs: '+childJobs);
        
                
        for(Apex_Job__c childJob : childJobs) {
            apexJob.Failure_Count__c += childJob.Failure_Count__c;
            apexJob.Records_Deleted__c += childJob.Records_Deleted__c;
            apexJob.Records_Inserted__c += childJob.Records_Inserted__c;
            apexJob.Records_Updated__c += childJob.Records_Updated__c;
            apexJob.accounts_inserted__c=childJob.accounts_inserted__c;
            apexJob.contracts_inserted__c=childJob.contracts_inserted__c;
            apexJob.assets_inserted__c=childJob.assets_inserted__c;
            apexJob.events_inserted__c=childJob.events_inserted__c;
        }
        
        System.debug('apexJob after popullated: '+apexJob);
        
        update apexJob;
  }
}