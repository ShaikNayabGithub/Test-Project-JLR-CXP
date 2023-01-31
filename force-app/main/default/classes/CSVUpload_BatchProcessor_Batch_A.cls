global abstract class CSVUpload_BatchProcessor_Batch_A implements Database.batchable<String> {
    private final Id attachmentId;
    protected final Id apexJobId;


    protected CSVUpload_BatchProcessor_Batch_A(Id attachmentId, Id apexJobId)
    {
      this.attachmentId = attachmentId;
      this.apexJobId = apexJobId;
    }


    global Iterable<String> start(Database.BatchableContext batchableContext)
    {
      Attachment attachment = [SELECT Body FROM Attachment WHERE Id =: attachmentId];
      String csvFileString = attachment.Body.toString().replaceAll('\\r\\\n', '\n');
      CSVIterator csvIterator = new CSVIterator(csvFileString, CSVParser.LF);

      String headerString = csvIterator.next();

      Apex_Job__c apexJob = new Apex_Job__c(Id = apexJobId,
        Status__c = ApexJobUtilities.PROCESSING_STATUS,
        File_Header__c = headerString
      );
      update apexJob;
      
      return csvIterator;
  }
  
  
  global abstract void execute(Database.BatchableContext info, List<String> csvRows);


    global void finish(Database.BatchableContext info) 
  {
        Apex_Job__c apexJob = new Apex_Job__c(Id = apexJobId,
            Status__c = ApexJobUtilities.PROCESSED_STATUS,
            Failure_Count__c = 0,
            Records_Deleted__c = 0,
            Records_Inserted__c = 0,
            Records_Updated__c = 0
        );

        List<Apex_Job__c> childJobs = [SELECT Failure_Count__c, Records_Deleted__c, Records_Inserted__c,Records_Updated__c 
                FROM Apex_Job__c WHERE Parent_Job__c =: apexJobId];
        for(Apex_Job__c childJob : childJobs) {
            apexJob.Failure_Count__c += childJob.Failure_Count__c;
            apexJob.Records_Deleted__c += childJob.Records_Deleted__c;
            apexJob.Records_Inserted__c += childJob.Records_Inserted__c;
            apexJob.Records_Updated__c += childJob.Records_Updated__c;
        }
        
        update apexJob;
  }
}