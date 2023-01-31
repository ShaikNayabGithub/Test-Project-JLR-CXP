global class shareAccountToRetailer implements Database.Batchable<sObject>{
     public Set<Id> AccIdSet;
     public Boolean chainAnotherbatch = true;
     public string errorMsgString;
     global shareAccountToRetailer(){
         errorMsgString='';
         AccIdSet= new Set<id>();
         Datetime halfHourBack = Datetime.now().addMinutes(-5);
         for(Opportunity opp:[select id, AccountId,Retailer__c,Asset__r.AccountId,Country_ISO_Code__c,StageName from opportunity where Retailer__c!=null and lastmodifieddate >= :halfHourBack AND LeadSource ='UDAAN' AND StageName in ('Save a Quote','Pay Deposit','Trade-in Valuation')]){ //hartnady edit 21/08/18 
             IF(opp.Country_ISO_Code__c=='JP' && opp.StageName=='Pay Deposit'){
                 AccIdSet.add(opp.Accountid);
             }
             ELSE IF(opp.Country_ISO_Code__c!='JP'){
                 AccIdSet.add(opp.Accountid);
             }
         }
         for(Case objCase:[select id, AccountId,Retailer__c,Asset.Accountid from Case where createddate >= :halfHourBack AND Origin='OSA Query']){
             AccIdSet.add(objCase.Accountid);
         }
         system.debug('----------oppAccSet'+AccIdSet);
     }
     global Database.QueryLocator start(Database.BatchableContext BC)
     {
         return Database.getQueryLocator([select id FROM ACCOUNT where id IN: AccIdSet]);
     }
     global void execute(System.SchedulableContext sc){
         List<AsyncApexJob> existingJobs = [SELECT Id FROM AsyncApexJob 
                      where jobtype = 'batchapex' and
                      apexclass.name = 'shareAccountToRetailer'
                      and status in ('Holding','Queued','Preparing','Processing') limit 1];

        //don't create a new batch if one is already running
        if(existingJobs.size() > 1) return;
            shareAccountToRetailer batch = new shareAccountToRetailer ();
           // Database.executeBatch(batch,1000);
      }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Set<Id> AccToShareIds= new Set<id>();
        List<Opportunity> currentopp= new List<Opportunity>();
        List<Case> currentcase= new List<Case>();
        for(sObject scp: Scope){
            AccToShareIds.add(scp.id);
        
        }
        if(!AccToShareIds.IsEmpty()){
            currentopp=[select id, Accountid,Retailer__c,Asset__r.AccountId from Opportunity where AccountID IN:AccToShareIds AND LeadSource ='UDAAN' limit 100];
            currentCase=[select id, Accountid,Retailer__c,Asset.Accountid from Case where AccountID IN:AccToShareIds AND Origin='OSA Query' limit 100];
        }
        if(!currentopp.IsEmpty()){
            shareOpportunity(currentopp);
        }
        if(!currentcase.IsEmpty()){
            shareCase(currentcase);
        }
        
        
    }
    
    global void shareOpportunity(List<Opportunity> shareOppLst){
        List<Opportunity> currentopp= shareOppLst;
        system.debug('----------currentopp'+currentopp);
        List<UserRole> RoleHierarchyParentPortalRoles= new List<UserRole>();
        List<AccountShare> accShareLst = new List<AccountShare>();
        Map<Id, Id> partnerCommunityAccounts = new Map<Id, Id>();
        for(Opportunity opp:currentopp){
            partnerCommunityAccounts.put(opp.Retailer__c, null);
        }
        if(!partnerCommunityAccounts.isEmpty()){
            for(Account acc : [SELECT ParentId, Id FROM Account WHERE Id IN :partnerCommunityAccounts.keySet()]){
                partnerCommunityAccounts.put(acc.Id, acc.ParentId);
            }
        }
        Map<Id, List<UserRole>> parentPartnerCommunityAccounts = new Map<Id, List<UserRole>>();
        Id CustomerCommunityAccountId;
        Id PartnerCommunityAccountId;
        Id ParentPartnerCommunityId;
        for(Opportunity opp:currentopp){
            CustomerCommunityAccountId= opp.Accountid;
            PartnerCommunityAccountId= opp.Retailer__c; ////hartnady edit 21/08/18 replaced 'opp.Asset__r.AccountId' with 'opp.Retailer__c'
            ParentPartnerCommunityId = null;
            if(PartnerCommunityAccountId!=null ){
                //DON'T DO THIS IN A FOR LOOP
                //ParentPartnerCommunityId=[select ParentId, id from Account where id=:PartnerCommunityAccountId].ParentId;
                if(partnerCommunityAccounts.containsKey(PartnerCommunityAccountId)){
                    ParentPartnerCommunityId = partnerCommunityAccounts.get(PartnerCommunityAccountId);
                    parentPartnerCommunityAccounts.put(ParentPartnerCommunityId, null);
                }
            }
        }
        for(UserRole ur : [SELECT Id, PortalRole, PortalAccountId FROM UserRole WHERE PortalRole IN ('Worker','Manager','Executive') AND PortalAccountId IN :parentPartnerCommunityAccounts.keySet()]){
            List<UserRole> urlist = new List<UserRole>();
            if(parentPartnerCommunityAccounts.get(ur.PortalAccountId) != null){
                urlist = parentPartnerCommunityAccounts.get(ur.PortalAccountId);
            }
            urlist.add(ur);
            parentPartnerCommunityAccounts.put(ur.PortalAccountId, urlist);
        }
        for(Opportunity opp : currentopp){
            Map<String,Id> PortalRoles = new Map<String,Id>();
            Map<String,Id> ParentPortalRoles = new Map<String,Id>();
            Id ParentPortalRoleId;
            IF(ParentPartnerCommunityId!= null ){
                 //DON'T DO THIS IN A FOR LOOP
                 //RoleHierarchyParentPortalRoles = [SELECT Id, PortalRole FROM UserRole where PortalRole IN ('Worker','Manager','Executive') AND PortalAccountId = : ParentPartnerCommunityId];
                 RoleHierarchyParentPortalRoles = new List<UserRole>();
                 if(parentPartnerCommunityAccounts.containsKey(ParentPartnerCommunityId)){
                     RoleHierarchyParentPortalRoles = parentPartnerCommunityAccounts.get(ParentPartnerCommunityId);
                 }
                 If(RoleHierarchyParentPortalRoles.size()>0){
                 for (UserRole ur : RoleHierarchyParentPortalRoles ) ParentPortalRoles.put(ur.PortalRole,ur.id); 
                     if (ParentPortalRoles.containsKey('Worker') ) {
                        ParentPortalRoleId= ParentPortalRoles.get('Worker') ;
                     } else if ( ParentPortalRoles.containsKey('Manager') ) {
                        ParentPortalRoleId= ParentPortalRoles.get('Manager') ;
                     } else {
                        ParentPortalRoleId= ParentPortalRoles.get('Executive') ;
                     }
                 }
            }
            List<Group> objParentGrps= new List<Group>();
            IF(ParentPortalRoleId!= null ){
                objParentGrps = [Select Id From Group where Type='Role' and RelatedId = : ParentPortalRoleId];
            }
            system.debug('-------PartnerCommunityAccountId'+PartnerCommunityAccountId);
            List<UserRole> RoleHierarchyPortalRoles = new List<UserRole>();
            if(PartnerCommunityAccountId != null){
                RoleHierarchyPortalRoles = [SELECT Id, PortalRole FROM UserRole where PortalRole IN ('Worker','Manager','Executive') AND PortalAccountId = : PartnerCommunityAccountId];
            }
            system.debug('-------RoleHierarchyPortalRoles'+RoleHierarchyPortalRoles );
            system.debug('-------User'+UserInfo.getUserId() );
            //if (RoleHierarchyPortalRoles.isEmpty()) return 'Cannot share Account '+String.ValueOf(CustomerCommunityAccountId)+' as no Partner User Role entries exist for Partner Account ' + String.ValueOf(PartnerCommunityAccountId);
            for (UserRole ur : RoleHierarchyPortalRoles) PortalRoles.put(ur.PortalRole,ur.id); 
            Id PortalRoleId;
            if ( PortalRoles.containsKey('Worker') ) {
                PortalRoleId = PortalRoles.get('Worker') ;
            } else if ( PortalRoles.containsKey('Manager') ) {
                PortalRoleId= PortalRoles.get('Manager') ;
            } else {
               PortalRoleId= PortalRoles.get('Executive') ;
            }
        
            List<Group> objGrps = new List<Group>();
            if(PortalRoleId != null){
                objGrps = [Select Id From Group where Type='Role' and RelatedId = : PortalRoleId];
            }
                system.debug('-------objGrps '+objGrps );
        
            if (!objGrps.isEmpty()){ 
                AccountShare ash = new AccountShare();
                ash.AccountAccessLevel = 'Edit';
                ash.AccountId =CustomerCommunityAccountId;
                ash.CaseAccessLevel = 'Edit';
                ash.OpportunityAccessLevel = 'Edit';
                //ash.RowCause = Schema.AccountShare.rowCause.PartnerCommunityAccountId;
                ash.UserOrGroupId =objGrps[0].id;
                accShareLst.add(ash);
                
            }
            if (!objParentGrps.isEmpty()){ 
                AccountShare ashParent = new AccountShare();
                ashParent.AccountAccessLevel = 'Edit';
                ashParent.AccountId =CustomerCommunityAccountId;
                ashParent.CaseAccessLevel = 'Edit';
                ashParent.OpportunityAccessLevel = 'Edit';
                //ash.RowCause = Schema.AccountShare.rowCause.PartnerCommunityAccountId;
                ashParent.UserOrGroupId =objParentGrps[0].id;
                accShareLst.add(ashParent);
             
            }
        }
        if(!accShareLst.IsEmpty()){
            try{
                Database.upsertresult[] saveresultarray=Database.upsert(accShareLst);
                for(Integer i=0;i<saveresultarray.size();i++){
                    if(!saveresultarray.get(i).isSuccess()){
                        Database.error Error=saveresultarray.get(i).geterrors().get(0);
                        String FailingMsg=Error.getmessage();
                        //errorMsgmap.put(accShareLst.get(i).AccountId,FailingMsg);
                        errorMsgString=errorMsgString+accShareLst.get(i).AccountId +FailingMsg+',';
                    }
                }
            }catch(Exception ex){
                errorMsgString += '\n\n' + ex.getMessage(); //edit hartnady 21/08/18
            }
        }
    }
    
    global void shareCase(List<Case> shareCaseLst){
        List<Case> currentCase= shareCaseLst;
        system.debug('----------currentCase'+currentCase);
        List<AccountShare> accShareLst = new List<AccountShare>();
        Set<Id> userRoleIds = new Set<Id>();
        for(Case objCase:currentCase){
            userRoleIds.add(objCase.Asset.AccountId);
        }
        List<UserRole> allRoleHierarchyPortalRoles = new List<UserRole>();
        if(!userRoleIds.isEmpty()){
            allRoleHierarchyPortalRoles = [SELECT Id, PortalRole, PortalAccountId FROM UserRole WHERE PortalRole IN ('Worker', 'Manager', 'Executive') AND PortalAccountId IN :userRoleIds];
        }
        User usr = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        Map<Id, List<Group>> groupMap = new Map<Id, List<Group>>();
        for(Group grp : [SELECT Id, RelatedId FROM Group WHERE Type='Role' AND RelatedId != null]){
            List<Group> grplist = new List<Group>();
            if(groupMap.containsKey(grp.RelatedId)){
                grplist = groupMap.get(grp.RelatedId);
            }
            grplist.add(grp);
            groupMap.put(grp.RelatedId, grplist);
        }
        for(Case objCase:currentCase){
            Id CustomerCommunityAccountId= objCase.Accountid;
            Id PartnerCommunityAccountId= objCase.Asset.Accountid ;
            Map<String,Id> PortalRoles = new Map<String,Id>();
            system.debug('-------PartnerCommunityAccountId'+PartnerCommunityAccountId);
            //DON'T DO THIS INSIDE A FOR LOOP
            //List<UserRole> RoleHierarchyPortalRoles = [SELECT Id, PortalRole FROM UserRole where PortalRole IN ('Worker','Manager','Executive') AND PortalAccountId = : PartnerCommunityAccountId];
            //system.debug('-------RoleHierarchyPortalRoles'+RoleHierarchyPortalRoles );
            system.debug('-------User'+UserInfo.getUserId() );
            //if (RoleHierarchyPortalRoles.isEmpty()) return 'Cannot share Account '+String.ValueOf(CustomerCommunityAccountId)+' as no Partner User Role entries exist for Partner Account ' + String.ValueOf(PartnerCommunityAccountId);
            //for (UserRole ur : RoleHierarchyPortalRoles) PortalRoles.put(ur.PortalRole,ur.id); 
            for(UserRole ur : allRoleHierarchyPortalRoles){
                if(ur.PortalAccountId == PartnerCommunityAccountId){
                    PortalRoles.put(ur.PortalRole, ur.Id);
                }
            }
            Id PortalRoleId;
            if ( PortalRoles.containsKey('Worker') ) {
                PortalRoleId = PortalRoles.get('Worker') ;
            } else if ( PortalRoles.containsKey('Manager') ) {
                PortalRoleId= PortalRoles.get('Manager') ;
            } else {
               PortalRoleId= PortalRoles.get('Executive') ;
            }
        
            List<Group> objGrps = new List<Group>();
            if(PortalRoleId != null){
                //DON'T DO THIS IN A FOR LOOP
                //objGrps = [Select Id From Group where Type='Role' and RelatedId = : PortalRoleId];
                if(groupMap.containsKey(PortalRoleId)){
                    objGrps = groupMap.get(PortalRoleId);
                }
            }
            system.debug('-------objGrps '+objGrps );
    
            if (!objGrps.isEmpty()) {
                //DON'T DO THIS IN A FOR LOOP
                //User usr=[select id,accountid from user where id=:Userinfo.getuserid()];
                system.debug('-------usr'+usr );
                AccountShare ash = new AccountShare();
                ash.AccountAccessLevel = 'Edit';
                ash.AccountId =CustomerCommunityAccountId;
                ash.CaseAccessLevel = 'Edit';
                ash.OpportunityAccessLevel = 'Edit';
                //ash.RowCause = Schema.AccountShare.rowCause.PartnerCommunityAccountId;
                ash.UserOrGroupId =objGrps[0].id;
                accShareLst.add(ash);
                
            }
        }
        if(!accShareLst.IsEmpty()){
            try{
                Database.upsertresult[] saveresultarray=Database.upsert(accShareLst);
                for(Integer i=0;i<saveresultarray.size();i++){
                    if(!saveresultarray.get(i).isSuccess()){
                        Database.error Error=saveresultarray.get(i).geterrors().get(0);
                        String FailingMsg=Error.getmessage();
                        //errorMsgmap.put(accShareLst.get(i).AccountId,FailingMsg);
                        errorMsgString=errorMsgString+accShareLst.get(i).AccountId +FailingMsg+',';
                    }
                }
            }catch(Exception ex){
                errorMsgString += '\n\n' + ex.getMessage(); //edit hartnady 21/08/18
            }
        }
    }
     
    global void finish(Database.BatchableContext BC)
    {  
        if(errorMsgString!=''){
           EmailUtility.SendEmail(new List<String>{system.label.Debug_EmailAddress_JLR,system.label.Debug_EmailAddress_TCS}, 'shareAccountToRetailer Exception', 'shareAccountToRetailer.cls Exception - ' + system.now(), errorMsgString);
        }
    }
}