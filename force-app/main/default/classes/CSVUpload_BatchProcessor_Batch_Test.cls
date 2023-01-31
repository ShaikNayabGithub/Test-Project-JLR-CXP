@isTest
public class CSVUpload_BatchProcessor_Batch_Test{
    static testMethod void testBatch()
  {

      final Map<String, FileUpload_BatchProcessor_FI> batchProcessorFactoriesByName;
      final FileUpload_FileValidator fileValidator;
   
      FileUpload_BatchProcessorFRetriever batchProcessorFactoryRetriever = new FileUpload_BatchProcessorFRetriever();
      batchProcessorFactoriesByName = batchProcessorFactoryRetriever.RetrieveFactories();
      fileValidator = new FileUpload_FileValidator();
      
      FileUpload_BatchProcessor_FI batchProcessorFactory = batchProcessorFactoriesByName.get('Finance');
      if(batchProcessorFactory == null) return;


      Apex_Job__c apexJob = new Apex_Job__c (
      Name = 'Temp',
      Status__c = ApexJobUtilities.QUEUED_STATUS
      );
    
    insert apexJob;
    
    string tempString = 'A,B,C';
    // convert from string to blob
    Blob tempBlob = Blob.valueOf(tempString);
    
     Attachment attachment = new Attachment (
            Name = 'tesfile',
            Body =tempBlob,
            ContentType = 'text/csv',
            ParentID = apexJob.id
        );
        insert attachment;
    
    Database.Batchable<String> batchProcessor = batchProcessorFactory.Create(attachment.Id, apexJob.Id);
    Id batchJobId = Database.ExecuteBatch(batchProcessor);
    System.assertNotEquals(batchJobId ,null);  

  }

 
}