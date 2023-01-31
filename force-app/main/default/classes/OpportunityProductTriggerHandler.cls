public class OpportunityProductTriggerHandler {
    
    public static Boolean ignoreMMIT= false;
    public static Boolean skipLogic = false;
    
    public void PreCreate(List<OpportunityLineItem> opportunityLineItems)
    {
        MMIT_OpportunityInfoSetter_OppLineItem_F mmitOpportunityInfoSetterFactory = new MMIT_OpportunityInfoSetter_OppLineItem_F();
        MMIT_OpportunityInfoSetter_OppLineItem mmitOpportunityInfoSetter = mmitOpportunityInfoSetterFactory.Create();
        OpportunityProductLookupSetter opportunityProductLookupSetter = new OpportunityProductLookupSetter();
        OpportunityToOrderLinker oppToOrderOnCreate = new OpportunityToOrderLinker();
        
        opportunityProductLookupSetter.SetMakeAndModel(opportunityLineItems);
        
        if(ignoreMMIT==false)
            mmitOpportunityInfoSetter.SetVehicleInfo(opportunityLineItems);
        
        if(opportunityLineItems != null && !opportunityLineItems.isEmpty()){      
          oppToOrderOnCreate.linkOrderToOpportunityOnCreate(opportunityLineItems);    
      }
        
    }
    
    /*public void ClearAssetOwner(List<OpportunityLineItem> opportunityLineItems){
OpportunityProduct_AssetManager opportunityProductAssetMgr = new OpportunityProduct_AssetManager();
opportunityProductAssetMgr.ClearAssetOwner(opportunityLineItems);
}*/
    
    public void SetAssetOwner(List<OpportunityLineItem> opportunityLineItems){
        OpportunityAssetOwnerSetter opportunityAssetOwnerSetter = new OpportunityAssetOwnerSetter();
        opportunityAssetOwnerSetter.SetAssetOwner(opportunityLineItems);
    }
    
    public void PreDelete(List<OpportunityLineItem> opportunityLineItems){
        OpportunityAssetOwnerSetter opportunityAssetOwnerSetter = new OpportunityAssetOwnerSetter();
        OpportunityCICodeClearer opportunityCICodeClearer = new OpportunityCICodeClearer();
        
        opportunityAssetOwnerSetter.ClearAssetOwner(opportunityLineItems);
        opportunityCICodeClearer.Clear(opportunityLineItems);
    }
    
    public void PreUpdate(Map<Id,OpportunityLineItem> oldItems, List<OpportunityLineItem> opportunityLineItems)
    {
        system.debug('skip is '+skipLogic);
        if(!skipLogic){
            MMIT_OpportunityInfoSetter_OppLineItem_F mmitOpportunityInfoSetterFactory = new MMIT_OpportunityInfoSetter_OppLineItem_F();
            MMIT_OpportunityInfoSetter_OppLineItem mmitOpportunityInfoSetter = mmitOpportunityInfoSetterFactory.Create();
            OpportunityToOrderLinkRemover linkRemover = new OpportunityToOrderLinkRemover();
            OpportunityToOrderLinker oppToOrder = new OpportunityToOrderLinker();
            
            linkRemover.removeLinksToOrderAndAsset(oldItems, opportunityLineItems);
            if(opportunityLineItems != null && !opportunityLineItems.isEmpty()){
                System.Debug('This is in opprod trigger '+opportunityLineItems);   
                oppToOrder.linkOrderToOpportunity(opportunityLineItems);
            }
            
            
            if(ignoreMMIT==false)
                mmitOpportunityInfoSetter.SetVehicleInfo(opportunityLineItems, new Map<Id, OpportunityLineItem>(opportunityLineItems));
        }
    }
    
    public void PostCreate(Map<Id,OpportunityLineItem> oldItems, List<OpportunityLineItem> opportunityLineItems)
    {
       // if(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_OppLineItem_Logic_Run__c) OpportunityDeferDecisionValuesUpdater.OpportunityUpdateOnPostInsert(opportunityLineItems);
        OpportunityDeferDecisionValuesUpdater.OpportunityUpdateOnPostInsert(opportunityLineItems);
        RollupAssets(opportunityLineItems);
        
        
        //CXPD-ProductOptions
        OpportunityProductOptionHandler.setMandatoryProductOptions(opportunityLineItems);
        RetailerMarginHandler.execute(opportunityLineItems);
    }
    
    public void PostUpdate(List<OpportunityLineItem> triggerNewList, Map<Id,OpportunityLineItem> triggerNewMap, List<OpportunityLineItem> triggerOldList,  Map<Id,OpportunityLineItem> triggerOldMap)
    {
       system.debug('skip is '+skipLogic);
        if(!skipLogic){
        if(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_OppLineItem_Logic_Run__c) OpportunityDeferDecisionValuesUpdater.OpportunityUpdateOnPostUpdate(triggerNewList,triggerOldMap);
        List<OpportunityLineItem> triggerFullList = new List<OpportunityLineItem>();
        triggerFullList.addAll(triggerOldList);
        triggerFullList.addAll(triggerNewList);
        RollupAssets(triggerFullList);
        }
    }
    
    public void PostDelete(List<OpportunityLineItem> oldOpportunityLineItems, Map<Id, OpportunityLineItem> oldOpportunityLineItemsMap)
    {
       if(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_OppLineItem_Logic_Run__c) OpportunityDeferDecisionValuesUpdater.OpportunityUpdateOnPostDelete(oldOpportunityLineItems);
        RollupAssets(oldOpportunityLineItems);

        OpportunityProductOptionHandler.removeProductOptionsOnDeleteOfParent(oldOpportunityLineItemsMap);
    }

    public void RollupAssets(List<OpportunityLineItem> oppLineItems)
    {
        List<Id> ids = new List<Id>();
        for (OpportunityLineItem oppLineItem : oppLineItems)
        {
            ids.add(oppLineItem.Asset__c);
        }
        Asset[] assets = [SELECT Id, (SELECT Id FROM Opportunity_Product__r) FROM Asset WHERE Id IN :ids];
        for (Asset asset : assets)
        {
            asset.Opp_Product_Count__c = asset.Opportunity_Product__r.size();
        }
        update assets;
    }
}