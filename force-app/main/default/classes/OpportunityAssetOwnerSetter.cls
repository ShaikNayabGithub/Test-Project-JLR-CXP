public without sharing class OpportunityAssetOwnerSetter {
    //CXPD-2448 changes begin
    public static User loggedInUser = getUserInformation(UserInfo.getUserId());
    public static User getUserInformation(Id userId) {
        if(loggedInUser == null || loggedInUser.Id != userId) {
            loggedInUser = [SELECT Id, Market__c, Country_ISO_Code__c FROM User WHERE Id = :userId];
        }
        return loggedInUser;
    }
    List<String> stages = new List<String>{'Take Order','Order Taken','Order','Handover','Handover & RDA','Won'};
    List<String> countryCodesToExclude = system.label.RDAHandoverCountryCodes.split(',');
    //CXPD-2448 changes end
    
    public void SetAssetOwner(List<OpportunityLineItem> opportunityLineItems){
        //for each OpportunityLineItem where the Status is Fulfilled From Stock and the Asset is set
        //change the Asset Status to 'Owned' and the AccoundId to the Opportunity AccountId
        List<OpportunityLineItem> affected = new List<OpportunityLineItem>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        system.debug('calling');
        for(OpportunityLineItem oli : opportunityLineItems){
            system.debug('inside '+opportunityLineItems);
            if(String.IsNotBlank(oli.Status__c) && oli.Status__c == 'Fulfilled From Stock' && oli.Asset__c != null){
                affected.add(oli);
                oppIds.add(oli.OpportunityId);
                assetIds.add(oli.Asset__c);
            }
        }
        if(oppIds.size() > 0 && assetIds.size() > 0){
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, AccountId, Account.Country_ISO_Code__c, StageName FROM Opportunity WHERE Id IN :oppIds]); // Updated query as part of CXPDA-949
            Map<Id, Asset> assetMap =  new Map<Id, Asset>([SELECT Id, AccountId, Status, Historic_Status__c FROM Asset WHERE Id IN :assetIds]);
            for(OpportunityLineItem oli : affected){
                if(assetMap.containsKey(oli.Asset__c) && opportunityMap.containsKey(oli.OpportunityId) && opportunityMap.get(oli.OpportunityId).Account.Country_ISO_Code__c != 'AU'){  // Added New Condition as part of CXPDA-949
                    //CXPD-2448
                    if(assetMap.get(oli.Asset__c).AccountId!=opportunityMap.get(oli.OpportunityId).AccountId && stages.contains(opportunityMap.get(oli.OpportunityId).StageName) && !countryCodesToExclude.contains(loggedInUser.Country_ISO_Code__c)) assetMap.get(oli.Asset__c).AccountId = opportunityMap.get(oli.OpportunityId).AccountId;
                    assetMap.get(oli.Asset__c).Historic_Status__c = assetMap.get(oli.Asset__c).Status;
                    assetMap.get(oli.Asset__c).Status = 'Owned';
                }
            }
            system.debug('assetMap'+assetMap);
            update assetMap.values();
        }
    }
    
    public void ClearAssetOwner(List<OpportunityLineItem> opportunityLineItems){
        Set<Id> assetIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Id> mapOlToOppIds = new Map<Id,Id>();
        Map<Id,Id> mapOlToAssetIds = new Map<Id,Id>();
        for(OpportunityLineItem oli : opportunityLineItems){
            if(oli.Asset__c != null){
                mapOlToAssetIds.put(oli.Id,oli.Asset__c);
                mapOlToAssetIds.put(oli.Id,oli.OpportunityId);
                assetIds.add(oli.Asset__c);
                oppIds.add(oli.OpportunityId);
            }
        }
        
        Map<Id, Asset> assMap =  New Map<Id,Asset>([SELECT Id, AccountId, Account.Owner.Contact.AccountId, Previous_Owner__c, Status, Historic_Status__c FROM Asset WHERE Id IN :assetIds]);
        Map<Id, Opportunity> oppMap =  New Map<Id,Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds ]);
        List<Asset> assetsToChange = New List<Asset>();
        for(OpportunityLineItem oli : opportunityLineItems){
            if( oli.Asset__c != null &&  assMap.keyset().contains(oli.Asset__c) && oppMap.keyset().contains(oli.OpportunityId)){
                Asset asset1 = assMap.get(oli.Asset__c);
               system.debug('HERE Asset   '+asset1 );
                Opportunity opp = oppMap.get(oli.OpportunityId);
                if(opp.AccountId == asset1.AccountId){
                    //CXPD-2448
                    if(asset1.Account.Owner.Contact.AccountId!=NULL){
                        asset1.AccountId = asset1.Account.Owner.Contact.AccountId;
                    }else if(asset1.Previous_Owner__c!=NULL){
                        asset1.AccountId = (Id)asset1.Previous_Owner__c;
                    }
                    /*if(asset1.Previous_Owner__c!=NULL) {
                        asset1.AccountId = (Id)asset1.Previous_Owner__c;
                    }else{
                        asset1.AccountId = asset1.Account.Owner.Contact.AccountId;
                    }*/
                    if(asset1.Historic_Status__c != null){
                         asset1.Status = asset1.Historic_Status__c;
                    }                   
                    assetsToChange.Add(asset1);
                }
            }
            
        }
        
        if(assetsToChange != null && assetsToChange.Size() > 0){
              update assetsToChange;
        }
      
     
    }
    
}