public class CaseGoodwillApprovalHandler {
    
    public void HandleGoodwillApproval(List<Case> triggerCases,  Map<id,case> oldCases)
    {
        SYSTEM.DEBUG('HandleGoodwillApproval');
        List<Case> approveCase = GetCasesToSubmit(triggerCases);
        SYSTEM.DEBUG('approveCase' +approveCase);
        if(approveCase.size() == 0) return;
        //if not in an approval process continue
        
        Map<Id, User> userList = getAllUsers();
        //RecordType employeeRecordType = [SELECT id FROM RecordType WHERE developername = 'Employee_Contact'];
        /*List<Contact> contactList = [SELECT ID, AccountID FROM Contact WHERE RecordTypeId =: employeeRecordType.Id
//added by Grant Millgate
LIMIT 1000];*/
        
        List<Contact> contactList = GetAllRetailerContacts(approveCase);
        //get's all retailers from all accounts of owners
        for(Case approveCaseX : approveCase)
        {
            system.debug('approvecasex line 18' + approveCaseX);
             Case oldCase;
            if(oldCases != null && approveCaseX.id != null && oldCases.get(approveCaseX.Id) != null){
                 oldCase = oldCases.get(approveCaseX.Id);
                 system.debug('approvecasex line 24' + oldCase);
            }
            
            system.debug('param1' + approveCaseX.Goodwill__c);
            system.debug('param2' + userList.isEmpty());
            system.debug('param3' + approveCaseX.Goodwill_Value__c);
            system.debug('param4' + oldCase);
            //system.debug('param5' + oldCase.Goodwill__c);
            if(!userList.isEmpty() && approveCaseX.Goodwill__c == Label.Goodwill_Approval_Yes && approveCaseX.Goodwill_Value__c != null && (oldCase == null || oldCase.Goodwill__c != approveCaseX.Goodwill__c))
            {
                SYSTEM.DEBUG('IN GOOD WILL LOOP' +approveCaseX);
                Id owningUserId = approveCaseX.OwnerId;
                User triggeringUser = userList.get(owningUserId);
                //checks ammount against custom setting using user true if not too high and found
                if(!IsUserAuthorised(triggeringUser, approveCaseX))
                {
                    SYSTEM.DEBUG('IsUserAuthorised noooot' );
                    FindApproverAndSubmit(approveCaseX, triggeringUser, userList.values(), contactList);
                }   
                else
                {
                    Approval.ProcessResult submitResult;
                    SYSTEM.DEBUG('IsUserAuthorised ' );
                    //submit to owner for appproval & auto approve
                    if(triggeringUser.Country_ISO_Code__c == 'AU'){
                        SYSTEM.DEBUG('OZZY ' );
                        submitResult = SubmitForApproval(owningUserId, approveCaseX.Id, 'Case_Goodwill_Approval_Process_Australia', owningUserId);
                        if(Approval.isLocked(approveCaseX.Id)) Approval.unlock(approveCaseX.Id);
                    }else{
                        if (triggeringUser.Country_ISO_Code__c == 'KR'){
                            owningUserId = UserInfo.getUserId();
                        }
                        submitResult = SubmitForApproval(owningUserId, approveCaseX.Id, Label.Goodwill_Approval_Name, null);
                        
                        
                        List<Id> workIds = submitResult.getNewWorkitemIds();
                        if(!workIds.isEmpty())
                        {
                            Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
                            approveRequest.setComments('Auto-approved');
                            approveRequest.setAction('Approve');
                            approveRequest.setWorkitemId(workIds[0]);
                            Approval.ProcessResult approveResult = Approval.process(approveRequest);
                        }
                    }
                }
            }
        }
    }
    
    //Checks that cases are not already in an approval process, removes them from the list if they are
    public List<Case> GetCasesToSubmit(List<Case> triggerCases)
    {
        List<Id> idList = new List<Id>();
        for(Case newCase : triggerCases)
        {
            idList.add(newCase.Id);
        }
        List<ProcessInstance> pi = [SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectID IN :idList AND Status != 'Approved' AND Status != 'Rejected' ];
       
        system.debug('  GetCasesToSubmit   pi   '+  pi);
        if(pi.isEmpty())
        {
            return triggerCases;
        }
        else
        {
            set<Id> caseIds = new set<Id>();
            for(ProcessInstance proI : pi)
            {
                caseIds.add(proI.TargetObjectId);
            }
            List<Case> toProcess = new List<Case>();
            for(Case trigCase : triggerCases)
            {
                if(!caseIds.contains(trigCase.Id))
                {
                    toProcess.add(trigCase);
                }
            }
            return toProcess;
        }
    }
    
