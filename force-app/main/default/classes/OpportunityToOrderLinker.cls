public class OpportunityToOrderLinker {
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
    
    //code used on pre create, sets has vin field to 1 
    public void linkOrderToOpportunityOnCreate(List<OpportunityLineItem> itemList)
    {
        for(OpportunityLineItem oliAsset :itemList)
        {    
            if(oliAsset.asset__c!=null)
            {
                oliAsset.has_vin__c=1;
            }
        }
    }
    
    
    public void linkOrderToOpportunity(List<OpportunityLineItem> itemList)
    {
        List<string> orderNumbers = new List<string>();
        List<Order> ordersToUpdate = new List<Order>();
        List<Asset> assetsToUpdate = new List<Asset>();
        List<Id> oppIds = new List<Id>();
        Set<Id> updatingAssetIds = new Set<Id>();        
        Set<Id>assetsIds= new Set<id>();
        Set<String> registrationNumbers=new Set<String>();
        Set<String> ordNumbers=new Set<String>();
        List<Asset> listAssets;
        List<Asset> listAssetsFromRegNumber;
        List<Asset> listAssetsFromOrdNumber;
        Map<Id,Asset> mapAssets=new Map<Id,Asset>();
        Asset assetWithOrdernumber=new asset();
        
        for(OpportunityLineItem itemOp:itemList)
        {    
            
            if((itemOp.Vista_Order_Number__c != null && itemOp.Vista_Order_Number__c !='')||itemOp.licence_plate__c!=null||itemOp.Asset__c!=null){
                oppIds.add(itemOp.OpportunityId);
            }
            system.debug('---- ' + json.serializePretty(itemOp));
            if(itemOp.asset__c!=null)
                assetsIds.add(itemOp.asset__c);
            else
                if(itemOp.licence_plate__c!=null && itemop.licence_plate__c!='')
                registrationNumbers.add(itemOp.licence_plate__c);
            else
                if(itemOp.vista_order_number__c!=null && itemOp.vista_order_number__c!='')
                ordNumbers.add(itemOp.Vista_Order_Number__c);        
        }
        
        List<Opportunity> oppList = new List<Opportunity>();//[SELECT AccountId, OwnerId FROM Opportunity WHERE Id In :oppIds];
        Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>([SELECT Id, StageName, Country_ISO_Code__c, AccountId,Purchase_Type__c, Account.Country_ISO_Code__c, OwnerId FROM Opportunity WHERE Id In :oppIds]); // updated query as part of CXPDA-949
        
        if(!oppMap.isEmpty()){           
            oppList.addAll(oppMap.values()); 
        }

        if(!assetsIds.isEmpty()!=null)
            listAssets=[select id,Order_Number__c,Registration_Number__c, AccountId from asset where id in:assetsIds];
        
        if(!registrationNumbers.isEmpty())    
            listAssetsFromRegNumber=[select id,Order_Number__c,Registration_Number__c, AccountId from asset where registration_number__c in:registrationNumbers];
        
        if(!ordNumbers.isEmpty())    
            listAssetsFromOrdNumber=[select id,Order_Number__c,Registration_Number__c, AccountId from asset where Order_Number__c in:ordNumbers];  
        
        //Populate mapassets with assets from reg number or vin
        if(listAssets!=null)
            mapAssets.putall(listAssets);
        if(listAssetsFromRegNumber!=null) 
            mapAssets.putall(listAssetsFromRegNumber);
        if(listAssetsFromOrdNumber!=null)
            mapAssets.putall(listAssetsFromOrdNumber);
        
        for(OpportunityLineItem item : itemList)
        {
            
            if(mapAssets.isEmpty() && (item.Licence_Plate__c!=NULL && item.licence_plate__c!=''))
            {
                item.Licence_Plate__c.addError('No records found: You don\'t have permission to see any of the records or There are no records of this type.');
                //CHange to Custom Label
            }
            
            if(item.Vista_Order_Number__c != null && item.Vista_Order_Number__c !='')
            {
                // oppIds.add(item.OpportunityId); //move earlier
                orderNumbers.add(item.Vista_Order_Number__c);
                
            }   
            else{
                if(item.licence_plate__c!=null)
                {
                    //  oppIds.add(item.OpportunityId); //move earlier
                    for(Asset assetFromMap:mapAssets.values()){ 
                        if(assetFromMap!=null)
                            if(assetFromMap.registration_Number__c==item.licence_plate__c)
                            assetWithOrdernumber=assetFromMap;        
                        
                    }
                    
                }
                else
                    if(item.Asset__c!=null)
                    
                    // oppIds.add(item.OpportunityId); //move earlier
                    
                    if(mapAssets.get(item.asset__c)!=null){
                        assetWithOrdernumber=mapAssets.get(item.asset__c);
                        
                    }
            }
            if(assetWithOrdernumber.order_number__c!=null && assetWithOrdernumber.order_number__c!=''&& assetWithOrdernumber.order_number__c!=' '&& assetWithOrdernumber.order_number__c!='-' && assetWithOrdernumber.order_number__c!='.')
            {   
                
                //oppIds.add(item.OpportunityId);
                Opportunity opp = oppMap.get(item.OpportunityId);
                //AUS Process linking multiple opportunities
                      if(opp != null && (opp.Purchase_Type__c == null || (opp.Purchase_Type__c != null && opp.Purchase_Type__c  != 'Used Vehicle')) && opp.Account.Country_ISO_Code__c != 'AU'){
                    orderNumbers.add(assetWithOrdernumber.order_number__c); //Dont't ADD HERE if opp for pre
                    item.Vista_Order_Number__c=assetWithOrdernumber.order_number__c; //DON't SET HERE if opp right stage
                }
                
                item.licence_plate__c=assetWithOrdernumber.registration_number__c;
                item.asset__c=assetWithOrdernumber.id;
                item.has_vin__c=1;
            } 
            
        }
        
        List<Order> orderList = [SELECT Id, Vista_Order_Number__c FROM Order WHERE Vista_Order_Number__c In :orderNumbers];
        
        
        List<Asset> assetList = [SELECT Order_Number__c,registration_number__c, AccountId FROM Asset WHERE Order_Number__c In : orderNumbers];
        Map<string, List<Asset>> assetsMappedToOrderNumbers = new Map<string, List<Asset>>();
        
        for(Asset oldAsset : assetList)
        {
            if(!assetsMappedToOrderNumbers.containsKey(oldAsset.Order_Number__c))
            {
                assetsMappedToOrderNumbers.put(oldAsset.Order_Number__c, new List<Asset> {oldAsset});
            }
            else
            {            
                assetsMappedToOrderNumbers.get(oldAsset.Order_Number__c).add(oldAsset);
            }
        }
        
        for(OpportunityLineItem item : itemList)
        {
            
            //if(orderList.isEmpty() && item.Vista_Order_Number__c!=null && item.Vista_Order_Number__c!='')
            //item.Vista_Order_Number__c.addError('No records found: You don\'t have permission to see any of the records or There are no records of this type.');
            
            
            //1)If an oppProduct doesnt have a vista order number
            //2)If there is a vista order number that is related to an asset but the order doesnt exist in CXP.
            
            if(item.Vista_Order_Number__c == null || item.Vista_Order_Number__c ==''
               ||(item.vista_order_number__c!=null && item.vista_order_number__c!='' && (orderList==null || orderList.isEmpty()==true)))
            {
                asset updateAsset;
                
                if(item.asset__c!=null)
                    updateAsset= mapAssets.get(item.asset__c);
                else
                    if(item.licence_plate__c!=null && item.licence_plate__c!='')    
                    updateAsset= getAssetFromLicencePlate(mapAssets,item.licence_plate__c);  
                else
                    if(item.vista_order_number__c!=null && item.vista_order_number__c!='')  
                    updateAsset=getAssetFromVistaOrderNumber(mapAssets,item.vista_order_number__c);
                
                if(updateAsset!=null){
                    item.licence_plate__c= updateAsset.registration_number__c;
                    item.asset__c=updateAsset.id;
                    item.has_vin__c=1;
                }
                else
                    item.has_vin__c=0;
                
                if(updateasset!=null)
                    for(Opportunity opp : oppList)
                {
                    if(opp.Id == item.OpportunityId && opp.Account.Country_ISO_Code__c != 'AU') // Added New Condition as part of CXPDA-949
                    {
                        
                        if(!updatingAssetIds.contains(updateAsset.Id))
                        {
                            //CXPD-2448
                            if(updateAsset.AccountId!=opp.AccountId && stages.contains(opp.StageName) && !countryCodesToExclude.contains(loggedInUser.Country_ISO_Code__c)) updateAsset.AccountId = opp.AccountId;
                            System.debug('updateAsset.AccountId: '+updateAsset.AccountId);
                            //else updateAsset.AccountId = opp.AccountId;
                            assetsToUpdate.add(updateAsset);
                            updatingAssetIds.add(updateAsset.Id);
                        }
                    }
                    
                }
            }         
            
        }
        
        for(Order updateOrder : orderList)
        {
            for(OpportunityLineItem item : itemList)
            {
                
                if(item.vista_order_number__c !='' && item.Vista_Order_Number__c != null && item.Vista_Order_Number__c == updateOrder.Vista_Order_Number__c)
                {
                    
                    updateOrder.OpportunityId = item.OpportunityId;
                    for(Opportunity opp : oppList)
                    {
                        if(opp.Id == item.OpportunityId)
                        {
                            updateOrder.AccountId = opp.AccountId;
                            updateOrder.OwnerId = opp.OwnerId;
                        }
                        if(assetsMappedToOrderNumbers.get(updateOrder.Vista_Order_Number__c) != null)
                        {
                            for(Asset updateAsset : assetsMappedToOrderNumbers.get(updateOrder.Vista_Order_Number__c))
                            {
                                
                                item.Vista_Order_Number__c=updateAsset.order_number__c;
                                item.licence_plate__c=updateAsset.registration_number__c;
                                item.asset__c=updateAsset.id;
                                item.has_vin__c=1;
                                
                                if(!updatingAssetIds.contains(updateAsset.Id) && opp.Id == item.OpportunityId && opp.Account.Country_ISO_Code__c != 'AU')  // Added New Condition as part of CXPDA-949
                                {
                                    //CXPD-2448
                                    if(updateAsset.AccountId!=opp.AccountId && stages.contains(opp.StageName) && !countryCodesToExclude.contains(loggedInUser.Country_ISO_Code__c)) updateAsset.AccountId = opp.AccountId;
                                    //else updateAsset.AccountId = opp.AccountId;
                                    assetsToUpdate.add(updateAsset);
                                    updatingAssetIds.add(updateAsset.Id);
                                }
                                
                            }
                        }
                        
                    }
                    
                    ordersToUpdate.add(updateOrder);
                }
            }
        }
        
        
        SavePoint sPoint =  Database.setSavepoint();
        try
        {
            if(!ordersToUpdate.isEmpty())
                update ordersToUpdate;
            
            if(!assetsToUpdate.isEmpty())
            update assetsToUpdate;
        }
        catch(System.DmlException ex)
        {
            if(ex.getMessage().contains('You can\'t edit Account Name'))
            {
                Database.rollback(sPoint);
                itemList[0].addError('VISTA Order Number already exists on an active order.');
            }
            else
            {
                throw ex;
            }
            
        }
        
    }
    
    private Asset getAssetFromLicencePlate(Map<Id,asset> mapAssets,String licencePlate){
        
        for(asset assetFromMap:mapAssets.values())
            if(assetFromMap.registration_number__c==licencePlate)
            return assetFromMap;    
        
        return null;    
    }
    
    private Asset getAssetFromVistaOrderNumber(Map<Id,asset> mapAssets,String vistaordernumber){
        
        for(asset assetFromMap:mapAssets.values())
            if(assetFromMap.Order_Number__c==vistaordernumber)
            return assetFromMap;    
        
        return null;    
    }
    
    
}