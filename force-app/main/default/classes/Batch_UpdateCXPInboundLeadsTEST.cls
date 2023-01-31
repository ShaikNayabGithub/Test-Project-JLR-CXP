@isTest
Public class Batch_UpdateCXPInboundLeadsTEST{
    @testSetup
    Public static void createData(){
        
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'Generic' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(DMS_ID__c  = '998812', Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        
        MENA_CDK_Lead__c crtLead = new MENA_CDK_Lead__c( External_Oem_Reference_ID__c = webToLead.id,
        Lead_Hub_ID__c = 'e735ec09-62f9-48d5-b9d8-4bbf2e08b767',First_Name__c = 'Test',
        Enquiry_Type__c = 'GENERAL_SALES_INQUIRY',Surname__c = 'Test',Lost_Lead_Comments__c = '',
        Mobile__c = '',Phone__c = '2323232323',Email__c = 'ayman@sdfdsfsdfsdfds.com',Edited_On__c = '17/06/2021',
        Task_Action_Owner__c = 'Ahmad Abu Hawili',Status__c = 'Converted',
        LeadUpdateStatus__c = '', FailReason__c = '' );
        
        insert crtLead;
        
        MENA_CDK_Lead__c crtLead1 = new MENA_CDK_Lead__c(
        Lead_Hub_ID__c = 'e735ec09-62f9-48d5-b9d8-4bbf2e08b767',First_Name__c = 'Test',
        Enquiry_Type__c = 'GENERAL_SALES_INQUIRY',Surname__c = 'Test',Lost_Lead_Comments__c = '',
        Mobile__c = '',Phone__c = '2323232323',Email__c = 'ayman@sdfdsfsdfsdfds.com',Edited_On__c = '17/06/2021',
        Task_Action_Owner__c = 'Ahmad Abu Hawili',Status__c = 'Converted',
        LeadUpdateStatus__c = '', FailReason__c = '' );
        
        insert crtLead1;
    }
    
    @isTest
    Public static void Batch_UpdateCXPInboundLeads(){
        List<MENA_CDK_Lead__c> cdkLeadList = [SELECT id,External_Oem_Reference_ID__c,Lead_Hub_ID__c,First_Name__c,
                         Enquiry_Type__c,Surname__c,Lost_Lead_Comments__c,Mobile__c,Phone__c,
                         Email__c,Edited_On__c,Task_Action_Owner__c,Status__c,LeadUpdateStatus__c, 
                         FailReason__c 
                    FROM MENA_CDK_Lead__c where External_Oem_Reference_ID__c != null];
        Database.executeBatch( new Batch_UpdateCXPInboundLeads( ) );                              
    }
    
    @isTest
    Public static void Batch_UpdateCXPInboundLeads1(){
        List<MENA_CDK_Lead__c> cdkLeadList = [SELECT id,External_Oem_Reference_ID__c,Lead_Hub_ID__c,First_Name__c,
                         Enquiry_Type__c,Surname__c,Lost_Lead_Comments__c,Mobile__c,Phone__c,
                         Email__c,Edited_On__c,Task_Action_Owner__c,Status__c,LeadUpdateStatus__c, 
                         FailReason__c 
                    FROM MENA_CDK_Lead__c where External_Oem_Reference_ID__c = null];
        Database.executeBatch( new Batch_UpdateCXPInboundLeads() );                              
    }
}