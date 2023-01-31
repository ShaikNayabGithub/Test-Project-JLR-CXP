public class aop_RequestTriggerHandler {
    List<RecordType> recordTypes;
    List<Contact>  contactList;
    List<Account>  accountList;
    List<aop_Area_Configuration__c>  configList;
    aop_EventRequestTriggerLogic businessLogic;
    aop_EmailController emailController;
    
    public aop_RequestTriggerHandler()
    {
        this.recordTypes = aop_RequestTriggerSetup.GetRecordTypes();
        //this.contactList = aop_RequestTriggerSetup.GetContacts();
        //this.accountList = aop_RequestTriggerSetup.GetAccounts();
        this.configList = aop_RequestTriggerSetup.GetConfigs();
        this.businessLogic = new aop_EventRequestTriggerLogic();
        this.emailController = new aop_EmailController();
    }
    
    public void preCreate(List<Request__c>  requests)
    {
        List<Id> contactIds = new List<Id>();
        for(Request__c evReq : requests)
        {
            if(evReq.aop_Customer__c != null)
            {
                contactIds.add(evReq.aop_Customer__c);
            }    
        }
        this.contactList = aop_RequestTriggerSetup.GetContacts(contactIds);
        this.accountList = aop_RequestTriggerSetup.GetAccounts(requests);
        for(Request__c evReq : requests)
        {
            if(aop_EventRequestTriggerLogic.IsAOPRequest(evReq, recordTypes))
            {
                    evReq = businessLogic.HandleEventRequestContact(evReq, contactList, configList);
                    evReq = businessLogic.HandleNoQualificationNeeded(evReq);
                    evReq = businessLogic.HandleWalkIn(evReq, recordTypes, configList);   
                    evReq = businessLogic.HandleQualification(evReq, accountList, configList);  
                    evReq = businessLogic.HandlePersonAccountCreation(evReq, recordTypes, configList); 
                    businessLogic.SetContactQualified(evReq);   
            }
        }
    }
    
    public void preUpdate(List<Request__c>  requests)
    {
        this.accountList = aop_RequestTriggerSetup.GetAccounts(requests);
        List<Id> contactIds = new List<Id>();
        for(Request__c evReq : requests)
        {
            if(evReq.aop_Customer__c != null)
            {
                contactIds.add(evReq.aop_Customer__c);
            }    
        }
        this.contactList = aop_RequestTriggerSetup.GetContacts(contactIds);
        for(Request__c evReq : requests)
        {
            if(aop_EventRequestTriggerLogic.IsAOPRequest(evReq, recordTypes))
            {
                    businessLogic.HandleBeforeUpdate(evReq, Trigger.Old, recordTypes, accountList, configList, contactList);
            }
        }
        
    }
    
    public void postCreate(List<Request__c>  requests)
    {
        for(Request__c evReq : requests)
        {
            if(aop_EventRequestTriggerLogic.IsAOPRequest(evReq, recordTypes))
            {
                aop_EventRequestTriggerLogic.HandleCommunityAccess(evReq.Id);
                aop_EventRequestTriggerLogic.HandleWalkInCommunityAccess(evReq.ID);
                emailController.CheckIfDisqualifiedOrNoQualificationRequired(evReq);
            }
        }
    }
    
    public void postUpdate(List<Request__c>  requests, Map<Id, Request__c>  newRequests, Map<Id, Request__c> oldRequests)
    {
        for(Request__c evReq : requests)
        {
            if(aop_EventRequestTriggerLogic.IsAOPRequest(evReq, recordTypes))
            {
                aop_EventRequestTriggerLogic.HandleCommunityAccess(evReq.Id);
                if(newRequests.get(evReq.id).aop_Status__c != oldRequests.get(evReq.id).aop_Status__c)
                    {
                        emailController.CheckIfDisqualifiedOrNoQualificationRequired(evReq);
                    }
            }
        }
    }
    

}