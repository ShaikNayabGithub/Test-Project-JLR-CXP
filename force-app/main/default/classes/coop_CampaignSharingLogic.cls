public class coop_CampaignSharingLogic {
    
    
    
    public void ShareCoopCampaignsWithRetailer(List<Campaign> newList, Map<Id, Campaign> oldMap) {
        //every time a Co-Op campaign is created share it with the retailer defined in the parent Retailer campaign
        //when a Co-Op campaign is altered, determine whether the parent campaign has been changed
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Map<String, Id> userRoleMap = new Map<String, Id>();
        List<Campaign> newCampaigns = new List<Campaign>();
        List<Campaign> childCampaigns = new List<Campaign>();
        List<String> additionalRetailers = new List<String>();
        Map<Id, String> parentCampaignToRetailerMap = new Map<Id, String>();
        Map<Id, Id> retailerToParentCampaignMap = new Map<Id, Id>();
        Map<Id,Id>  parentCampaignToRetailerIdMap = new Map<Id,Id>();
        Set<id> parentAccountList = new Set<id>();  
        Map <id,List<Campaign>> campaigntoChildCampaignMap = new Map<id,List<Campaign>>();
        Map <id,List<Account>> retailerByParent = new Map<id,List<Account>>();        
        Map<String, Group> retailerToUsersMap = new Map<String, Group>();      
        Set<Id> sharesToDelete = new Set<Id>(); 
       
        for(Campaign c : newList){
            //if coop campaign entered
            if(c.RecordTypeId == coopRecordTypeId){
                //check if new (old map is null) or parentId has changed
                if(oldMap == null || !oldMap.containsKey(c.Id) || oldMap.get(c.Id).ParentId != c.ParentId){
                    if(oldMap != null && oldMap.containsKey(c.Id)){
                        sharesToDelete.add(c.Id);
                    }
                    if(c.ParentId != null){ //this is a Co-Op Campaign with a parent
                        newCampaigns.add(c);
                        //put parent in campaign retailer map
                        parentCampaignToRetailerMap.put(c.ParentId, null);
                    }
                }
            }
            else if(c.RecordTypeId == retailerRecordTypeId){
                //this retailer plan            
                if(oldMap == null || !oldMap.containsKey(c.Id) || oldMap.get(c.Id).Retailer__c != c.Retailer__c){
                    if(oldMap != null && oldMap.containsKey(c.Id)){
                        sharesToDelete.add(c.Id);
                    }
                    if(c.Retailer__c != null){ //this is a Retailer Campaign with a Retailer
                        newCampaigns.add(c);                     
                        parentCampaignToRetailerMap.put(c.Id, null);
                        
                        
                    }
                }            
            }
        }
        
        if(!newCampaigns.isEmpty()){
            
            //need to obtain the detail of the associated retailer campaigns
            for(Campaign pc : [SELECT Id, Retailer__c,Retailer__r.record_sub_type__c , Retailer__r.Name, (Select id, recordtypeId from childcampaigns where recordtypeId=:coopRecordTypeId) FROM Campaign WHERE Id IN :parentCampaignToRetailerMap.keySet() AND Retailer__c != null]){
                String strRetailerId = (String)pc.Retailer__c;
                //if its a dealergroup add it to the parent account list
                if(pc.Retailer__c != null && pc.Retailer__r.record_sub_type__c != null && pc.Retailer__r.record_sub_type__c == 'Legal Entity (Dealer Group)'){
                    parentAccountList.add(pc.Retailer__c);
                }
                //need to put them in map for SOQL
                parentCampaignToRetailerMap.put(pc.Id, pc.Retailer__r.Name + ' Partner Manager');
                retailerToParentCampaignMap.put(pc.retailer__c,pc.Id);
                parentCampaignToRetailerIdMap.put(pc.Id,pc.Retailer__r.id);
                if(pc.childCampaigns != null && !pc.childCampaigns.isEmpty()){
                    //Need to map parent to children if they have them for sharing
                    List<Campaign> children = pc.childCampaigns;
                    campaigntoChildCampaignMap.put(pc.id,children);
                }
            }           
            
           
            //group of children accounts when associating with retailer campaign with dealergroup
            if(parentAccountList.size()>0){               
                List<Account> accsInGroup = [Select id, name, parentid from account where parentId in:parentAccountList];
                
                retailerByParent = SObjectUtilities.MapByIdField(accsInGroup, Schema.Account.ParentId.getDescribe());
                
                For(Account accChild : accsInGroup)
                {
                    additionalRetailers.add(accChild.Name+ ' Partner Manager');                  
                }    
                
            }
            
            for(UserRole ur : [SELECT Id, Name FROM UserRole WHERE Name IN :parentCampaignToRetailerMap.values() or Name IN:additionalRetailers]){
                System.debug('User rOLES '+ur);
                userRoleMap.put(ur.Name, ur.Id);
            }
            
            for(Group g : [SELECT Id, RelatedId, Related.Name FROM Group WHERE RelatedId IN :userRoleMap.values() AND Type = 'Role']){
                retailerToUsersMap.put(g.RelatedId, g);
                
            }
        }
        List<CampaignShare> campaignSharing = new List<CampaignShare>();
        
        for(Campaign c : newCampaigns){
            String sharingMode;
            String strRetailerName;
            String userRoleName;
            List<Id> userRoleIds = new List<Id>();
            Id userRoleId;
            if(parentCampaignToRetailerMap.containsKey(c.ParentId)){
                userRoleName = parentCampaignToRetailerMap.get(c.ParentId);
                sharingMode = 'Edit';
                
            }
            if(parentCampaignToRetailerMap.containsKey(c.Id)){
                userRoleName = parentCampaignToRetailerMap.get(c.Id);
                sharingMode = 'Read';
                
            }
            
            
            if(retailerByParent.containsKey(c.Retailer__c) ||  parentCampaignToRetailerIdMap.ContainsKey(c.ParentId)){
                id retailerId;
                if(retailerByParent.containsKey(c.Retailer__c)){
                    retailerId =c.Retailer__c;
                }else if( parentCampaignToRetailerIdMap.ContainsKey(c.ParentId)){
                    retailerId = parentCampaignToRetailerIdMap.get(c.ParentId);
                }            
                
                List<Account> accs = retailerByParent.get(retailerId);
                if(accs!= null && !accs.isEmpty()){
                    for(Account acc : accs){
                        
                        if(userRoleMap.containsKey(acc.name+' Partner Manager')){
                            
                            Id userrole = userRoleMap.get(acc.name+' Partner Manager');
                            
                            if(sharingMode != null && userrole != null && retailerToUsersMap.containsKey(userrole)){
                                CampaignShare cs = new CampaignShare(CampaignId=c.Id, RowCause='Manual', UserOrGroupId=retailerToUsersMap.get(userrole).Id);
                                cs.CampaignAccessLevel = sharingMode;                           
                                campaignSharing.add(cs);
                                
                            }
                            if(sharingMode != null && userrole != null && retailerToUsersMap.containsKey(userrole) && campaigntoChildCampaignMap.containsKey(c.Id) ){
                                List<Campaign> camps = campaigntoChildCampaignMap.get(c.id);
                                for(Campaign ca : camps){
                                    sharesToDelete.add(ca.id);
                                    CampaignShare cs = new CampaignShare(CampaignId=ca.Id, RowCause='Manual', UserOrGroupId=retailerToUsersMap.get(userrole).Id);
                                    cs.CampaignAccessLevel = 'Edit';                           
                                    campaignSharing.add(cs);
                                    
                                }
                                
                            }
                        }
                    }
                }
            }
            
            if(userRoleMap.containsKey(userRoleName)){
                userRoleId = userRoleMap.get(userRoleName);
            }
            
            if(sharingMode != null && userRoleId != null && retailerToUsersMap.containsKey(userRoleId)){
                CampaignShare cs = new CampaignShare(CampaignId=c.Id, RowCause='Manual', UserOrGroupId=retailerToUsersMap.get(userRoleId).Id);
                cs.CampaignAccessLevel = sharingMode;
                campaignSharing.add(cs);
                
            }
            if(campaigntoChildCampaignMap.containsKey(c.Id)&& retailerToUsersMap.containsKey(userRoleId)){
                List<Campaign> camps = campaigntoChildCampaignMap.get(c.id);
                for(Campaign ca : camps){
                    sharesToDelete.add(ca.id);
                    CampaignShare cs = new CampaignShare(CampaignId=ca.Id, RowCause='Manual', UserOrGroupId=retailerToUsersMap.get(userRoleId).Id);
                    cs.CampaignAccessLevel = 'Edit';                           
                    campaignSharing.add(cs);
                    
                }
                
            }
            
        }
        //need to delete existing record shares if the Campaign has been updated
        if(!sharesToDelete.isEmpty()){
            List<CampaignShare> existingShares = [SELECT Id FROM CampaignShare WHERE CampaignId IN :sharesToDelete AND RowCause='Manual' AND UserOrGroup.Name = null AND UserOrGroup.Type = 'Queue'];
            delete existingShares;
        }
        system.debug('Campaign sharing '+campaignSharing);
        if(!campaignSharing.isEmpty()){
            insert campaignSharing;
        }
    }
    
    
    
}