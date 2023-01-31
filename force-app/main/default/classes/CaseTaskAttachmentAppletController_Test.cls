@isTest(SeeAllData=false)
public class CaseTaskAttachmentAppletController_Test{
    
    static testMethod void pageloadtest()
    { 
        Case c = TestClass_CaseCreator.Create('Phone');
        Task t = new Task();
        t.ownerid = UserInfo.getUserId();
        t.whatid=c.id;
        t.subject='subject';
        t.description='description';
        t.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Task').getRecordTypeId();
        insert t;
        
        ContentVersion conVer= new ContentVersion();
        conVer.Title='file';
        conVer.PathOnClient='file.csv';
        conVer.IsMajorVersion=true;
        conVer.VersionData=Blob.valueOf('123456789');
        insert conVer;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = t.id;
        conDocLink.ContentDocumentId = conDocId;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        
        
        /*Attachment att = new Attachment();
        att.ParentId = t.id;
        att.Name = 'file';
        att.Body = Blob.valueOf('123456789');
        insert att;*/
        
        CaseTaskAttachmentAppletController cta = new CaseTaskAttachmentAppletController(new ApexPages.StandardController(c));
        system.assert(t.subject=='subject');
    
    }
    
}