    //Finds a mapping for the case amount, finds users with the specified profile, submits for approval
    public void FindApproverAndSubmit(Case approveCaseX, User triggeringUser, List<User> userList, List<Contact> contactList)
    {
        System.debug('triggeringUser (MB)');
        System.debug(triggeringUser);
        List<GoodwillApprovalMapping__c> mappings = GetApprovalMapping(approveCaseX, triggeringUser.Country_ISO_Code__c, false);
        System.debug('mappings (MB)');
        System.debug(mappings);
        User approver = null;
        approver = GetApproverFromList(mappings, triggeringUser, userList, contactList); 
        System.debug('approver (MB)');
        System.debug(approver);
        if(approver != null)
        {
            System.debug('approver is not null (MB)');
            SubmitForApproval(approver.Id, approveCaseX.Id, Label.Goodwill_Approval_Name,null);
        }
        else
        {
            System.debug('approver is null (MB)');
            //added for Korea market where final approval is not based on the Profile but based on Queue
            //Final approver user will be added to a queue. This program will fetch the Queue ID and sends it for approval
            if(triggeringUser.Country_ISO_Code__c == 'KR')
            {
				SYSTEM.DEBUG('Korea ' );
                string gwApproverwQueueName = label.GoodwillApproverQueue;
				system.debug(gwApproverwQueueName);
				List<Group> gwQueueID =[SELECT Id FROM Group where Type='Queue' And Name =:gwApproverwQueueName limit 1];
            if(gwQueueID != null)
            {
                SubmitForApproval(gwQueueID[0].Id, approveCaseX.Id, Label.Goodwill_Approval_Name, null);
            } else {
                System.debug('No Approval triggered');
            }
            }
            else {
            List<GoodwillApprovalMapping__c> unlimitedMappings = GetApprovalMapping(approveCaseX, triggeringUser.Country_ISO_Code__c, true);
            approver = GetApproverFromList(unlimitedMappings, triggeringUser, userList, contactList);
            System.debug('Final Approver Check from unlimited Mappings');
            System.debug(approver);
            if(approver != null)
            {
                SubmitForApproval(approver.Id, approveCaseX.Id, Label.Goodwill_Approval_Name, null);
            } else {
                System.debug('No Approval triggered');
            }
            }
        }
    }
    
    //goes through all potential profiles until it finds a user who can approve the amount
    public User GetApproverFromList(List<GoodwillApprovalMapping__c> mappings, User triggeringUser, List<User> userList, List<Contact> contactList)
    {
        System.debug('GetApproverFromList (MB): mappings');
        System.debug(mappings);
        System.debug('GetApproverFromList (MB): triggeringUser');
        System.debug(triggeringUser);
        System.debug('GetApproverFromList (MB): userList');
        System.debug(JSON.serialize(userList));
        System.debug('GetApproverFromList (MB): contactList');
        System.debug(JSON.serialize(contactList));
        
        for(GoodwillApprovalMapping__c  mapping : mappings)
        {
            User approver = FindApprover(mapping, triggeringUser, userList, contactList);
            if(approver != null)
            {
                return approver;
            }
        }
        return null;
    }
    
    //Gets a list of users with the profile specified in the mapping, either returns first user or finds a user in the case owner's retailer
    public User FindApprover(GoodwillApprovalMapping__c mapping, User triggeringUser, List<User> userList, List<Contact> contactList)
    {
        User approver;
        if(mapping != null)
        {
            List<User> usersWithProfile = GetUsersOfProfile(mapping, userList);
                    System.debug('inspide  (MB): FindApprover');
        System.debug(JSON.serialize(usersWithProfile));
            if(!usersWithProfile.isEmpty())
            {
                if(mapping.Type__c == Label.NSC)
                {
                    approver = usersWithProfile[0];
                }
                else if(mapping.Type__C == Label.Retailer)
                {
                    approver = GetRetailerUser(triggeringUser, usersWithProfile, contactList);
                }
            }
        }
        return approver;
    }
    
    //gets a list of all users
    public Map<Id, User> getAllUsers()
    {
        //changed as per CXPD-2617 Goodwill Case Approval Modifications
        //specifically for Korea market, goodwill process should not trigger automatically
        //User will explictly click on approval button to trigger approval process
        //gets a list of all users. extracting all users method is moved to a new class as it was not
        //fetching all users if submit is done through community user. hence created a new class "without sharing" tag
        
       /* Map<Id, User> userMap = new Map<Id, User>();
        List<User> userList = [SELECT Id, Country_ISO_Code__c, ContactId, ProfileId, ManagerId FROM User
                               WHERE aop_Has_AoP_Community_Access__c = false AND IsActive = true];
        system.debug('user list In getallusers');
        system.debug(userList.size());
        system.debug(userlist);
        for(User u : userList)
        {
            userMap.put(u.Id, u);
        }
        return userMap; */
        Map<Id, User> userMap = new Map<Id, User>();
        CaseGoodwillApprovalHandlerHelper UserMap1 = new CaseGoodwillApprovalHandlerHelper();
        UserMap = UserMap1.getAllUsersHelper();
        	return UserMap;
    }
    
