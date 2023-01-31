public class AssetRoleSetter {
    
    public static boolean ownerChangedFromNewAssetRole = false;
    
    public void SetOwnerAssetRoles(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap){
        List<Asset> assetsWithNewOwner = new List<Asset>();
        List<Asset> assetsWithDeletedOwner = new List<Asset>();
        List<Id> accountIdList = new List<Id>();
        if(AssetRoleSetter.ownerChangedFromNewAssetRole){
            return;
        }
        //Start - Updated as part of CXPDA-948
        for(Asset asset : currentAssets){
        if(oldAssetMap != null && oldAssetMap.containsKey(asset.Id)){
           if(asset.AccountId != oldAssetMap.get(asset.Id).AccountId){
                accountIdList.add(asset.AccountId);
                accountIdList.add(oldAssetMap.get(asset.Id).AccountId);
            }
            }else if(asset.AccountId != null){
               accountIdList.add(asset.AccountId);
                
            }
        }
         Map<Id,Account> roleAccountMap = new Map<Id,Account>(); //new Map<Id,Account>([SELECT Id, Primary_Account__c, Primary_Account__pc, IsPersonAccount, Is_Primary__c, Country_ISO_Code__c,Country_ISO_Code__pc FROM Account
                                                //               WHERE Is_Primary__c= FALSE AND (Country_ISO_Code__c = 'AU' OR Country_ISO_Code__pc = 'AU') AND  Id IN :accountIdList]);
       
        
        
        for(Asset asset : currentAssets){
            //if AccountId is not null, find out if we need to create a new AssetRole
            if(oldAssetMap != null && oldAssetMap.containsKey(asset.Id)){ //if the Asset Account has changed, create a new AssetRole and update any existing AssetRoles
                Asset oldAsset = oldAssetMap.get(asset.Id);
                Account currentAccount;
                Account oldAccount;
               if(roleAccountMap.containsKey(asset.AccountId)) currentAccount = roleAccountMap.get(asset.AccountId);
               if(roleAccountMap.containsKey(oldAsset.AccountId)) oldAccount = roleAccountMap.get(oldAsset.AccountId);
                if(oldAsset.AccountId == null && asset.AccountId != null){ //new Asset Account value added
                    assetsWithNewOwner.add(asset);
                }
                else if(oldAsset.AccountId != null){
                    if(asset.AccountId == null){ //Asset Account value deleted
                        assetsWithDeletedOwner.add(asset);
                    }
                    else if(oldAsset.AccountId != asset.AccountId && ((currentAccount == null && oldAccount == null) || (currentAccount != null && oldAccount != null && currentAccount.Primary_Account__c != oldAccount.Primary_Account__c))){ //Asset Account value changed
                        assetsWithNewOwner.add(asset);
                        assetsWithDeletedOwner.add(asset);
                    }
                }
            }
            else if(asset.AccountId != null){ //new Asset
                assetsWithNewOwner.add(asset);
            }
        }
        
        //End - Updated as part of CXPDA-948
        ChangeExistingAssetRole(assetsWithDeletedOwner, 'Current Owner', 'Previous Owner');
        CreateNewAssetRole(assetsWithNewOwner, 'Current Owner');
    }
    
    public void CreateNewAssetRole(List<Asset> assets, String role){
        List<Role__c> assetRolesToCreate = new List<Role__c>();
        List<Role__c> accountAssetRoles = new List<Role__c>();
        //should not create a new asset role if the current owner is a Retailer
        Set<Id> accountIdsToCheckForRetailer = new Set<Id>();
        Set<Id> retailerAccountIds = new Set<Id>(); 
        Id accountRecordType;
        Id contactRecordType;
        //if (UserInfo.getLocale()=='en_GB' || UserInfo.getLocale()=='en_US') {
        //    accountRecordType = Schema.SObjectType.Role__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        //  contactRecordType = Schema.SObjectType.Role__c.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        //} else {
            for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN ('Account', 'Contact') AND SobjectType = 'Role__c']){
                if(rt.DeveloperName.equalsIgnoreCase('ACCOUNT')){
                    accountRecordType = rt.Id;
                }
                else if(rt.DeveloperName.equalsIgnoreCase('CONTACT')){
                    contactRecordType = rt.Id;
                }
            }
        //}
        Id retailerRecordType = AccountUtilities.RecordTypes.get('Retailer').Id;
        for(Asset asset : assets){
            if(asset.AccountId != null){
                accountAssetRoles.add(new Role__c(RecordTypeId=accountRecordType, Account__c=asset.AccountId, Vehicle__c=asset.Id, Role__c=role, Driver__c=asset.Driver__c, Lessee__c=asset.Lessee__c));
                accountIdsToCheckForRetailer.add(asset.AccountId);
            }
            else if(asset.ContactId != null){
                assetRolesToCreate.add(new Role__c(RecordTypeId=contactRecordType, Contact__c=asset.ContactId, Vehicle__c=asset.Id, Role__c=role, Driver__c=asset.Driver__c, Lessee__c=asset.Lessee__c));
            }
        }
        for(Account acc : [SELECT Id FROM Account WHERE Id IN :accountIdsToCheckForRetailer AND RecordTypeId = :retailerRecordType]){
            retailerAccountIds.add(acc.Id);
        }
        for(Role__c r : accountAssetRoles){
            if(!retailerAccountIds.contains(r.Account__c)){
                assetRolesToCreate.add(r);
            }
        }
        if(assetRolesToCreate.size() > 0){
            insert assetRolesToCreate;
        }
    }
    
    public void UpdateAssets(List<Role__c> assetRoles){
        //retrieve the Assets related to the passed AssetRoles and determine if it AccountId requires updating to the AccountId of the AssetRole
        Map<Id, Id> assetOwnerMap = new Map<Id, Id>();
        for(Role__c assetRole : assetRoles){
            if(String.IsNotBlank(assetRole.Role__c) && assetRole.Role__c.equalsIgnoreCase('CURRENT OWNER')){
                if(assetRole.Vehicle__c != null && assetRole.Account__c != null){
                    assetOwnerMap.put(assetRole.Vehicle__c, assetRole.Account__c);
                }
            }
        }
        List<Asset> vehiclesToUpdate = new List<Asset>();
        
         Map<Id,Account> roleAccountMap = new Map<Id,Account>([SELECT Id, Primary_Account__c, Primary_Account__pc, IsPersonAccount, Is_Primary__c, Country_ISO_Code__c,Country_ISO_Code__pc FROM Account
                                                               WHERE (Country_ISO_Code__c = 'AU' OR Country_ISO_Code__pc = 'AU') AND  Id IN :assetOwnerMap.values()]);    //Added as part of CXPDA-948
      
        for(Asset vehicle : [SELECT Id, AccountId FROM Asset WHERE Id IN :assetOwnerMap.keySet()]){
            if(assetOwnerMap.containsKey(vehicle.Id)){
                Id assignedOwner = assetOwnerMap.get(vehicle.Id);
                 //Start - Updated as part of CXPDA-948
                Boolean isAUSPrimaryAccount = false;
              //jp  if(roleAccountMap.containsKey(assignedOwner)) isAUSPrimaryAccount = roleAccountMap.get(assignedOwner).Is_Primary__c;
                if(vehicle.AccountId != assignedOwner && !isAUSPrimaryAccount){
                    vehiclesToUpdate.add(new Asset(Id=vehicle.Id, AccountId=assignedOwner));
                }
                 //End - Updated as part of CXPDA-948
            }
        }
        ownerChangedFromNewAssetRole = true;
        update vehiclesToUpdate;
        UpdateRoleAccount(assetRoles, roleAccountMap);
    }
    
    public void ChangeExistingAssetRole(List<Asset> assets, String existingRole, String newRole){
        Set<Id> assetIds = new Set<Id>();
        for(Asset asset : assets){
            assetIds.add(asset.Id);
        }
       List<Role__c> currentAssetRoles = [SELECT Id, Role__c FROM Role__c WHERE Account__c != null AND Vehicle__c IN :assetIds AND Role__c = :existingRole];
        for(Role__c assetRole : currentAssetRoles){
            assetRole.Role__c = newRole;
        }
        update currentAssetRoles;
    }
    
   /**
    * @param Method Name: UpdateRoleAccount
    * @description :This is applicable for AUS only. It will update the Role Account to Primary Account of the Role.Account 
    * @param  : (List<Role__c> assetRoles- Trigger.New ,  Map<Id,Account> roleAccountMap - Account Role Map
    * @return : 
    * @JIRA: CXPDA-948
    */
     public void UpdateRoleAccount(List<Role__c> assetRoles, Map<Id,Account> roleAccountMap){
    
         for(Role__c assetRole : assetRoles){
             if(roleAccountMap.containsKey(assetRole.Account__c)){
                 Account currentRoleAccount = roleAccountMap.get(assetRole.Account__c);
                 if(!currentRoleAccount.Is_Primary__c && currentRoleAccount.Primary_Account__pc !=null && currentRoleAccount.IsPersonAccount){
                     assetRole.Account__c = currentRoleAccount.Primary_Account__pc;
                 }else if(!currentRoleAccount.Is_Primary__c && currentRoleAccount.Primary_Account__c  !=null) {
                     assetRole.Account__c = currentRoleAccount.Primary_Account__c;
                     
                 }
             }
         }
     }
    
}