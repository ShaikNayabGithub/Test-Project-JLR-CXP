public class AssetRoleSetterNew {
    
    
    public void SetOwnerAssetRoles(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap){
        System.debug('SetOwnerAssetRoles');
        List<Asset> assetsWithNewOwner = new List<Asset>();
        List<Asset> assetsWithDeletedOwner = new List<Asset>();
        List<Id> accountIdList = new List<Id>();
        
        
        for(Asset asset : currentAssets){
            if(oldAssetMap != null && oldAssetMap.containsKey(asset.Id)){
                //an Update Call
                if(asset.AccountId != oldAssetMap.get(asset.Id).AccountId){
                    //doesn't match so add to list
                    accountIdList.add(asset.AccountId);
                    accountIdList.add(oldAssetMap.get(asset.Id).AccountId);
                }
            }else if(asset.AccountId != null){
                //new asset create first one
                accountIdList.add(asset.AccountId);
                
            }
        }
        
        
        //get map of accounts which aren't primary but getting parents which are
        /*Map<Id,Account> roleAccountMap = new Map<Id,Account>([SELECT Id, Primary_Account__c, Primary_Account__pc, IsPersonAccount, Is_Primary__c, Country_ISO_Code__c,Country_ISO_Code__pc FROM Account
                                                              WHERE (Country_ISO_Code__c = 'AU' OR Country_ISO_Code__pc = 'AU') AND  Id IN :accountIdList AND Primary_Account__c != null  ]); */
        
        
        for(Asset asset : currentAssets){
            //if AccountId is not null, find out if we need to create a new AssetRole
            if(oldAssetMap != null && oldAssetMap.containsKey(asset.Id)){ //if the Asset Account has changed, create a new AssetRole and update any existing AssetRoles
                Asset oldAsset = oldAssetMap.get(asset.Id);
                //Account currentAccountAU;
                //Account oldAccountAU;
                //if(roleAccountMap.containsKey(asset.AccountId)) currentAccountAU = roleAccountMap.get(asset.AccountId);
                
                //if(roleAccountMap.containsKey(oldAsset.AccountId)) oldAccountAU = roleAccountMap.get(oldAsset.AccountId);
                
                
                if(oldAsset.AccountId == null && asset.AccountId != null){ //new Asset Account value added
                    assetsWithNewOwner.add(asset);
                }
                else if(oldAsset.AccountId != null){
                    if(asset.AccountId == null){ //Asset Account value deleted
                        assetsWithDeletedOwner.add(asset);
                    }
                    else if(oldAsset.AccountId != asset.AccountId /*&& (
                        (currentAccountAU == null && oldAccountAU == null) //Neither are primary or not aus
                        || (currentAccountAU != null && oldAccountAU != null && currentAccountAU.Primary_Account__c != oldAccountAU.Primary_Account__c) //both are secondary and don't match primary
                        || (currentAccountAU == null && oldAccountAU != null && asset.AccountId != oldAccountAU.Primary_Account__c) //current primary of old account
                        || (currentAccountAU != null && oldAccountAU == null && oldAsset.AccountId != currentAccountAU.Primary_Account__c) //current secondary of old primary account
                    )*/){ //Asset Account value changed
                        assetsWithNewOwner.add(asset);
                        assetsWithDeletedOwner.add(asset);
                    }
                }
            }
            else if(asset.AccountId != null){ //new Asset
                assetsWithNewOwner.add(asset);
            }
            
            
        }
           //set all current owner to previous
        ChangeExistingAssetRole(assetsWithDeletedOwner, 'Current Owner', 'Previous Owner');
     
            CreateNewAssetRole(assetsWithNewOwner, 'Current Owner');
        
        
        
    }
    
     public void ChangeExistingAssetRole(List<Asset> assets, String existingRole, String newRole){
        Set<Id> assetIds = new Set<Id>();
        for(Asset asset : assets){
            assetIds.add(asset.Id);
        }
       List<Role__c> currentAssetRoles = [SELECT Id, Role__c FROM Role__c WHERE Account__c != null AND Vehicle__c IN :assetIds AND Role__c = :existingRole];
        for(Role__c assetRole : currentAssetRoles){
            assetRole.Role__c = newRole;
            assetRole.Effective_To__c=system.today();
        }
        update currentAssetRoles;
    }
    
     public void CreateNewAssetRole(List<Asset> assets, String role){
        //oncreation
         List<Role__c> assetRolesToCreate = new List<Role__c>();
        List<Role__c> accountAssetRoles = new List<Role__c>();
        //should not create a new asset role if the current owner is a Retailer
        Set<Id> accountIdsToCheckForRetailer = new Set<Id>();
        Set<Id> retailerAccountIds = new Set<Id>(); 
        Id accountRecordType;
        Id contactRecordType;
       
            for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN ('Account', 'Contact') AND SobjectType = 'Role__c']){
                if(rt.DeveloperName.equalsIgnoreCase('ACCOUNT')){
                    accountRecordType = rt.Id;
                }
                else if(rt.DeveloperName.equalsIgnoreCase('CONTACT')){
                    contactRecordType = rt.Id;
                }
            }
        
        Id retailerRecordType = AccountUtilities.RecordTypes.get('Retailer').Id;
        for(Asset asset : assets){
            if(asset.AccountId != null){
                accountAssetRoles.add(new Role__c(RecordTypeId=accountRecordType, Account__c=asset.AccountId, Vehicle__c=asset.Id, Role__c=role, Driver__c=asset.Driver__c, Lessee__c=asset.Lessee__c, Effective_From__c=system.today()));
                accountIdsToCheckForRetailer.add(asset.AccountId);
            }
            else if(asset.ContactId != null){
                assetRolesToCreate.add(new Role__c(RecordTypeId=contactRecordType, Contact__c=asset.ContactId, Vehicle__c=asset.Id, Role__c=role, Driver__c=asset.Driver__c, Lessee__c=asset.Lessee__c,Effective_From__c=system.today()));
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
            //update ownership to false!
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
        
        /*Map<Id,Account> roleAccountMap = new Map<Id,Account>([SELECT Id, Primary_Account__c, Primary_Account__pc, IsPersonAccount, Is_Primary__c, Country_ISO_Code__c,Country_ISO_Code__pc FROM Account
                                                               WHERE (Country_ISO_Code__c = 'AU' OR Country_ISO_Code__pc = 'AU') AND  Id IN :assetOwnerMap.values() ]);    //Added as part of CXPDA-948
      
        system.debug('roleAccountMap '+roleAccountMap);*/
         for(Asset vehicle : [SELECT Id, AccountId, Account.Primary_Account__c FROM Asset WHERE Id IN :assetOwnerMap.keySet()]){
            if(assetOwnerMap.containsKey(vehicle.Id)){
                Id assignedOwner = assetOwnerMap.get(vehicle.Id);
                 //Start - Updated as part of CXPDA-948
               
                ///here should only update asset if account not primary of 
               /*if(roleAccountMap.containsKey(assignedOwner)){
                     system.debug('It is australia ');
                    Account acc = roleAccountMap.get(assignedOwner);
                     system.debug('acc '+acc);
                     system.debug('acc.primary_account__c '+acc.primary_account__c);
                    system.debug('assignedOwner '+assignedOwner);
                        system.debug('vehicle '+vehicle);
                       system.debug('vehicle.AccountId '+vehicle.AccountId);
                     system.debug('vehicle.Account.primary_account__c '+vehicle.Account.primary_account__c);
                    //
                       if(vehicle.AccountId != assignedOwner) system.debug('vehicle.AccountId != assignedOwner');
                       if( vehicle.account.primary_account__c != null) system.debug(' vehicle.account.primary_account__c != null');
                       if(vehicle.account.primary_account__c != assignedOwner) system.debug('vehicle.account.primary_account__c != assignedOwner');
                       if(assignedOwner != acc.Id ) system.debug('assignedOwner != acc.Id ');
                       if(acc.primary_account__c != null && assignedOwner != acc.primary_account__c) system.debug('acc.primary_account__c != null && assignedOwner != acc.primary_account__c');
                       if((assignedOwner != acc.Id &&  acc.primary_account__c == null)) system.debug('(assignedOwner != acc.Id &&  acc.primary_account__c == null)');
                     
                    //
                    
                    if(    
                        (   (vehicle.AccountId != assignedOwner &&   vehicle.account.primary_account__c != null &&  vehicle.account.primary_account__c != assignedOwner)
                        || (vehicle.AccountId != assignedOwner &&   vehicle.account.primary_account__c == null )
                        )
                       && 
                        (    (vehicle.AccountId  != acc.Id && acc.primary_account__c != null && vehicle.AccountId  != acc.primary_account__c)
                             ||(vehicle.AccountId  != acc.Id &&  acc.primary_account__c == null)
                        )
                      ){ 
                            system.debug('CHANGED ');
                         vehiclesToUpdate.add(new Asset(Id=vehicle.Id, AccountId=assignedOwner));
                    }
                    
                    
                }else{ */
                     if(vehicle.AccountId != assignedOwner){
                    vehiclesToUpdate.add(new Asset(Id=vehicle.Id, AccountId=assignedOwner));
                }  
                }
                    
                    
             
                 //End - Updated as part of CXPDA-948
            }
        //}
      system.debug('vehiclesToUpdate '+vehiclesToUpdate);
         if(!vehiclesToUpdate.isEmpty())
        update vehiclesToUpdate;
        //UpdateRoleAccount(assetRoles, roleAccountMap);
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
                 if( currentRoleAccount.Primary_Account__c !=null ){
                     assetRole.Account__c = currentRoleAccount.Primary_Account__c;
                 }
             }
         }
     }
    
     public void UpdateRoleEffectiveDateAndPrimary(List<Role__c> assetRoles, Map<Id,Role__c> OldRoleMap){
    	 Set<Id> assetAccountId= New Set<Id>();
         for(Role__c assetRole : assetRoles){
             if(assetRole.Account__c !=null)
           	assetAccountId.add(assetRole.Account__c);
         }
         
         Map<Id,Account> assetAccountMap= New Map<Id,Account>([select Id,  Primary_Account__c, Primary_Account__pc, IsPersonAccount, Is_Primary__c from Account where ID IN:assetAccountId ]);
         for(Role__c assetRole : assetRoles){
            if(OldRoleMap!=null && OldRoleMap.get(assetRole.id).Role__c != assetRole.Role__c && assetRole.Role__c=='Previous Owner' && assetRole.Effective_To__c==null)
            {
               assetRole.Effective_To__c=System.today(); 
            }else if(OldRoleMap==null && assetRole.Role__c=='Current Owner')
            {
               assetRole.Effective_From__c=System.today(); 
            }
             
             If(!assetAccountMap.isEmpty() && assetAccountMap.containsKey(assetRole.Account__c))
             {
                 account ObjAccount=assetAccountMap.get(assetRole.Account__c);
             	if(ObjAccount.Is_Primary__c)
                	assetRole.Primary_Account__c= ObjAccount.Id;
                else if(ObjAccount.Primary_Account__c !=null)
                    assetRole.Primary_Account__c= ObjAccount.Primary_Account__c;
             	else If(ObjAccount.Primary_Account__pc !=null)
                    assetRole.Primary_Account__c= ObjAccount.Primary_Account__pc;
             }
         }
     }
    
}