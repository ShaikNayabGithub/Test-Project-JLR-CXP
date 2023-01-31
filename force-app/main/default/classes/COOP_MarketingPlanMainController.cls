public class  COOP_MarketingPlanMainController{
    
    @AuraEnabled
    public static SchemaUtility.CurrentDateDetails getFYearDetails() {
        return  new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());       
    } 
    
    
    @AuraEnabled
    public static User getUserDetails() {
        return  [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Id =:userInfo.getUserId()];       
    }
    
    @AuraEnabled
    public static List<String> getCampaignsDetails(String currentFYYear, String currentQuarter) {
        
        String fyYear = '%'+currentFYYear+'%'; 
        String fquarter = '%Q'+ currentQuarter+'%';                                                      
        String wherecondition =' WHERE Name Like :fyYear AND Name Like :fquarter AND Retailer__c != null  ORDER BY Retailer__r.Name ASC  ';
        String query = 'SELECT Id,Name,Retailer__r.Name,Status,Retailer_Quarter_Budget__c,Planned_spend_to_date_per_campaign__c,'+
            'Carry_Forwarded_Budget__c,Total_Claim_Amount__c,Total_Claim_For_Quarter__c,Total_Penalty_Amount__c,Final_Eligible_Budget__c,'+
            'coop_Actual_spend_per_campaign__c,COOP_Remaining_Amount__c,COOP_Actual_Budget__c,COOP_Adjustment_Amount__c,'+
            '(SELECT ID FROM ProcessInstances WHERE Status=\'Pending\' ORDER BY CreatedDate DESC)  FROM Campaign ' ;
        system.debug(currentFYYear+currentQuarter+query+wherecondition);
        List<Campaign> campaignList = database.query(query+wherecondition);
        List<String> retailerNameList = new List<String>();
        for(Campaign singleCampaign: campaignList){
            if(singleCampaign.Retailer__c != null && !retailerNameList.contains(singleCampaign.Retailer__r.Name) ) retailerNameList.add(singleCampaign.Retailer__r.Name);
        }
        return retailerNameList;
    } 
    
    @AuraEnabled
    public static Map<String,List<String>> getModelList() {
        return  SchemaUtility.getDependentPicklistValues(Campaign.coop_Model__c);       
    } 
    
    @AuraEnabled
    public static List<Campaign> searchCampaigns(String selectedFYYear, String selectedQuarter, String selectedBrand,String selectedModel, String selectedRetailer) {
        String fyYear = '%'+selectedFYYear+'%'; 
        String fquarter = '%Q'+ selectedQuarter+'%';                                                      
        String wherecondition =' WHERE Name Like :fyYear AND Name Like :fquarter ';
        String childQuery = 'SELECT Id,Name,Model__c,Status__c,Is_Locked__c,Business_Type__c, Media_Type__c,'+
            ' PlannedspendforActivity__c, ActualspendforActivity__c, Total_Claimed_Amount__c, Start_Date__c, End_Date__c, Description__c,'+
            ' Experiences_Target__c, Leads_Target__c, Penalty__c, Funnel_Category__c, GRMS_Comments__c FROM Campaign_activities__r ';
        String ChildWhereCondition = ' WHERE (NOT(Status__c IN (\'Activity Rejected\',\'Activity Canceled\' )))';
        if(selectedBrand == 'Jaguar'){
            wherecondition = wherecondition+ ' AND Name Like \'%JAG%\' ';
        }else if(selectedBrand == 'Land Rover'){
            wherecondition = wherecondition+ ' AND Name Like \'%LR%\' ';            
        }
        if(selectedModel != null && selectedModel != 'none' && selectedModel != ''){
            ChildWhereCondition = ChildWhereCondition+' AND Model__c INCLUDES (\''+selectedModel+'\') ';
        }
        if(selectedRetailer != null && selectedRetailer != ''){ 
            wherecondition =wherecondition+' AND Retailer__r.Name LIKE \'%'+selectedRetailer+'%\' ';
        }else{
            wherecondition =wherecondition+' AND Retailer__c != null ';
        }
        String query = 'SELECT Id,Name,CurrencyIsoCode,Status,Retailer_Quarter_Budget__c,Planned_spend_to_date_per_campaign__c,'+
            'Carry_Forwarded_Budget__c,Total_Claim_Amount__c,Total_Claim_For_Quarter__c,Total_Penalty_Amount__c,Final_Eligible_Budget__c,'+
            'coop_Actual_spend_per_campaign__c,COOP_Remaining_Amount__c,COOP_Actual_Budget__c,COOP_Adjustment_Amount__c,'+
            '(SELECT ID FROM ProcessInstances WHERE '+
            ' Status=\'Pending\' ORDER BY CreatedDate DESC),  ('+ childQuery+ChildWhereCondition+' order by status__c ) FROM Campaign ' ;
        
        List<Campaign> campaignList = database.query(query+wherecondition+' ORDER BY Retailer__r.Name ASC LIMIT 2');
        return  campaignList;       
    } 
    
    @AuraEnabled
    public static String getNextApproverDetails(String campaignId) {
        String nextApproverName ;
        List<ProcessInstanceWorkitem> pendingAIName =[SELECT  Actor.Name
                                                      FROM ProcessInstanceWorkitem 
                                                      WHERE 
                                                      ProcessInstance.Status = 'Pending' AND 
                                                      ProcessInstance.TargetObjectId=:campaignId ORDER BY CreatedDate DESC];
        
        if(!pendingAIName.isEmpty())
        {
            for(ProcessInstanceWorkitem userDetails:pendingAIName){
                if(nextApproverName==null && string.isBlank(nextApproverName))
                    nextApproverName = ''+userDetails.Actor.Name;
                else
                    nextApproverName+='/ '+userDetails.Actor.Name;
            }
        }
        return  nextApproverName;       
    } 
    
    @AuraEnabled
    public static String saveCampaigns(List<Campaign> updateCampaignList) {
        try{
            List<Campaign> updatedList =new List<Campaign>();
            for(Campaign singleCampaign : updateCampaignList){
                if(!Approval.isLocked(singleCampaign.Id))updatedList.add(singleCampaign);
            }
            //update updateCampaignList;
            if(updatedList.size() > 0) update updatedList;
            
        }catch(exception exc){
            return 'error-$-'+exc.getMessage();
        }
        
        return 'success-$-The Campaigns has been updated successfully!';
    }
    
    @AuraEnabled
    public static String saveCampaignActivitys(List<CooP_Campaign_Activity__c> updateCampaignActivityList) {
        try{
            
            user currentUser=[select id, contactId from User where id=:userinfo.getUserId()];
            Map<id,CooP_Campaign_Activity__c> campaignActivityMapForUpdate= new map<Id,CooP_Campaign_Activity__c>();
            set<Id> campaignInApprovalSet= new set<Id>();
            map<Id,CooP_Campaign_Activity__c> camActivityInApprovalMap= new map<Id,CooP_Campaign_Activity__c>();
            List<Approval.ProcessWorkitemRequest> allRequests = new List<Approval.ProcessWorkitemRequest>();
            Map<id,Campaign> campaignsForUpdateMap= new map<id,Campaign>();
            
            
            for(CooP_Campaign_Activity__c camActivity: updateCampaignActivityList)
            {
                if(!Approval.isLocked(camActivity.Id) || 
                   (Approval.isLocked(camActivity.Id) && currentUser.contactId==null && 
                    (camActivity.Status__c=='Activity Needs Modification' || camActivity.Status__c=='Activity Approved' || camActivity.Status__c=='Activity Rejected') ))
                {
                    campaignActivityMapForUpdate.put(camActivity.Id,camActivity);
                    if(camActivity.Status__c=='Activity Needs Modification')
                    {
                        if(Approval.isLocked(camActivity.Id))
                            camActivityInApprovalMap.put(camActivity.Id,camActivity);
                        else 
                            campaignInApprovalSet.add(camActivity.Campaign__c);
                    }else if( Approval.isLocked(camActivity.Id) &&
                             (camActivity.Status__c=='Activity Approved' || camActivity.Status__c=='Activity Rejected'))
                        camActivityInApprovalMap.put(camActivity.Id,camActivity);
                }
            }
            
            for(ProcessInstanceWorkitem piwi : [SELECT  Id, 
                                                ProcessInstanceId, 
                                                ProcessInstance.TargetObjectId,
                                                ProcessInstance.Status
                                                FROM ProcessInstanceWorkitem 
                                                WHERE 
                                                ProcessInstance.Status = 'Pending' AND 
                                                (ProcessInstance.TargetObjectId IN : campaignInApprovalSet OR ProcessInstance.TargetObjectId IN : camActivityInApprovalMap.keySet()) AND
                                                ActorId =:userinfo.getUserId()])
            {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                if(campaignInApprovalSet.contains(piwi.ProcessInstance.TargetObjectId))
                {
                    req.setComments('Activity Needs Modification, recalling campaign from approval.');
                    req.setAction('Reject');
                    campaignsForUpdateMap.put(piwi.ProcessInstance.TargetObjectId,New campaign(Id=piwi.ProcessInstance.TargetObjectId, Status = 'Campaign Needs Modification'));
                }else if(camActivityInApprovalMap.containsKey(piwi.ProcessInstance.TargetObjectId))
                {
                    string caActivityStatus=camActivityInApprovalMap.get(piwi.ProcessInstance.TargetObjectId).Status__c;
                    if(caActivityStatus=='Activity Needs Modification')
                    {
                        req.setComments('Activity Needs Modification, recalling activity from approval.');
                        req.setAction('Reject');
                    } else if(caActivityStatus=='Activity Rejected')
                    {
                        req.setComments('Activity Rejected.');
                        req.setAction('Reject');
                    }else if(caActivityStatus=='Activity Approved')
                    {
                        req.setComments('Activity Approved');
                        req.setAction('Approve');
                    }
                }
                req.setWorkitemId(piwi.id);
                allRequests.add(req);
            }
            
            if(!campaignActivityMapForUpdate.isEmpty())
                update campaignActivityMapForUpdate.values();
            
            if(!allRequests.isEmpty())
            {
                Approval.ProcessResult[] processResults = null;
                processResults = Approval.process(allRequests, true);  
            }
            
            
            if(!campaignsForUpdateMap.isEmpty())
            {
                CampaignTriggerHandler.isTriggerNotActive=true;
                update campaignsForUpdateMap.values();
                
            }
        }catch(exception exc){
            //return exc.getMessage();
            return 'error-$-'+exc.getMessage(); //The Campaign Activities  has been updated successfully!';
        }
        return 'success-$-The Campaign Activities has been updated successfully!';
    }
    
    @AuraEnabled
    public static List<CooP_Campaign_Activity__c> getRejCanActivities(String campaignId) {   
        return [SELECT Id,Name FROM CooP_Campaign_Activity__c WHERE Campaign__c =:campaignId AND Status__c IN ('Activity Rejected','Activity Canceled' )];
    }
    
    @AuraEnabled
    public static String saveCampaignComments(String campaignId, String comments) {
        try{
            if(string.isNotBlank(comments) && comments!=null)
            {
                list<campaign> campaignLst=[select Retailer__c 
                                            from campaign 
                                            where ID=:campaignId
                                           ];
                if(!campaignLst.isEmpty())
                {
                    Map<Id,User> recepientsMap= new map<id,User>([select Id, contactId 
                                                                  FROM
                                                                  User
                                                                  Where ((contact.AccountId=:campaignLst[0].Retailer__c 
                                                                          AND contactId !=null
                                                                          AND profile.Name='Dealer Principle')
                                                                         OR Name='Vivek Varale') AND isActive=true]);
                    
                    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                    
                    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = comments + '\n #campaignComment ';
                    messageInput.messageSegments.add(textSegment);
                    for (Id userToMention : recepientsMap.keySet()) {
                        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                        mentionSegment.id = userToMention;
                        messageInput.messageSegments.add(mentionSegment);
                    }
                    
                    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                    input.body = messageInput;
                    input.subjectId = campaignId;
                    input.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), input);
                    return 'success-$-New campaign comments added!';
                }else{
                    return 'error-$-No valid retailer fould!'; 
                }
                
            } else{
                
                return 'error-$-No Comments are posted!';
            }
        }catch(exception exc){
            return 'error-$-'+exc.getMessage();
        }
    }
    
    @AuraEnabled
    public static string approveOrReject(String campaignId, String campaignActID, string strComment, string strAction) {
        boolean skipApproval=false;
        Try{
            if(strAction=='Approve' || strAction=='Reject'){
                ProcessInstance processInst= [SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId =:campaignId];
                ProcessInstanceWorkitem pInstanceWorkitems = [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =:processInst.Id Limit 1];
                
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(strComment);
                req.setAction(strAction); //to approve use 'Approve'
                
                // Use the ID from the newly created item to specify the item to be worked
                req.setWorkitemId(pInstanceWorkitems.Id);
                
                // Add the request for approval
                Approval.ProcessResult result =  Approval.process(req);  
                
                if(strAction=='Reject')
                {
                    campaign objCampaign=New campaign(Id=campaignId, Status = 'Campaign Needs Modification');
                    update objCampaign; 
                }
                
            }else
            {                
                list<CooP_Campaign_Activity__c> underModificaionActLst=[select id 
                                                                        from 
                                                                        CooP_Campaign_Activity__c 
                                                                        where campaign__c=:campaignId
                                                                        
                                                                        AND status__c='Activity Needs Modification'];
                campaign objCampaign= [select id, 
                                       Cumulative_Eligible_Budget__c, 
                                       Planned_spend_to_date_per_campaign__c,
                                       (select id from Campaign_activities__r
                                        Where Status__c Not IN ('Activity Canceled', 'Activity Rejected')) 
                                       From campaign
                                       where Id=:campaignId];
                if(objCampaign.Campaign_activities__r.IsEmpty() && strAction=='Comment')
                    return 'Error-$-There are no active activities found!';
                else if(objCampaign.Planned_spend_to_date_per_campaign__c>objCampaign.Cumulative_Eligible_Budget__c && strAction=='Comment')
                    return 'Error-$-Planned spend is more than eligible budget, Please adjust planned spend on activity.';
                if(!underModificaionActLst.isEmpty() && strAction=='Comment'){
                    return 'Error-$-There are pending activity needs modification.';
                }else {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments(strComment);  
                    if(strAction=='Comment')
                    {
                        
                        req.setObjectId(campaignId);
                        req.setProcessDefinitionNameOrId('Coop_Retailer_Approval_INDIA_v3');
                        
                    }else{
                        CooP_Campaign_Activity__c objCampActivity= [SELECT Id,Status__c, Has_Approval_Process__c FROM CooP_Campaign_Activity__c where Id =:campaignActID Limit 1];
                        if(!objCampActivity.Has_Approval_Process__c)
                        {
                            objCampActivity.Status__c='Activity Canceled';
                            update objCampActivity;
                            skipApproval=true;
                        }
                        else
                        {
                            req.setObjectId(campaignActID);
                            req.setProcessDefinitionNameOrId('Campaign_Activity_Cancellation_IN');
                        }
                    }
                    if(!skipApproval)
                    {
                        // Submit on behalf of a specific submitter
                        req.setSubmitterId(userinfo.getUserId()); 
                        // Submit the approval request for the account
                        Approval.ProcessResult result = Approval.process(req);
                    }
                }
                
            }
            if(string.isNotBlank(strComment) && strComment!=null)
            {
                FeedItem post = new FeedItem();
                post.ParentId = campaignId;
                post.Body = strComment+' #'+strAction+'Comment';
                post.Title= strAction+' Comment';
                insert post;
            } 
            return 'Success-$-Operation successful!';
        }
        catch(exception e){
            return 'Error-$-'+e.getMessage();
        }
    } 
    
}