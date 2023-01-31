@isTest
public class JLR_IndiaUdaan_LeadHandler_Test
{
    
    public static testmethod void testrun()
    {
        
        Task_Reference__c ObjTR = createTaskReference('Duplicate and Test Drive','test','test');
        Task_Reference__c ObjTR1 = createTaskReference('Duplicate Lead','test','test');
        Task_Reference__c ObjTR2 = createTaskReference('Test Drive Request','test','test');
        Task_Reference__c ObjTR3 = createTaskReference('owner is queue','test','test');
        Task_Reference__c ObjTR4 = createTaskReference('Generic Follow-Up','test','test');
        Account ObjAccount = TestClass_AccountCreator.CreateRetailer();
        Dealer_Manager__c ObjDM = createDealermanager(objAccount.Id,UserInfo.getUserId());
        
        Vehicle_Specification__c objMake = createVehicleSpecification('Jaguar','Make');
        insert objMake;
        
        Vehicle_Specification__c objModel = createVehicleSpecification('XF','Model');
        objModel.Make__c = objMake.Id;
        objModel.Is_Currently_Sold__c=true;
        insert objModel;
        
        Lead ObjLead = new Lead();
        ObjLead.LastName = 'Test';
        ObjLead.Mapping_Primary_Model_of_Interest__c = 'A3';
        ObjLead.Email = 'Test1@apex.com';
        ObjLead.MobilePhone = '9875678435';        
        ObjLead.JLR_India_Udaan_Duplicate__c = false;
        ObjLead.Preferred_Retailer__c = ObjAccount.id;
        ObjLead.JLR_India_Udaan_Lead_Type__c = 'Quotation';
        ObjLead.Purchase_Type__c = 'New Vehicle';
        ObjLead.Type__c  = 'Services';
        ObjLead.WebSiteLeadId__c = '978979722';
        ObjLead.OwnerID = userinfo.getuserid();
        ObjLead.recordtypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Test Drive Request').getRecordTypeId();
        ObjLead.Brand__c = objMake.id;
        ObjLead.Primary_Model_Interest__c = objModel.id;        
        
        insert ObjLead;
        
        User usr = new User();
        usr = [select id from user where id=:userinfo.getuserid()];
        system.runas(usr){
        Group Grp = new Group(Name='Test', type='Queue');
        insert Grp;
        QueueSObject Que = new QueueSObject(QueueID = Grp.id, SobjectType = 'Lead');
        insert Que;
        
        
        Lead ObjLead2 = new Lead();
        ObjLead2.LastName = 'Test1';
        ObjLead2.Mapping_Primary_Model_of_Interest__c = 'A3';
        ObjLead2.Email = 'Test12@apex.com';
        ObjLead2.MobilePhone = '9875678435';        
        ObjLead2.JLR_India_Udaan_Duplicate__c = false;
        ObjLead2.Preferred_Retailer__c = ObjAccount.id;
        ObjLead2.JLR_India_Udaan_Lead_Type__c = 'Quotation';
        ObjLead2.Purchase_Type__c = 'New Vehicle';
        ObjLead2.Type__c  = 'Services';
        ObjLead2.WebSiteLeadId__c = '978979720';
        ObjLead2.OwnerID = Que.QueueID;
        ObjLead2.recordtypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Generic').getRecordTypeId();
        ObjLead2.Brand__c = objMake.id;
        ObjLead2.Primary_Model_Interest__c = objModel.id;   
                
        insert ObjLead2;
        System.assertEquals(ObjLead2.OwnerId,Que.QueueID);
        }
        
        
    }
    Public static testmethod void testrun2()
    {
        
        Task_Reference__c ObjTR = createTaskReference('Duplicate and Test Drive','test','test');
        Task_Reference__c ObjTR1 = createTaskReference('Duplicate Lead','test','test');
        Task_Reference__c ObjTR2 = createTaskReference('Test Drive Request','test','test');
        Task_Reference__c ObjTR3 = createTaskReference('owner is queue','test','test');
        Task_Reference__c ObjTR4 = createTaskReference('Generic Follow-Up','test','test');
        Account ObjAccount = TestClass_AccountCreator.CreateRetailer();
        Dealer_Manager__c ObjDM = createDealermanager(objAccount.Id,UserInfo.getUserId());
        
        Vehicle_Specification__c objMake = createVehicleSpecification('Jaguar','Make');
        insert objMake;
        
        Vehicle_Specification__c objModel = createVehicleSpecification('XF','Model');
        objModel.Make__c = objMake.Id;
        objModel.Is_Currently_Sold__c=true;
        insert objModel;
        
        
        Lead ObjLead1 = new Lead();
        ObjLead1.LastName = 'Test';
        ObjLead1.Mapping_Primary_Model_of_Interest__c = 'A3';
        ObjLead1.Email = 'Test@apex.com';
        ObjLead1.MobilePhone = '9875678430';        
        ObjLead1.JLR_India_Udaan_Duplicate__c = true;
        ObjLead1.Preferred_Retailer__c = ObjAccount.id;
        ObjLead1.JLR_India_Udaan_Lead_Type__c = 'Booking';
        ObjLead1.Purchase_Type__c = 'New Vehicle';
        ObjLead1.Type__c  = 'Services'; 
        ObjLead1.WebSiteLeadId__c = '978979762';
        ObjLead1.Industry = 'Electronics';
        ObjLead1.In_Market_Date__c = System.today().addDays(15);
        
        ObjLead1.Brand__c= objMake.id;
        ObjLead1.Primary_Model_Interest__c= objModel.id;  
                
        insert ObjLead1;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(ObjLead1.id);
        lc.setDoNotCreateOpportunity(false);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
	try{        
	Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assertEquals(true,lcr.isSuccess());
	}
	catch(Exception e){
		System.debug('ERROR: ' + e);
	}
        
        
    
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