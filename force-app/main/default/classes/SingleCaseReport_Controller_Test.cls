@isTest(seeAllData=false)
public class SingleCaseReport_Controller_Test {
	@testSetup static void setup() { 
		RecordSharer.DisableRecordSharing = true;
        Test.startTest();
        Case c = TestClass_CaseCreator.Create('Email');
        Test.stopTest();
        Asset a = TestClass_AssetBuilder.BuildVehicle(true);
        insert a;
        c.assetid = a.id;
        c.accountid = a.accountid;
        c.contactid=[select personcontactid from account where id in (select accountid from asset where id = : a.id)].personcontactid;
        update c;
        CaseComment cc = new CaseComment(ParentId=c.id,CommentBody='test',isPublished=true);
        insert cc;
        Task t = new Task(Subject='aaa',Description='bbb',WhatId=c.id);
        insert t; 
        EmailMessage em = new EmailMessage(ParentId=c.id,ToAddress='fake@email.com',subject='test',htmlBody='test',TextBody='test');
        insert em;
        /*Attachment att = new Attachment(ParentId=c.id,Name='file',Body=Blob.ValueOf('test'));
        insert att;*/
        
        ContentVersion conVer= new ContentVersion();
        conVer.Title='file';
        conVer.PathOnClient='file.csv';
        conVer.IsMajorVersion=true;
        conVer.VersionData=Blob.valueOf('test');
        insert conVer;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = c.id;
        conDocLink.ContentDocumentId = conDocId;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
    
    } 
    
    static testMethod void showReport() { 
        
        Test.startTest();

        Case c = [select id from case];
        
        PageReference reportPage = Page.SingleCaseReport;
        Test.setCurrentPage(reportPage);
        ApexPages.currentPage().getParameters().put('Id',c.Id); 
        
        SingleCaseReport_Controller report = new SingleCaseReport_Controller(new ApexPages.StandardController(c)); 
        report.getHasAttachments();
        report.getHasTasks();
        report.getHasComments();
        Test.stopTest();   
    }
}