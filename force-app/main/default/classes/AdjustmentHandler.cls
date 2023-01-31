public class AdjustmentHandler {
    public static void PreCreate(List<COOP_Adjustment__c> triggerNewList, Map<Id,COOP_Adjustment__c> triggerNewMap){
    }
    public static void PostCreate(List<COOP_Adjustment__c> triggerNewList, Map<Id,COOP_Adjustment__c> triggerNewMap){
        List<Id> campaignIdList = new List<Id>();
        for(COOP_Adjustment__c adj : triggerNewList){
            campaignIdList.add(adj.Campaign__c);
        }
        if(campaignIdList.size() > 0) campaignAdjustmentRollup(campaignIdList);
        
        notifyOnAdjestmentCreation(triggerNewMap.keyset());
    }
    public static void PreUpdate(List<COOP_Adjustment__c> triggerNewList, Map<Id,COOP_Adjustment__c> triggerNewMap, List<COOP_Adjustment__c> triggerOldList, Map<Id,COOP_Adjustment__c> triggerOldMap){
    }
    public static void PostUpdate(List<COOP_Adjustment__c> triggerNewList, Map<Id,COOP_Adjustment__c> triggerNewMap, List<COOP_Adjustment__c> triggerOldList, Map<Id,COOP_Adjustment__c> triggerOldMap){
        List<Id> campaignIdList = new List<Id>();
        for(COOP_Adjustment__c adj : triggerNewList){
            if(adj.Campaign__c != triggerOldMap.get(adj.Id).Campaign__c) {
                campaignIdList.add(adj.Campaign__c);
                campaignIdList.add(triggerOldMap.get(adj.Id).Campaign__c);
            }
            if(adj.Amount__c != triggerOldMap.get(adj.Id).Amount__c){
                campaignIdList.add(adj.Campaign__c);
            }
        }
        if(campaignIdList.size() > 0) campaignAdjustmentRollup(campaignIdList);
    }
    
    public static void PostDelete(List<COOP_Adjustment__c> triggerOldList, Map<Id,COOP_Adjustment__c> triggerOldMap){
        List<Id> campaignIdList = new List<Id>();
        for(COOP_Adjustment__c adj : triggerOldList){
            campaignIdList.add(adj.Campaign__c);
        }
        if(campaignIdList.size() > 0) campaignAdjustmentRollup(campaignIdList);
    }    
    public static void PostUnDelete(List<COOP_Adjustment__c> triggerNewList, Map<Id,COOP_Adjustment__c> triggerOldMap){
        List<Id> campaignIdList = new List<Id>();
        for(COOP_Adjustment__c adj : triggerNewList){
            campaignIdList.add(adj.Campaign__c);
        }
        if(campaignIdList.size() > 0) campaignAdjustmentRollup(campaignIdList);
    }
    
    public static void campaignAdjustmentRollup(List<Id> campaignIdList){  
        map<Id,Campaign> campaignUpdateMap= new map<Id,Campaign>();
        
        for(COOP_Adjustment__c adj: [SELECT Id,Campaign__c,Amount__c FROM COOP_Adjustment__c WHERE Campaign__c IN :campaignIdList]){
            Campaign campObj= new Campaign(COOP_Adjustment_Amount__c=0);
            if(campaignUpdateMap.containsKey(adj.Campaign__c)){
                campObj=campaignUpdateMap.get(adj.Campaign__c); 
                campObj.COOP_Adjustment_Amount__c += adj.Amount__c != null ? adj.Amount__c : 0;
            }else{
                campObj.Id=adj.Campaign__c;
                campObj.COOP_Adjustment_Amount__c += adj.Amount__c != null ? adj.Amount__c : 0;
            }
            campaignUpdateMap.put(campObj.Id, campObj);
        }
        if(!campaignUpdateMap.isEmpty())
            update campaignUpdateMap.values();
    }
    
    @future
    public static void notifyOnAdjestmentCreation(set<Id> adJestMentId)
    {
        map<id,Id> adjestmentRetailerMap= new map<Id,Id>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        list<COOP_Adjustment__c> adjestMentLst=[select Name, 
                                                Id,
                                                Campaign__c, 
                                                Amount__c,
                                                CurrencyIsoCode,
                                                Adjustment_Comment__c, 
                                                Campaign__r.Retailer__c, 
                                                Campaign__r.Name
                                                from COOP_Adjustment__c 
                                                where ID IN:adJestMentId
                                               ];
        for(COOP_Adjustment__c adjestMents:adjestMentLst)
        {
            adjestmentRetailerMap.put(adjestMents.Id, adjestMents.Campaign__r.Retailer__c);                                    
        }
        
        
        if(!adjestmentRetailerMap.isEmpty())
        {
            system.debug('campaignLst'+adjestmentRetailerMap);
            map<id,set<Id>> userAccountIdMap= new map<id,set<Id>>();
            for(User recepients:[select  Id, contact.AccountId 
                                 FROM
                                 User
                                 Where contact.AccountId IN:adjestmentRetailerMap.values() 
                                 AND contactId !=null
                                 AND profile.Name='Dealer Principle'] )
            {
                set<id> tempReciptSet= new set<id>();
                if(userAccountIdMap.containsKey(recepients.contact.AccountId))
                    tempReciptSet.addAll(userAccountIdMap.get(recepients.contact.AccountId));
                tempReciptSet.add(recepients.Id);
                userAccountIdMap.put(recepients.contact.AccountId, tempReciptSet);
            }
            
            for(COOP_Adjustment__c adjestMents:adjestMentLst){
                if(userAccountIdMap.containsKey(adjestMents.Campaign__r.Retailer__c))
                {
                    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                    
                    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text =  'New adjustment record created for campaign:'+adjestMents.Campaign__r.Name+'. Adjusted amount: '+adjestMents.Amount__c+adjestMents.CurrencyIsoCode;
                    if(adjestMents.Adjustment_Comment__c !=null && string.isNotBlank(adjestMents.Adjustment_Comment__c))
                        textSegment.text+='\n More details: '+adjestMents.Adjustment_Comment__c;
                    textSegment.text+='\n #NewAdjustment ';
                    messageInput.messageSegments.add(textSegment);
                    for (Id userToMention : userAccountIdMap.get(adjestMents.Campaign__r.Retailer__c)) {
                        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                        mentionSegment.id = userToMention;
                        messageInput.messageSegments.add(mentionSegment);
                    }
                    
                    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                    input.body = messageInput;
                    input.subjectId = adjestMents.Id;
                    input.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                    batchInputs.add(new ConnectApi.BatchInput(input)); 
                }
            }
        }
        
        if(!batchInputs.isEmpty() && !test.isRunningTest())
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs); 
    }
    
}