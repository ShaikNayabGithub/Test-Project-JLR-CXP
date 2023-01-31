global with sharing class ScheduleTestJobQueuer implements schedulable {
    
    global void execute(SchedulableContext SC) {
        doExecute();
    }
    
    @future (callout=true)
    public static void doExecute(){
        //enqueueUnitTests();
        enqueueTests();
    }
    
    /*public static void createDaily4AMScheduledJob(){
        AutomatedTestJobQueuer atj = new AutomatedTestJobQueuer();  
        string sch = '0 0 4 * * ?';  
        system.schedule('Enqueue Unit Tests 4 AM',sch,atj);
    }

       Allows us to externally enqueue our unit tests. For example,
       whenever we check our code into source control, we could
       run our unit tests.
   
    webservice static void enqueueUnitTests(){      
        enqueueTests();
    }*/
    
    
    public static void enqueueTests() { 
            
       ApexClass[] testClasses = [SELECT Id, Name FROM ApexClass where (NamespacePrefix = null) and (name like '%Test' or name like '%_T') order by name asc]; 
            
       if (!testClasses.isEmpty() ) {
          /*
             Insertion of the ApexTestQueueItem causes the unit tests to be 
             executed. Since they're asynchronous, the apex async job id
             needs to be stored somewhere so we can process the test results
             when the job is complete.
          */
          ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            
          for (ApexClass testClass : testClasses) {
              system.debug('   enqueueTests::testClass ' + testClass);
                
              queueItems.add(new ApexTestQueueItem(ApexClassId=testClass.Id));
          }

          if (!Test.isRunningTest()) insert queueItems;

          // Get the job ID of the first queue item returned. 
    
          /*ApexTestQueueItem item = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id=:queueItems[0].Id LIMIT 1];
          
          String msg = 'A new test run has been scheduled in this org with job id: ' + item.ParentJobId;
          EmailUtility.SendEmail('hartnady@gmail.com','Automated Test Queuer','New Test Run #'+item.ParentJobId,msg);*/

       }
    }
}