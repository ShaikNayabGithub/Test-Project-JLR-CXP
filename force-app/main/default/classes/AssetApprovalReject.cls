public without sharing class AssetApprovalReject {
    public String assetIds {get; set;}
    public Asset thisAsset {get; set;}
    
    Public String sfdcBaseURL {get; set;}
    Public String ApprovalStepName {get; set;}
    Public String StepStatusName {get; set;}
    
    public  ProcessInstanceStep CurrentApprovalRequest {
        get {

            try {

                if (assetIds != null && processInstanceId != null) {
                    List<ProcessInstanceStep> steps = [SELECT SystemModstamp, 
                                                              StepStatus, 
                                                              ProcessInstanceId, 
                                                              Comments, 
                                                              ActorId
                                                       FROM ProcessInstanceStep
                                                       WHERE ProcessInstanceId=:processInstanceId
                                                       ORDER BY CreatedDate DESC
                                                       LIMIT 1];  
                    
                    if  (steps.size() != 1) {
                        return null;
                    }
                    else {
                        CurrentApprovalRequest = steps[0];
                    }
                }

            } 
            catch (Exception e){
                System.Debug(e);
                throw e;
            }

            return CurrentApprovalRequest;
        }
        
        set;
    }
    
    public ProcessInstanceStep OriginalApprovalRequest {
        get {

            try {

                if (OriginalApprovalRequest == null ) {
                    if (assetIds != null && processInstanceId != null) {
                        List<ProcessInstanceStep> pSteps = [SELECT SystemModstamp, 
                                                            StepStatus, 
                                                            ProcessInstanceId, 
                                                            OriginalActorId, 
                                                            Comments, 
                                                            ActorId
                                FROM ProcessInstanceStep
                                 WHERE ProcessInstanceId=:processInstanceId 
                                 ORDER BY CreatedDate ASC
                                LIMIT 1];  
                        if (psteps.size() != 1) {
                            return null;
                        } else { 
                            OriginalApprovalRequest = psteps[0];
                        }
                    }
                    
                }
            } 

            catch (Exception e){
                System.Debug(e);
                throw e;
            }

            return OriginalApprovalRequest;  
        }
        
        set;
        
    }
    
    public User OriginalRequestor {
        get {
            try {
                if(OriginalRequestor == null && OriginalApprovalRequest != null) {
                    List<User> users = [SELECT Id, 
                                               CompanyName, 
                                               FirstName, 
                                               LastName,
                                               UserType
                                        FROM User 
                                        WHERE Id=:OriginalApprovalRequest.ActorId];
                    
                    if (users.size() != 1) {
                        return null;
                    } else {
                        OriginalRequestor = users[0];
                    }
                }
            }

            catch (Exception e){
                System.Debug(e);
                throw e;
            }

            return OriginalRequestor;
            
        }      
        set;
    }
    
    public User CurrentApprover {
        get {
            try {
            if(OriginalRequestor == null && CurrentApprovalRequest != null) {
                List<User> users = [SELECT Id, CompanyName, FirstName, LastName, UserType, ContactId FROM User WHERE Id=:CurrentApprovalRequest.OriginalActorId];
                
                if (users.size() != 1) {
                    return null;
                } else {
                    OriginalRequestor = users[0];
                }
            }
                } catch (Exception e){
                System.Debug(e);
                throw e;
            }
            return OriginalRequestor;
            
        }      
        set;
    }
    
    
    
    public Id ProcessInstanceId {
        get { 
            try {
                if(ProcessInstanceId == null && assetIds != null) {
                    List<ProcessInstance> pi = [SELECT Id 
                                                FROM ProcessInstance 
                                                WHERE targetObjectId=:assetIds 
                                                ORDER BY CreatedDate DESC LIMIT 1];
                    if (pi.size() != 1) {
                        return null;
                    } else {
                        ProcessInstanceId = pi[0].Id;
                    } 
                }
            } 

            catch (Exception e){
                System.Debug(e);
                throw e;
            }

            return ProcessInstanceId;
        }

        set;
                                   
    }
    
    public Asset getAssets() {
        try {
        if (assetIds != null) {
            thisAsset = [SELECT Id, name
                        FROM Asset
                        WHERE Id=:assetIds
                        LIMIT 1];
        }
            } catch (Exception e){
                System.Debug(e);
                throw e;
            }
        return thisAsset;
    }
    
    public String getURL() {
        
        if (assetIds == null || CurrentApprover == null) return null;
        
        String urlPrefix = URL.getSalesforceBaseUrl().toExternalForm();
        try {
            if (CurrentApprover.UserType == 'Partner' || CurrentApprover.UserType == 'Power Partner') {
                List<NetworkMember> memberships = [SELECT NetworkId 
                                                   FROM NetworkMember 
                                                   WHERE MemberId = :CurrentApprover.Id];
                
                if (memberships.size() == 0) {
                    return null;
                }
                
                ConnectApi.Community community = ConnectApi.Communities.getCommunity((String)memberships[0].NetworkId);
                
                urlPrefix = community.urlPathPrefix;
            }
        }
        catch (Exception e) {
            System.debug(e);
            throw e;
        } 
        
        return urlPrefix + '/' + assetIds;
    }
    
}