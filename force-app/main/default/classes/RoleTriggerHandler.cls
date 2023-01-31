public class RoleTriggerHandler {
    
    Public static Boolean accountJagANDLRStatusRoleInsertCheck = true;
    Public static Boolean accountJagANDLRStatusRoleUpdateCheck = true;
    
    public void PreCreate(List<Role__c> roles)
    {
        /*VehicleOwnershipStatusSetter vehicleOwnershipStatusSetter = new VehicleOwnershipStatusSetter();

vehicleOwnershipStatusSetter.SetOwnershipStatuses(vehicleAccountRoles);*/
        RoleStatusSetter_Factory roleStatusSetterFactory = new RoleStatusSetter_Factory();
        RoleStatusMaintainer roleStatusMaintainer = new RoleStatusMaintainer(roleStatusSetterFactory.Build());
        
        if (!roles.isEmpty()) roleStatusMaintainer.MaintainRoleStatuses(roles);
        
        AssetRoleSetterNew assetRoleSetter = new AssetRoleSetterNew();      
        assetRoleSetter.UpdateAssets(roles);
        assetRoleSetter.UpdateRoleEffectiveDateAndPrimary(roles, null);
    }
    
    public void PreUpdate(List<Role__c> currentRoles, Map<Id,Role__c> oldMap)
    {
        /*VehicleOwnershipStatusSetter vehicleOwnershipStatusSetter = new VehicleOwnershipStatusSetter();

vehicleOwnershipStatusSetter.SetOwnershipStatuses(currentVehicleAccountRoles, oldVehicleAccountRoles);*/
        
        RoleStatusSetter_Factory roleStatusSetterFactory = new RoleStatusSetter_Factory();
        RoleStatusMaintainer roleStatusMaintainer = new RoleStatusMaintainer(roleStatusSetterFactory.Build());
        
        if (!currentRoles.isEmpty()) roleStatusMaintainer.MaintainRoleStatuses(currentRoles, oldMap.values());
        
        AssetRoleSetterNew assetRoleSetter = new AssetRoleSetterNew();
        assetRoleSetter.UpdateAssets(currentRoles);
        assetRoleSetter.UpdateRoleEffectiveDateAndPrimary(currentRoles, oldMap);
    }
    
    public void PreDelete(List<Role__c> roles)
    {
        RoleStatusSetter_Factory roleStatusSetterFactory = new RoleStatusSetter_Factory();
        RoleStatusMaintainer roleStatusMaintainer = new RoleStatusMaintainer(roleStatusSetterFactory.Build());
        
        roleStatusMaintainer.RollbackRoleStatuses(roles);
    }
    public void PostCreate(List<Role__c> currentRoles){
        if(!system.isFuture() && !system.isBatch() && accountJagANDLRStatusRoleInsertCheck){
            String roleJsonStr = json.serialize(currentRoles);
            AccountJagANDLRStatusHandler.handleJaguarAndLandRoverStatusRole(roleJsonStr,null);
            accountJagANDLRStatusRoleInsertCheck = false;
        }
    }
    
    public void PostUpdate(List<Role__c> currentRoles, Map<Id,Role__c> oldMap){
        if(!system.isFuture() && !system.isBatch() && accountJagANDLRStatusRoleUpdateCheck){
            String roleJsonStr = json.serialize(currentRoles);
            String oldRoleJsonStr = json.serialize(oldMap);
            AccountJagANDLRStatusHandler.handleJaguarAndLandRoverStatusRole(roleJsonStr,oldRoleJsonStr);
            accountJagANDLRStatusRoleUpdateCheck = false;
        }
    }
    
}