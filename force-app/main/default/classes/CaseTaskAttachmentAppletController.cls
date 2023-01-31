public class CaseTaskAttachmentAppletController {

    public Case theCase {get;set;}
    public List<Attachment> taskAttachments {get;set;}
    public Map<Id,Task> taskMap {get;set;}
    public Boolean hasEditAccess {
        get {
            List <UserRecordAccess> permissions = [select RecordId, HasEditAccess from UserRecordAccess where RecordId = : theCase.id and UserId = : UserInfo.getUserId() ];
            if (permissions.isEmpty()) {
                return false;
            } else {
                return permissions[0].HasEditAccess;
            }
        }
    }
    /*public Boolean isPartnerUser {
        get {
                return (UserInfo.getUserType()=='PowerPartner'?true:false);
            }
    }*/
    
    public class taskAttachment {
        public string taskName {get;set;}
        public string taskId {get;set;}
        public string fileName {get;set;}
        public string fileId {get;set;}
        public string fileSize {get;set;}
        public string lastModifDate {get;set;}
        public string createdBy {get;set;}
        public string createdOn {get;set;}
    }
    
    public List<taskAttachment> clsTaskAttachments {get;set;} 
    
    public CaseTaskAttachmentAppletController(ApexPages.StandardController controller) {
    
        this.theCase = (Case) controller.getRecord();
        
        taskMap = new Map<Id,Task>(); 
        for (Task t : [select id, subject from task where whatid = : theCase.id]) taskMap.put(t.id,t); 
        
        taskAttachment ta;
        clsTaskAttachments = new List<taskAttachment>();
        
        
        Map<Id,Id> contentDocLinkedEntityMap = New Map<Id,Id>();
        for(ContentDocumentLink cdLink:[select id, LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:theCase.id OR LinkedEntityId IN:taskMap.keySet() ])
        {
          contentDocLinkedEntityMap.Put(cdLink.ContentDocumentId,cdLink.LinkedEntityId);  
        }
        
        if(!contentDocLinkedEntityMap.isEmpty()) 
        {
            for(ContentVersion a:[Select Id, Title, ContentDocumentId, lastmodifieddate, ContentSize, CreatedBy.Name, CreatedDate from ContentVersion where IsLatest=True AND ContentDocumentId IN:contentDocLinkedEntityMap.keyset() ]) 
            {
                ta = new taskAttachment();
                Id parentId=contentDocLinkedEntityMap.get(a.ContentDocumentId);
            if (taskMap.containsKey(parentId)) {
                ta.taskName='Task: '+taskMap.get(parentid).subject;
                ta.taskId=parentid;
            } else {
                ta.taskName='Case';
                ta.taskid=parentid;
            } 
            ta.fileName=a.Title;
            ta.fileId=a.id;
            ta.fileSize=String.ValueOf(a.ContentSize/1000) +'KB';
            ta.lastModifDate = a.lastmodifieddate.format('dd/MM/yyyy HH:mm');
            ta.createdBy = a.createdby.name;
            ta.createdOn = a.createddate.format('dd/MM/yyyy HH:mm');
            clsTaskAttachments.add( ta );
            }
        }
        
        /*for (Attachment a : [select id, parentid, name, bodylength, lastmodifieddate, lastmodifiedby.name, createdby.name , createddate
                            from attachment where parentid = : theCase.id or parentid in : taskMap.keySet() order by createddate desc]) {
            ta = new taskAttachment();
            if (taskMap.containsKey(a.parentId)) {
                ta.taskName='Task: '+taskMap.get(a.parentid).subject;
                ta.taskId=a.parentid;
            } else {
                ta.taskName='Case';
                ta.taskid=thecase.id;
            } 
            ta.fileName=a.name;
            ta.fileId=a.id;
            ta.fileSize=String.ValueOf(a.bodyLength/1000) +'KB';
            ta.lastModifDate = a.lastmodifieddate.format('dd/MM/yyyy HH:mm');
            ta.createdBy = a.createdby.name;
            ta.createdOn = a.createddate.format('dd/MM/yyyy HH:mm');
            clsTaskAttachments.add( ta );
        }*/
        
    }

}