    //Submits the case for approval to the specified approver   
    public Approval.ProcessResult SubmitForApproval(Id approverId, Id caseId, string processName, Id SubmitterId)
    {
        Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
        submitReq.setObjectId(caseId);
        if (SubmitterId != null) { 
            submitReq.setSubmitterId(SubmitterId);
        }else {
            submitReq.setNextApproverIds(new ID[] {approverId});
        }
        submitReq.setProcessDefinitionNameOrID(processName);
        System.debug('MB: About to submit for approveral, submitReq:');
        System.debug(submitReq);
        Approval.ProcessResult result = Approval.process(submitReq);
        system.debug(result);
        return result;
    }
    
    //if !unlimited, gets mapping where min amount < goodwill value > max amount. Else gets mapping with no maximum.  
    public List<GoodwillApprovalMapping__c> GetApprovalMapping(Case approveCase, string userCountry, boolean unlimited)
    {
        decimal amount = approveCase.Goodwill_Value__c;
        //get a list instead to check multiple profiles
        List<GoodwillApprovalMapping__c>  mappingList = new List<GoodwillApprovalMapping__c>();
        Map<string, GoodwillApprovalMapping__c> goodwillMap = GoodwillApprovalMapping__c.getAll();
        System.debug('unlimited (MB)');
        System.debug(unlimited);
        System.debug('approveCase.Goodwill_Value__c (MB)');
        System.debug(approveCase.Goodwill_Value__c);
        
        for(GoodwillApprovalMapping__c mapping : goodwillMap.values())
        {
            System.debug('mapping to evaluate');
            System.debug(mapping);
            if(!unlimited && mapping.Minimum_Value__c <= amount && mapping.Maximum_Value__c >= amount && mapping.Country__c == userCountry)
            {
                System.debug('adding not unlimited mapping result');
                mappingList.add(mapping);
                //return mapping;
            }
            else if(unlimited && mapping.Maximum_Value__c == null && mapping.Country__c == userCountry)
            {
                System.debug('adding unlimited mapping result');
                mappingList.add(mapping);
                //return mapping;
            }
        }
        System.debug('mappingList');
        System.debug(mappingList);
        return mappingList;
    }
    
    //Returns a list of users where profileId = mapping.profileID
    public List<User> GetUsersOfProfile(GoodwillApprovalMapping__c mapping, List<User> userList)
    {
        List<User> returnList = new List<user>();
        for(User u : userList)
        {
            if(u.Country_ISO_Code__c == mapping.Country__c && u.ProfileId == mapping.Profile_ID__c)
            {
                returnList.add(u);
            }
        }
        
        return returnList;
    }
    
