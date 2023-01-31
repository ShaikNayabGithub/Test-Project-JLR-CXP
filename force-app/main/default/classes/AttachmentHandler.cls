/********************************************************************************************************
* Name         : AttachmentHandler
* @Date        : 04-May-2017
* @Description : This is handler is for trigger "AttachmentTrigger" that is used to convert the lead on incoming attachment
* UPDATES
* Version          Created By                    Date                        Description
*-------------------------------------------------------------------------------------------
*   1.0              SaasFocus                    05-May-2017                  Initial Creation 
*************************************************************************************************************--*/
public class AttachmentHandler {
    
    public void PostCreate(List<Attachment> attachments){
        fetchInsertedAttachmentInfo(attachments); 
        //cloneTaskAttachmentsAgainstParentCase(attachments);
    }
    /*public void PostUpdate(List<Attachment> OldAttachments, List<Attachment> NewAttachments){
if (!NewAttachments.isEmpty() && 
newAttachments[0].ParentId != oldAttachments[0].ParentId && 
String.ValueOf(newAttachments[0].ParentId).startsWith('00T') ) 
cloneTaskAttachmentsAgainstParentCase(NewAttachments);
}
private void cloneTaskAttachmentsAgainstParentCase(List<Attachment> attachList) {

Map<Id,Attachment> mapTaskIdToAttachment = new Map<Id,Attachment>();
List<Attachment> attachmentsToClone = new List<Attachment>();
Attachment clonedAttachment;

for (Attachment a : attachList) { 
if (String.ValueOf(a.ParentId).startsWith('00T')) { //if the attachment being created is linked to a Task 
clonedAttachment = a.clone();
mapTaskIdToAttachment.put(a.ParentId,clonedAttachment); 
}
}

if (!mapTaskIdToAttachment.isEmpty()) { 
for (Task t : [select whatid, id from task where what.type = 'Case' and id in : mapTaskIdToAttachment.keySet()]) {   
clonedAttachment = mapTaskIdToAttachment.get(t.id);
clonedAttachment.ParentId = t.whatid;
attachmentsToClone.add(clonedAttachment); 
}
}

if (!attachmentsToClone.isEmpty()) insert attachmentsToClone;

}*/
    private void fetchInsertedAttachmentInfo (List<Attachment> attachList){
        List<Attachment> listOfAttachments = new List<Attachment>();
        Set<Id> setLeadId = new Set<Id>();
        List<Lead> lstParentLead = new List<Lead>();
        Map<Id,Attachment> mapAttachmentParent = new Map<Id,Attachment> ();
        Map<Id,List<Attachment>> mapAttachmentAndLead = new Map<Id,List<Attachment>>();
        List<Attachment> listAttachmentToInsertOpp = new List<Attachment>();
        Map<string,List<lead>> mapDuplicateLead = new Map<string,List<lead>>(); 
        List<Database.LeadConvertResult> lstLeadConvertResult = new List<Database.LeadConvertResult>();
        Map<string,Id> mapAccCombination_Mobile_Email = new Map<string,Id>();
        List<Database.LeadConvert> lstLeadToConvert = new  List<Database.LeadConvert>();
        LeadStatus convertStatus;
        Set<Id> setAttToDelete = new Set<Id>();
        Id devRecordTypeId = SObjectUtilities.RecordTypes.get('Lead').get('Generic').Id;
        Set<Id> setDealer = new Set<Id>();
        Map<Id,Id> mapDealerManager = new Map<Id,Id>();
        set < string >  setPrefferedRetailer = new set < string > ();
        set < string >  setBrand = new set < string > ();
        set < string >  setPimaryModelOfInterest = new set < string > ();
        set < string >  setEmail = new set < string > ();
        set < string >  setMobile = new set < string > ();
        set < string >  setLastName = new set < string > ();
        List<Account> acctMobileEmail = new List<Account>();
        
        if(attachList != null && attachList.size()>0){ 
            listOfAttachments = [Select id,Parent.Type,ParentId,Parent.RecordtypeId from Attachment where Id in: attachList];
            if(listOfAttachments.size()>0){
                for(Attachment att :listOfAttachments ){
                    mapAttachmentParent.put(att.id,att);
                }
                for(Attachment attch : attachList){
                    if(mapAttachmentParent.get(attch.id).ParentId != null && mapAttachmentParent.get(attch.id).Parent.Type == 'Lead'){
                        setLeadId.add(mapAttachmentParent.get(attch.id).ParentId);
                        if(!mapAttachmentAndLead.containsKey(mapAttachmentParent.get(attch.id).ParentId)){
                            mapAttachmentAndLead.put(mapAttachmentParent.get(attch.id).ParentId,new List<Attachment>{attch});
                        }
                        else {
                            mapAttachmentAndLead.get(mapAttachmentParent.get(attch.id).ParentId).add(attch);
                        }
                    }
                }
            }
        }
        if(setLeadId != null && setLeadId.size()>0){
            lstParentLead = [Select Id,IsConverted,Preferred_Retailer__c,Brand__c, Primary_Model_Interest__c, LastName, Email, MobilePhone,ConvertedAccountId,ConvertedContactId,ConvertedOpportunityId,JLR_India_Udaan_Duplicate__c,owner.type,JLR_India_Udaan_Lead_Type__c,WebSiteLeadId__c from Lead
                             where Id in: setLeadId and WebSiteLeadId__c!=''];
        }
        if(lstParentLead.size()>0)
        {
            for(Lead objLead:lstParentLead)
            {
                if ( string.isNotEmpty(objLead.Preferred_Retailer__c) )
                    setPrefferedRetailer.add(objLead.Preferred_Retailer__c);
                if ( string.isNotEmpty(objLead.Brand__c) )
                    setBrand.add(objLead.Brand__c);
                if ( string.isNotEmpty(objLead.Primary_Model_Interest__c) )
                    setPimaryModelOfInterest.add(objLead.Primary_Model_Interest__c);
                if ( string.isNotEmpty(objLead.Email))
                    setEmail.add(objLead.Email);
                if ( string.isNotEmpty(objLead.MobilePhone) )
                    setMobile.add(objLead.MobilePhone);
                if ( string.isNotEmpty(objLead.LastName) )
                    setLastName.add(objLead.LastName);
                
                setDealer.add(objLead.Preferred_Retailer__c);  
            }
        }
        if(setDealer.size()>0)
        {
            for(Dealer_Manager__c objDM:[Select id,Dealer__c,Manager__c from Dealer_Manager__c where Dealer__c in:setDealer])
            {
                mapDealerManager.put(objDM.Dealer__c,objDM.Manager__c);
            }
        }
        if(setPrefferedRetailer.size()>0 && setBrand.size()>0 && setPimaryModelOfInterest.size()>0 && (setEmail.size()>0 || setMobile.size()>0 || setLastName.size()>0))
        {
            for(Lead objLead:[Select Id,IsConverted,Preferred_Retailer__c,Brand__c, Primary_Model_Interest__c, LastName, Email, MobilePhone,ConvertedAccountId,ConvertedContactId,ConvertedOpportunityId,JLR_India_Udaan_Duplicate__c,WebSiteLeadId__c from Lead
                              where Preferred_Retailer__c in : setPrefferedRetailer
                              and Brand__c in : setBrand
                              and Primary_Model_Interest__c in : setPimaryModelOfInterest
                              and (Email in : setEmail
                                   or LastName in :setLastName
                                   or MobilePhone in : setMobile
                                  )
                              and isconverted = true])
            {
                if(!mapDuplicateLead.containskey(objLead.Preferred_Retailer__c+'-'+objLead.Brand__c+'-'+objLead.Primary_Model_Interest__c+'-'+objLead.Email+'-'+objLead.MobilePhone+'-'+objLead.LastName))
                {
                    mapDuplicateLead.put(objLead.Preferred_Retailer__c+'-'+objLead.Brand__c+'-'+objLead.Primary_Model_Interest__c+'-'+objLead.Email+'-'+objLead.MobilePhone+'-'+objLead.LastName,new List<Lead>{objLead});
                }
                else
                {
                    
                    mapDuplicateLead.get(objLead.Preferred_Retailer__c+'-'+objLead.Brand__c+'-'+objLead.Primary_Model_Interest__c+'-'+objLead.Email+'-'+objLead.MobilePhone+'-'+objLead.LastName).add(objLead);
                }
            } 
        }
        
        system.debug('mapDuplicateLead'+mapDuplicateLead);
        if(setMobile.size()>0 && setEmail.size()>0)
        {
            acctMobileEmail = [Select id,PersonMobilePhone ,PersonEmail,JLR_Unique_Combination__c from Account 
                               where PersonMobilePhone in :setMobile and PersonEmail in :setEmail];
            if(acctMobileEmail.size()>0 ){
                for(Account objAcc:acctMobileEmail) 
                {
                    mapAccCombination_Mobile_Email.put(objAcc.PersonMobilePhone+'-'+objAcc.PersonEmail,objAcc.Id);
                    
                }
            }
        }               
        if(lstParentLead != null && lstParentLead.size()>0){
            convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            for(Lead leadObj : lstParentLead){
                if(string.isNotEmpty(leadObj.WebSiteLeadId__c))
                {
                    if(leadObj.JLR_India_Udaan_Duplicate__c == true && mapDuplicateLead.containskey(leadObj.Preferred_Retailer__c+'-'+leadObj.Brand__c+'-'+leadObj.Primary_Model_Interest__c+'-'+leadObj.Email+'-'+leadObj.MobilePhone+'-'+leadObj.LastName)){                                
                        if(mapAttachmentAndLead != null && mapAttachmentAndLead.containsKey(leadObj.id)){
                            for(Attachment att : mapAttachmentAndLead.get(leadObj.id)){
                                for(Lead leadObj_2:mapDuplicateLead.get(leadObj.Preferred_Retailer__c+'-'+leadObj.Brand__c+'-'+leadObj.Primary_Model_Interest__c+'-'+leadObj.Email+'-'+leadObj.MobilePhone+'-'+leadObj.LastName)){ 
                                    Attachment atachmentToInsertOpp = new Attachment();
                                    if(leadObj_2.ConvertedOpportunityId != null){
                                        atachmentToInsertOpp = att.clone(); 
                                        atachmentToInsertOpp.parentId = leadObj_2.ConvertedOpportunityId; 
                                        listAttachmentToInsertOpp.add(atachmentToInsertOpp);
                                    }
                                } 
                            }
                        }
                        
                    }
                    else 
                        if(leadObj.isConverted == False && leadObj.JLR_India_Udaan_Lead_Type__c=='Booking')
                    { 
                        Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(leadObj.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        
                        if(mapAccCombination_Mobile_Email.containsKey(leadObj.MobilePhone+'-'+leadObj.Email))
                            lc.accountId=mapAccCombination_Mobile_Email.get(leadObj.MobilePhone+'-'+leadObj.Email);
                        if(leadObj.owner.type=='Queue')
                        {
                            if (mapDealerManager.containskey(leadObj.Preferred_Retailer__c) && mapDealerManager.get(leadObj.Preferred_Retailer__c)!=null)
                                
                            {
                                lc.setownerId(mapDealerManager.get(leadObj.Preferred_Retailer__c));
                                lstLeadToConvert.add(lc);
                            }
                        }
                        else
                            lstLeadToConvert.add(lc);
                        
                    }
                } 
            }
        }
        
        if(lstLeadToConvert!=null && lstLeadToConvert.size()>0)
        {
            lstLeadConvertResult = Database.convertLead(lstLeadToConvert); 
            for(Database.LeadConvertResult lcr:  lstLeadConvertResult)
            {
                if(lcr.isSuccess())
                {
                    if(mapAttachmentAndLead != null && mapAttachmentAndLead.containsKey(lcr.getLeadId())){
                        for(Attachment att : mapAttachmentAndLead.get(lcr.getLeadId())){
                            Attachment attChToUpdate = att.clone();
                            attChToUpdate.ParentId=lcr.getOpportunityId(); 
                            listAttachmentToInsertOpp.add(attChToUpdate);
                            setAttToDelete.add(att.Id);
                        }
                    }   
                    
                }
            }
        }
        
        if(listAttachmentToInsertOpp != null && listAttachmentToInsertOpp.size()>0){
            Insert listAttachmentToInsertOpp;
        }
        if(setAttToDelete != null && setAttToDelete.size()>0){
            Delete [Select Id from Attachment where id in :setAttToDelete];
        }
        
    }
}