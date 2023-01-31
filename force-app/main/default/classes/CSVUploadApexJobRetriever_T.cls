@isTest
public class CSVUploadApexJobRetriever_T {
    static testMethod void testApexJobNotNull()
  {
    CSVUpload_ApexJobRetriever csvRetriever=new CSVUpload_ApexJobRetriever();
    Apex_Job__c apexJob=new Apex_Job__c ();
    insert apexJob;

    Apex_Job__c apexJobFromDB = csvRetriever.retrieve(apexJob.id);
    System.assertNotEquals(apexJobFromDB,null);  

  }

 
}