public class NotesCustomRelatedListController {
    
    @auraEnabled 
    public static list<contentNoteClass> fetchAllRelatedNotes(Id ParentId)
    {
        Set<Id> contentDocIdSet = New Set<Id>();
        for(ContentDocumentLink cdl:[select Id, ContentDocumentId from ContentDocumentLink where LinkedEntityId=:ParentId])
        {
            contentDocIdSet.add(cdl.ContentDocumentId); 
        }
        List<contentNoteClass> notesList= New List<contentNoteClass>();
        for(ContentNote cn: [SELECT Content,
                             CreatedById,
                             CreatedBy.Name,
                             CreatedDate,
                             Id,
                             TextPreview,
                             Title
                             FROM ContentNote 
                             WHERE
                             Id IN:contentDocIdSet
                             ORDER BY CreatedDate DESC])
        {
            contentNoteClass objNote= new contentNoteClass();
            objNote.objNote=cn;
            objNote.Content=cn.Content.toString();
            notesList.add(objNote);
        }
        return notesList;
    }
    
    @AuraEnabled
    public static void createRecord (ContentNote nt, id PrentId){
        try{
            if(nt != null && nt.Id ==null){
                insert nt;
                ContentDocument cd=[select id from ContentDocument where id=:nt.Id];
                ContentDocumentLink cdl=new ContentDocumentLink();
                cdl.ContentDocumentId=cd.id;
                cdl.LinkedEntityId=PrentId;
                cdl.ShareType='V';
                cdl.Visibility='AllUsers';
                insert cdl;
            }else if(nt !=null)
                update nt;
        } catch (Exception ex){
            system.debug('@@@@ '+ex.getMessage());
        }
    }  
    
    @AuraEnabled
    public static void updateNote (ContentNote nt){
        try{
            if(nt != null){
                Update nt;
            }
        } catch (Exception ex){
            system.debug('@@@@ '+ex.getMessage());
        }
    } 
    
    @auraEnabled 
    public static void deleteNote(ContentNote nt){
        try{
            if(nt != null){
                delete nt;
            }
        } catch (Exception ex){
            system.debug('@@@@ '+ex.getMessage());
        }
    }
    
    public class contentNoteClass{
        @AuraEnabled public ContentNote objNote{get;set;}
        @AuraEnabled public String Content{get;set;}
    }
}