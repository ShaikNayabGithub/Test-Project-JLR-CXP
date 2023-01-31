@isTest
public class FinanceUpload_Processor_T {
    static testMethod void testFinanceUpload_Processor()
    {
        
        
        Apex_Job__c apexJob = new Apex_Job__c();
        
        FinanceUpload_Processor_F processorFactory = new FinanceUpload_Processor_F();
        CSVUpload_DataCollection_FF dataCollectionFactoryFactory = new CSVUpload_DataCollection_FF();
        CSVUpload_RowValidator_F validatorFactory = new CSVUpload_RowValidator_F();
        
        CSVUpload_Processor_I processor = processorFactory.Create();
        CSVUpload_DataCollection_F dataCollectionFactory = dataCollectionFactoryFactory.Create();
        CSVUpload_RowValidator validator = validatorFactory.Create(FinanceUpload_Constants.PROCESS_NAME);
        List<Account> accountList = new List<Account>();
        accountList.add(TestUtility.createIndividualAccount());
        accountList.add(TestUtility.createIndividualAccount());
        insert accountList;
        
        List<Account> accountRetreiveList = [SELECT recordtypeid,LegalEntityID__c,corporate__c,PersonEmail, Email2__pc, Email3__pc,Retailer_Email__c , PersonHomePhone, PersonMobilePhone,
                                     PersonOtherPhone, Phone,PersonAssistantPhone,owner.accountid  FROM Account];
        FinanceUpload_AccountRetriever accountRet = new FinanceUpload_AccountRetriever();
        accountRet.findDuplicates(accountRetreiveList);
        System.assertNotEquals(validator,null);
    }
    
    
}