public without sharing class VehicleUpdateOnAccountController {
  @AuraEnabled
    public static AssetRolesWrapper getAccountAssetRoles(String accountId) {
        AssetRolesWrapper arWrapper = new AssetRolesWrapper();
        Id primaryAccountId;
        Account assetAccount = [SELECT Id, Is_Primary__c, Primary_Account__c,RecordType.DeveloperName FROM Account WHERE Id=: accountId];
       arWrapper.recordTypeName = ''+assetAccount.RecordType.DeveloperName;
        if(assetAccount.Is_Primary__c)  primaryAccountId = assetAccount.Id;   else    primaryAccountId = assetAccount.Primary_Account__c;
        if(assetAccount.RecordType.DeveloperName != 'Retailer'){
            
            List<Role__c> assetRoleList = [SELECT Id,Account__c,Vehicle__c,Vehicle__r.AccountId, Vehicle__r.Name,Vehicle__r.Registration_Number__c, Role__c, Model_From_Asset__c 
                                           FROM Role__c WHERE Primary_Account__c =: primaryAccountId OR Account__c =: primaryAccountId ORDER BY Role__c ASC];
            List<Id> accountIdList = new List<Id>();
            Map<Id,Boolean> accountAccess = new Map<Id,Boolean>();
            List<AssetPermissionWrapper> roleWrapper = new List<AssetPermissionWrapper>();
            for(Role__c role : assetRoleList){
                accountIdList.Add(role.Vehicle__r.AccountId);
            }
            for(UserRecordAccess access: [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId IN :accountIdList]){
                accountAccess.put(access.RecordId,access.HasEditAccess);
            }
              for(Role__c role : assetRoleList){
                  AssetPermissionWrapper singleRoleWrapper = new AssetPermissionWrapper();
                 singleRoleWrapper.accountAssetRole = role;
                  singleRoleWrapper.editAccess = accountAccess.get(role.Vehicle__r.AccountId);
                roleWrapper.Add(singleRoleWrapper);
            }
        arWrapper.accountAssetRolesList.addAll(roleWrapper);      
        }
            return arWrapper; 
    }
    
    @AuraEnabled
    public static AssetRolesWrapper getAllAccountAssetRoles(String accountId) {
        AssetRolesWrapper arWrapper = new AssetRolesWrapper();
        Id primaryAccountId;
        Account assetAccount = [SELECT Id, Is_Primary__c, Primary_Account__c,RecordType.DeveloperName FROM Account WHERE Id=: accountId];
       arWrapper.recordTypeName = ''+assetAccount.RecordType.DeveloperName;
        if(assetAccount.Is_Primary__c)  primaryAccountId = assetAccount.Id;   else    primaryAccountId = assetAccount.Primary_Account__c;
        if(assetAccount.RecordType.DeveloperName != 'Retailer'){
            
            List<Role__c> assetRoleList = [SELECT Id,Account__c,Vehicle__c,Vehicle__r.AccountId, Vehicle__r.Name,Vehicle__r.Registration_Number__c, Role__c, Model_From_Asset__c 
                                           FROM Role__c WHERE Primary_Account__c =: primaryAccountId OR Account__c =: primaryAccountId ORDER BY Role__c ASC];
            List<Id> accountIdList = new List<Id>();
            Map<Id,Boolean> accountAccess = new Map<Id,Boolean>();
            List<AssetPermissionWrapper> roleWrapper = new List<AssetPermissionWrapper>();
            for(Role__c role : assetRoleList){
                accountIdList.Add(role.Vehicle__r.AccountId);
            }
            for(UserRecordAccess access: [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId IN :accountIdList]){
                accountAccess.put(access.RecordId,access.HasEditAccess);
            }
              for(Role__c role : assetRoleList){
                  AssetPermissionWrapper singleRoleWrapper = new AssetPermissionWrapper();
                 singleRoleWrapper.accountAssetRole = role;
                  singleRoleWrapper.editAccess = accountAccess.get(role.Vehicle__r.AccountId);
                roleWrapper.Add(singleRoleWrapper);
            }
        arWrapper.accountAssetRolesList.addAll(roleWrapper);      
        }
            return arWrapper; 
    }
    
    
    @AuraEnabled
    public static String getLoggedInUserAccountId() {
        User currentUser = [SELECT Id, AccountId FROM User WHERE Id =:UserInfo.getUserId()];
        if(currentUser.AccountId != null)  return currentUser.AccountId; else  return 'Not Community User';
                
    }
     @AuraEnabled
    public static List<recordType> getRoleRecordTypeList() {       
        return SObjectUtilities.RecordTypes.get('Role__c').values();
    }
     @AuraEnabled
    public static String changeAssetOwner(String assetId) { 
        Asset currentAsset = [SELECT Id ,AccountId,OwnerId FROM Asset WHERE Id= :assetId];
    currentAsset.OwnerId = userinfo.getUserId();
            update currentAsset;
        return currentAsset.id;
    }
    
    
    
  public class AssetRolesWrapper {
        @AuraEnabled
        public List<AssetPermissionWrapper> accountAssetRolesList = new List<AssetPermissionWrapper>();
        @AuraEnabled
        public String recordTypeName = '';
    } 
     public class AssetPermissionWrapper {
        @AuraEnabled
        public Role__c accountAssetRole = new Role__c();
        @AuraEnabled
        public Boolean editAccess;
    }
    
}