    public List<Contact> GetAllRetailerContacts(List<Case> allCases) {
        List<Contact> retailerContacts = new List<Contact>();
        Set<Id> caseOwners = new Set<Id>();
        for(Case c : allCases){
            if(c.OwnerId != null){
                caseOwners.add(c.OwnerId);
            }
        }
        if(caseOwners.size() > 0){
            Set<Id> ownerAccounts = new Set<Id>();
            for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ContactId != null AND Contact.AccountId != null AND Id IN :caseOwners]){
                ownerAccounts.add(u.Contact.AccountId);
            }
            if(ownerAccounts.size() > 0){
                Id employeeRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
                retailerContacts = [SELECT Id, AccountId FROM Contact WHERE RecordTypeId = :employeeRecordType AND AccountId != null AND AccountId IN :ownerAccounts];
            }
        }
        return retailerContacts;
    }
    
    @AuraEnabled
    public  static void HandleGoodwillApprovalKorea (Id caseId)
    {
        //changed as per CXPD-2617 Goodwill Case Approval Modifications
        //specifically for Korea market, goodwill process should not trigger automatically
        //User will explictly click on approval button to trigger approval process
        //This method is called from "submit for approval" LWC button in community page
        system.debug('ID sent by LWC is' + caseId );
        case caseData = [SELECT CaseNumber,Cases__c,Case_Account__c,Case_Contact_Email__c,Case_Contact_Phone__c,Case_Country_ISO_Code__c,Checked_for_Deletion__c,ClosedDate,Closed_Solved__c,Country_ISO_Code__c,CreatedById,CreatedDate,Goodwill_Approval_Date__c,Goodwill_Description__c,Goodwill_Responsibility__c,Goodwill_Status__c,Goodwill_Type__c,Goodwill_Value__c,Goodwill__c,Id,IsClosed,IsClosedOnCreate,IsDeleted,IsEscalated,Lead__c,Legal_Case__c,Old_Owner__c,Other_Goodwill_Description__c,OwnerId,Owner_ISO_Code__c,Owner_Region_Or_Market__c,Status,Status__c FROM Case where Id = :caseId];
        case caseDataDummy = [SELECT CaseNumber,Cases__c,Case_Account__c,Case_Contact_Email__c,Case_Contact_Phone__c,Case_Country_ISO_Code__c,Checked_for_Deletion__c,ClosedDate,Closed_Solved__c,Country_ISO_Code__c,CreatedById,CreatedDate,Goodwill_Approval_Date__c,Goodwill_Description__c,Goodwill_Responsibility__c,Goodwill_Status__c,Goodwill_Type__c,Goodwill_Value__c,Goodwill__c,Id,IsClosed,IsClosedOnCreate,IsDeleted,IsEscalated,Lead__c,Legal_Case__c,Old_Owner__c,Other_Goodwill_Description__c,OwnerId,Owner_ISO_Code__c,Owner_Region_Or_Market__c,Status,Status__c FROM Case where Id = :caseId];


        List<case> caseDataList = New List<case>();
        caseDataList.add(caseData);
        Map<id,case> oldCases = new Map<id,case>();
        oldCases.put(caseID, caseDataDummy);
        oldCases.get(caseID).Goodwill__c = '';
        system.debug('handleKorea' + caseDataList);
        system.debug('handleKorea2' + oldCases);
        CaseGoodwillApprovalHandler approvalHandler = new  CaseGoodwillApprovalHandler();
        approvalHandler.HandleGoodwillApproval(caseDataList, oldCases);
    }
    
    @AuraEnabled
    public static boolean GoodwillButtonStatusKorea (Id caseID)
    {
        //check if goodwill is Yes or No, based on which goodwill button approval will be enabled
        List<case> goodwillcheck = [select Goodwill__c from case where Id = :caseId];
        boolean showButton = false;
        if (goodwillcheck[0].Goodwill__c == 'Yes') showButton = True;
        return showButton;
    }
    //from a list of users, returns the first who is in the same retailer as caseOwner
    public User GetRetailerUser(User caseOwner, List<User> profileList, List<contact> contactList)
    {
        Id ownerContactId = caseOwner.ContactId;
        Id AccountId;
        for(Contact con :  contactList)
        {
            if(con.Id == ownerContactId)
            {
                AccountId = con.AccountId;
                break;
            }
        }
        if(AccountID != null)
        {
            Set<Id> conIDList = new Set<Id>();
            {
                for(Contact con: contactList)
                {
                    if(con.AccountId == AccountID)
                    {
                        conIDList.add(con.Id);
                    }
                }
            }
            System.debug('ConIDList ' + conIDList);
            for(User u : profileList)
            {
                if(u.ContactID != null && conIdList.contains(u.ContactId))
                {
                    return u;
                }
            }
        }
        return null;
        
    }
    
    //Retrieves mapping for user's profile & country. If goodwill amount below max value, returns true
    public boolean IsUserAuthorised(User caseOwner, Case approveCase)
    {
        GoodwillApprovalMapping__c userMapping = GetApprovalMappingFromProfile(caseOwner);
        if(userMapping != null)
        {
            Decimal maxValue = userMapping.Maximum_Value__c;
            if(maxValue == null || approveCase.Goodwill_Value__c <= maxValue)
            {
                return true;
            }
            else
            {
                return false;
            }
            
        }
        else
        {
            return false;
        }
    }
    
    //Gets mapping where profileId = user.profileId & country code = user.country code
    public GoodwillApprovalMapping__c GetApprovalMappingFromProfile(User caseOwner)
    {
        if(caseOwner != null && caseOwner.ProfileID != null){
            Id profileID = caseOwner.ProfileID;
            List<GoodwillApprovalMapping__c> approvalMappings = GoodwillApprovalMapping__c.getAll().values();
            for(GoodwillApprovalMapping__c mapping : approvalMappings)
            {
                if(mapping.Profile_ID__c == profileId && mapping.Country__c == caseOwner.Country_ISO_Code__c)
                {
                    return mapping;
                }
            }
        }
        return null;
    }
    
}