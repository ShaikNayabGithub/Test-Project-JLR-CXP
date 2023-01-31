public class OpportunityToOrderLinkRemover {

    List<string> vistaNumbers;
    List<String> vinNumbers;
    List<String> licenseNumbers;
    
    public void removeLinksToOrderAndAsset(Map<Id, OpportunityLineItem> oldProducts, List<OpportunityLineItem> newProducts)
    {
        List<Asset> assetsToUpdate  = new List<Asset>();
        List<Order> ordersToUpdate = new List<Order>();
        List<OpportunityLineItem> itemsToRemove = GetProductsWhereOrderNumberRemoved(oldProducts, newPRoducts);
        if(!itemsToRemove.isEmpty())
        {
            Map<Id, Opportunity> relatedOpps = getRelatedOpportunities(itemsToRemove);
            Map<Id,Contact> usersWithRetailers =  GetRetailersFromOpportunityOwner(itemsToRemove, relatedOpps);
            Map<string, Order> associatedOrders = getAssociatedOrders(itemsToRemove);
            Map<string, Asset> associatedAssets = getAssociatedAssets(itemsToRemove);
            DeleteAssetRoles(associatedAssets.values());
            
            Asset oppAsset;
            for(OpportunityLineItem oldItem : itemsToRemove)
            {
                Order oppOrder = associatedORders.get(oldItem.Vista_Order_Number__c);
                
                if(!vistaNumbers.isEmpty())
                    oppAsset= associatedAssets.get(oldItem.Vista_Order_Number__c);
                else
                if(!vinNumbers.isEmpty())
                    oppAsset= associatedAssets.get(oldItem.asset__c);
                else
                if(!licenseNumbers.isEmpty())        
                    oppAsset= associatedAssets.get(oldItem.licence_plate__c);
                    
                Opportunity relatedOpp = relatedOpps.get(oldItem.OpportunityId);
                if(oppOrder != null)
                {
                    oppOrder.OpportunityId = null;
                }
                Contact oppOwner;
                if(relatedOpp != null)
                {
                    oppOwner = usersWithRetailers.get(relatedOpp.OwnerID);
                }
                if(oppOwner != null && oppOwner.Id != null && oppOwner.AccountID != null)
                {
                    if(oppOrder != null)
                    {
                        oppOrder.AccountId = oppOwner.AccountID;
                        
                    }
                    
                    if(oppAsset != null)
                    {
                        oppAsset.AccountId = oppOwner.AccountID;
                        assetsToUpdate.add(oppAsset);
                    }
                }
                if(oppOrder != null)
                {
                    ordersToUpdate.add(oppOrder);
                }
            }
            update assetsToUpdate;
            update ordersToUpdate;
    
        }
    }
    
    public void DeleteAssetRoles(List<Asset> oldAssets)
    {
        List<Role__c> rolesToDelete = new List<Role__c>();
        List<Id> assetIds = new List<Id>();
        for(Asset oldAsset : oldAssets)
        {
            assetIds.add(oldAsset.Id);
        }
        List<Role__c> existingRoles = [SELECT Id, Account__c, Vehicle__c, Role__c FROM Role__C WHERE Vehicle__c In: assetIds];
        for(Asset oldAsset : oldAssets)
        {
            for(Role__c oldRole : existingRoles)
            {
                if(oldRole.Account__c == oldAsset.AccountId && oldRole.Vehicle__c == oldAsset.Id && oldRole.Role__c == 'Current Owner')
                {
                    rolesToDelete.add(oldRole);
                }
            }
        }
        delete rolesToDelete;
    }
    
    public List<OpportunityLineItem> GetProductsWhereOrderNumberRemoved(Map<Id, OpportunityLineItem> oldProducts, List<OpportunityLineItem> newProducts)
    {
        List<OpportunityLineItem> itemsThatChanged = new List<OpportunityLineItem>();
        
        for(OpportunityLineItem newItem: newProducts)
        {
            OpportunityLineItem oldItem = oldProducts.get(newItem.Id);
            
            if(oldItem.Vista_Order_Number__c != null &&  oldItem.Vista_Order_Number__c != newItem.Vista_Order_Number__c)
            {
               
                itemsThatChanged.add(oldItem);
                
            }
             else if (oldItem.asset__c!= null &&  oldItem.asset__c!= newItem.asset__c)
            {
                
                 itemsThatChanged.add(oldItem);
            
            }
             else if (oldItem.licence_plate__c!= null &&  oldItem.licence_plate__c!= newItem.licence_plate__c)
            {
                
                 itemsThatChanged.add(oldItem);
            
            }
            
            if(oldItem.licence_plate__c!= null &&  oldItem.licence_plate__c!= newItem.licence_plate__c&& newItem.licence_Plate__c==null)
            {
            
                newItem.asset__c=null;
                newItem.Vista_Order_Number__c='';
            }
            else
            if(oldItem.asset__c!= null &&  oldItem.asset__c!= newItem.asset__c&& newItem.asset__c==null)
            {
            
                newItem.licence_plate__c='';
                newItem.Vista_Order_Number__c='';
            }
            else
            if(oldItem.Vista_Order_Number__c != null &&  oldItem.Vista_Order_Number__c != newItem.Vista_Order_Number__c && newItem.Vista_Order_Number__c ==null)
            {
            
                newItem.licence_plate__c='';
                newItem.asset__c=null;
            }
        
                      
        }
        return itemsThatChanged;
    }
    
    public Map<Id, Opportunity> getRelatedOpportunities(List<OpportunityLineItem> oldItems)
    {
        List<Id> oppIDs = new List<ID>();
        for(OpportunityLineItem oldItem : oldItems)
        {
            Id oppId = oldItem.OpportunityId;
            oppIds.add(oppId);
        }
        List<Opportunity> oppList = [SELECT OwnerId FROM Opportunity WHERE Id In: oppIds];
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(oppList);
        return oppMap;
    }
    
    public Map<Id, Contact> GetRetailersFromOpportunityOwner(List<OpportunityLineItem> oldItems, Map<Id, Opportunity> oppMap)
    {
        List<Id> oppIDs = new List<ID>();
        List<Id> OwnerIDs = new List<Id>();
        List<Id> contactIds = new List<ID>();
        for(Opportunity opp : oppMap.values())
        {
            OwnerIds.add(opp.OwnerId);
        }
        List<User> userList  = [SELECT ContactId, Contact.AccountId, UserType FROM User WHERE Id In: OwnerIds];
        for(User usr : userList)
        {
            contactIds.add(usr.ContactId);
        }
        List<Contact> contactList = [SELECT AccountId FROM Contact WHERE Id In: contactIds];
        Map<Id, User> userMap = new Map<Id, User>(userList);
        Map<Id, Contact> contactMap = getContactMapFromContactsAndUsers(userList, contactList);
        return contactMap;
    }
    
    public Map<Id, Contact> getContactMapFromContactsAndUsers(List<User> userList, List<Contact> contactList)
    {
        Map<Id, Contact> contactMap  = new Map<Id, Contact>();
        for(User usr : userList)
        {
            for(Contact con : contactList)
            {
                if(con.Id == usr.ContactId)
                {
                    contactMap.put(usr.Id, con);
                }
            }
        }
        
        return contactMap;
    }
    
    public List<string> getVistaOrderNumbers(List<OpportunityLineItem> oldItems)
    {
       
        List<string> vistaNumbers = new List<string>();
        for(OpportunityLineItem oldItem : oldItems)
        {
            if(oldItem.Vista_Order_Number__c!=null && oldItem.Vista_Order_Number__c!='')
                vistaNumbers.add(oldItem.Vista_Order_Number__c);
        }
        
        return vistaNumbers;
    }
    
    public List<string> getVinNumbers(List<OpportunityLineItem> oldItems)
    {
       
        List<string> vinNumbers = new List<string>();
        for(OpportunityLineItem oldItem : oldItems)
        {
            if(oldItem.asset__c!=null)
                vinNumbers.add(oldItem.asset__c);
        }
        
        return vinNumbers;
    }
    
     public List<string> getLicencenumbers(List<OpportunityLineItem> oldItems)
    {
       
        List<string> licenceNumbers = new List<string>();
        for(OpportunityLineItem oldItem : oldItems)
        {
            if(oldItem.licence_plate__c!=null && olditem.licence_plate__c!='')
                licenceNumbers.add(oldItem.licence_plate__c);
        }
        
        return licenceNumbers ;
    }
    
    
    public Map<string, Order> getAssociatedOrders(List<OpportunityLineItem> oldItems)
    {
        List<string> vistaNumbers = getVistaOrderNumbers(oldItems);       
        List<Order> oldOrders = [SELECT Id, Vista_Order_Number__C FROM ORder WHERE Vista_ORder_Number__c In: vistaNumbers];
        Map<string, Order> ordersToOrderNumbers = new Map<string, Order>();
        for(Order oldOrder : oldOrders)
        {
            ordersToOrderNumbers.put(oldORder.Vista_Order_Number__C, oldORder);
        }
        return ordersToOrderNumbers;
    }
    
    public Map<string, Asset> getAssociatedAssets(List<OpportunityLineItem> oldItems)
    {
 
        vistaNumbers = getVistaOrderNumbers(oldItems);
        vinNumbers=getVinNumbers(oldItems);
        licenseNumbers=getLicencenumbers(oldItems);
        List<Asset> oldAssets;
                
        if(!vistaNumbers.isEmpty())
            oldAssets = [SELECT Id, AccountId, Order_Number__C,Registration_Number__c FROM Asset WHERE Order_Number__c In: vistaNumbers AND Account.Country_ISO_Code__c != 'AU']; // Added New Condition as part of CXPDA-949
        else
        if(!vinNumbers.isEmpty())
            oldAssets = [SELECT Id, AccountId, Order_Number__C,Registration_Number__c FROM Asset WHERE id In: vinNumbers AND Account.Country_ISO_Code__c != 'AU']; // Added New Condition as part of CXPDA-949
        else
        if(!licenseNumbers.isEmpty()) 
            oldAssets = [SELECT Id, AccountId, Order_Number__C,Registration_Number__c FROM Asset WHERE registration_number__c In: licenseNumbers AND Account.Country_ISO_Code__c != 'AU'];   // Added New Condition as part of CXPDA-949
             
        Map<string, Asset> assetsToOrderNumbers = new Map<string, Asset>();
        
        if(oldAssets!=null && !vistaNumbers.isEmpty())
            for(Asset oldAsset : oldAssets)
            {
                assetsToOrderNumbers.put(oldAsset.Order_Number__C, oldAsset);
            }
        else
        if(!vinNumbers.isEmpty() & oldAssets!=null)
             for(Asset oldAsset : oldAssets)
            {
                assetsToOrderNumbers.put(oldAsset.id, oldAsset);  
            }
        else    
        if(!licenseNumbers.isEmpty() & oldAssets!=null)
         for(Asset oldAsset : oldAssets)
        {
            
            assetsToOrderNumbers.put(oldAsset.registration_number__c, oldAsset);   
        }
            
        return assetsToOrderNumbers;
    }

}