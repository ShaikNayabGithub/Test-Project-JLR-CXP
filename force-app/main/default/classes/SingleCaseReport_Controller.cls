public with sharing class SingleCaseReport_Controller {
    public Case cse {get; set;}
    public List<Task> caseTasks {get; set;}
    public List<CaseComment> caseComments {get; set;}
    public List<ContentVersion> caseAttachments {get; set;}
    
    public SingleCaseReport_Controller(ApexPages.StandardController ctrl){
    	cse = (Case)ctrl.getRecord();
    	String taskQuery = 'SELECT Id';
    	for(Schema.FieldSetMember f : SObjectType.Task.FieldSets.Case_Single_Report.getFields()){
    		taskQuery += ', ' + f.FieldPath;
    	}
    	taskQuery += ' FROM Task WHERE WhatId = \'' + cse.Id + '\'';
    	caseTasks = Database.query(taskQuery);
    	caseComments = [SELECT CommentBody, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM CaseComment WHERE ParentId = :cse.Id AND IsDeleted = false];
    	
        Set<Id> contentDocIdSet = New Set<Id>();
        for(ContentDocumentLink cdLink:[select id, LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:cse.id ])
        {
          contentDocIdSet.add(cdLink.ContentDocumentId);  
        }
        
        caseAttachments = [Select Id, Title, CreatedById, CreatedDate from ContentVersion where IsLatest=True AND ContentDocumentId IN:contentDocIdSet ];
    }
    
    public boolean getHasTasks(){
    	if(caseTasks == null){
    		return false;
    	}
    	return caseTasks.size() > 0;
    }
    
    public boolean getHasComments(){
    	if(caseComments == null){
    		return false;
    	}
    	return caseComments.size() > 0;
    }
    
    public boolean getHasAttachments(){
    	if(caseAttachments == null){
    		return false;
    	}
    	return caseAttachments.size() > 0;
    }
}