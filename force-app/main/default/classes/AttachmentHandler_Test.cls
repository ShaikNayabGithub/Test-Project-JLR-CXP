@isTest
public class AttachmentHandler_Test
{
    
    public static testmethod void testrun1()
    {
        
        List<Task_Reference__c> TReference = New List<Task_Reference__c>();
        Task_Reference__c ObjTR = createTaskReferenceForList('Duplicate and Test Drive','test','test');
        TReference.add(ObjTR);
        Task_Reference__c ObjTR1 = createTaskReferenceForList('Duplicate Lead','test','test');
        TReference.add(ObjTR1);
        Task_Reference__c ObjTR2 = createTaskReferenceForList('Test Drive Request','test','test');
        TReference.add(ObjTR2);
        Task_Reference__c ObjTR3 = createTaskReferenceForList('owner is queue','test','test');
        TReference.add(ObjTR3);
        insert TReference;
        Account ObjAccount = TestClass_AccountCreator.CreateRetailer();       
        Dealer_Manager__c ObjDM = createDealermanager(objAccount.Id,UserInfo.getUserId());
        System.debug('Inserted Dealer manager');
        Vehicle_Specification__c objMake = createVehicleSpecification('Jaguar','Make');
        insert objMake;
        System.debug('inserted make');
        Vehicle_Specification__c objModel = createVehicleSpecification('XF','Model');
        objModel.Make__c = objMake.Id;
        objModel.Is_Currently_Sold__c=true;
        
        insert objModel;
        System.debug('Inseted model');
        test.starttest();
        Lead ObjLead = TestClass_LeadCreator.CreateLead();
        ObjLead.LastName = 'Test';
        ObjLead.Mapping_Primary_Model_of_Interest__c = 'A3';
        ObjLead.Email = 'Test1@apex.com';
        ObjLead.MobilePhone = '9875678435';        
        ObjLead.JLR_India_Udaan_Duplicate__c = false;
        ObjLead.Preferred_Retailer__c = ObjAccount.id;
        ObjLead.JLR_India_Udaan_Lead_Type__c = 'Booking';
        ObjLead.Purchase_Type__c = 'New Vehicle';
        ObjLead.Type__c  = 'Services';
        ObjLead.WebSiteLeadId__c = '978979722';
        ObjLead.Brand__c = objMake.id;
        ObjLead.Primary_Model_Interest__c = objModel.id; 
        
        
        update ObjLead;
        test.stoptest();      
        Attachment attach = createAttachment(objLead.id);     
        System.assertEquals(objLead.isConverted,False);
        
    }
    
    Public static testmethod void testrun2()
    {       
        
        List<Task_Reference__c> TReference = New List<Task_Reference__c>();
        Task_Reference__c ObjTR = createTaskReferenceForList('Duplicate and Test Drive','test','test');
        TReference.add(ObjTR);
        Task_Reference__c ObjTR1 = createTaskReferenceForList('Duplicate Lead','test','test');
        TReference.add(ObjTR1);
        Task_Reference__c ObjTR2 = createTaskReferenceForList('Test Drive Request','test','test');
        TReference.add(ObjTR2);
        Task_Reference__c ObjTR3 = createTaskReferenceForList('owner is queue','test','test');
        TReference.add(ObjTR3);
        insert TReference;
        Account ObjAccount = TestClass_AccountCreator.CreatePersonAccount();
        objAccount.PersonMobilePhone = '9875678435';
        objAccount.PersonEmail = 'Test1@apex.com';
        update objAccount;
        //Dealer_Manager__c ObjDM = createDealermanager(objAccount.Id,UserInfo.getUserId());
        
        Lead ObjLead1 = TestClass_LeadCreator.CreateLead();
        ObjLead1.LastName = 'Test';
        ObjLead1.Mapping_Primary_Model_of_Interest__c = 'A3';
        ObjLead1.Email = 'Test@apex.com';
        ObjLead1.MobilePhone = '9875678430';        
        ObjLead1.JLR_India_Udaan_Duplicate__c = true;
        //ObjLead1.Preferred_Retailer__c = ObjAccount.id;
        ObjLead1.JLR_India_Udaan_Lead_Type__c = 'Booking';
        ObjLead1.Purchase_Type__c = 'New Vehicle';
        ObjLead1.Type__c  = 'Services'; 
        ObjLead1.WebSiteLeadId__c = '978979762';
        
        update ObjLead1;
        
        test.starttest();   
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(ObjLead1.id);
        lc.setDoNotCreateOpportunity(false);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        createAttachment(objLead1.id);
        System.assertEquals(lcr.isSuccess(),true);
        test.stoptest();   
        
    }
    
    public static Task_Reference__c createTaskReferenceForList(string name,string description,string subject)
    {
        Task_Reference__c ObjTR = new Task_Reference__c();
        ObjTR.Name = name;
        ObjTR.Description__c = description;
        ObjTR.Subject__c = subject;
        
        return objTR;
    }
    
    
    public static Task_Reference__c createTaskReference(string name,string description,string subject)
    {
        Task_Reference__c ObjTR = new Task_Reference__c();
        ObjTR.Name = name;
        ObjTR.Description__c = description;
        ObjTR.Subject__c = subject;
        insert ObjTR;
        return objTR;
    }
    
    public static Dealer_Manager__c createDealermanager(Id dealerId,Id managerId)
    {
        Dealer_Manager__c ObjDM = new Dealer_Manager__c();
        ObjDM.Dealer__c = dealerId;
        ObjDM.Manager__c = managerId;
        insert ObjDM;
        return ObjDM;
    }
    
    public static Attachment createAttachment(id parentId)
    {
        Attachment attach1 = new Attachment();     
        attach1.Name = 'Unit Test Attachment';
        Blob bodyBlob1 = Blob.valueOf('Unit Test Attachment Body');
        attach1.body = bodyBlob1;
        attach1.parentId = parentId;
        insert attach1;
        return attach1;
    }
    
    public static Vehicle_Specification__c createVehicleSpecification(string strName,string recordtype)
    {
        Vehicle_Specification__c objVehicleSpecification = new Vehicle_Specification__c();
        objVehicleSpecification.Name = strName;
        objVehicleSpecification.aop_JLR_Owned__c =true;
        objVehicleSpecification.recordTypeId = Schema.Sobjecttype.Vehicle_Specification__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        return objVehicleSpecification;
    }
    
}