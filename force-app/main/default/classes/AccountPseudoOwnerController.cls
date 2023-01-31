public class AccountPseudoOwnerController {
    
    //THIS CLASS CAN BE DELETED - REMOVAL OF PSEUDO_ACCOUNT_OWNER
    public void CheckIfCanEditPseudoOwner(List<Account> newAccounts, List<Account> oldAccounts)
    { 
        //MAKE SURE THIS ONLY FIRES ON CHANGE OF PSEUDOOWNER SOMEWHERE
        Map<Id, Account> newAccountsMap = new Map<Id, Account>(newAccounts);
        Id currentUser = UserInfo.getUserId();
        ID currentUserRoleID = UserInfo.getUserRoleId();
        
        List<User> userList = getUserList(oldAccounts);
        List<UserRole> allRolesList = [SELECT Name, ParentRoleID FROM UserRole WHERE PortalType =: 'Partner'];
        Set<UserRole> allRolesSet = new Set<UserRole>(allRolesList);
        
        boolean canUpdate = false;
        boolean isCurrentUserPartner = isUserPartner(allRolesSet, currentUserRoleID);
        
        for(Account oldAccount : oldAccounts)
        {
            Id oldAccountPseudoOwner = oldAccount.OwnerId;
            Id newAccountPseudoOwner = newAccountsMap.get(oldAccount.Id).OwnerId;
            Set<ID> currentUserRoleIDSet = new Set<ID>();
            currentUserRoleIDSet.add(currentUserRoleID);
            User currentFullUser = getUserFromList(userList, currentUser);
            User oldUser = getUserFromList(userList, oldAccount.OwnerId); 
            
            canUpdate = canCurrentUserUpdate(oldAccountPseudoOwner, currentUser, currentUserRoleIDSet, allRolesSet, oldUser, currentFullUser, isCurrentUserPartner);
            
            if(!canUpdate)
            {
                Account newAcc = newAccountsMap.get(oldAccount.Id);
                newAcc.addError('Insufficient permissions to reassign this account');
            }
        }
    }
    
    @TestVisible
    private Boolean canCurrentUserUpdate(Id oldAccountPseudoOwner, ID CurrentUser, Set<ID> currentUserRoleIDSet, Set<UserRole> allRolesSet, User oldUser, User currentFullUser, boolean isCurrentUserPartner)
    {
        Boolean canUpdate = false;
        if(oldAccountPseudoOwner == CurrentUser)
            {
                canUpdate = true;
                System.debug('CurrentUser is OldOwner');
            }
            if(isCurrentUserPartner)
            {
                System.debug('current is partner');
                Set<ID> childRoles = getAllChildRoleIds(currentUserRoleIDSet, allRolesSet);
                if(childRoles.contains(oldUser.UserRoleId))
                {
                    System.debug('Is below in hierarchy');
                    canUpdate = true;
                }
            }
            else
            {
                if(currentFullUser != null && oldUser != null)
                {
                    if(currentFullUser.Market__c == null || currentFullUser.Market__c == oldUser.Market__c)
                    {
                        system.debug('current user market ' + currentFullUser.Market__c);
                        canUpdate = true;
                    }
                }
            }
        
        return canUpdate;
    }
    
    @TestVisible
    private List<User> getUserList(List<Account> oldAccounts)
    {
        Set<Id> userIds = new Set<Id>();
        for(Account oldAcc : oldAccounts)
        {
            userIds.add(oldAcc.OwnerId);
        }
        userIds.add(userInfo.getUserId());
        
        List<User> userList = [SELECT UserRoleId, Market__c FROM User WHERE Id In : userIds];
        
        return userList;
    }
    
    @TestVisible
    private User getUserFromList(List<User> userList, Id userIdToGet)
    {
        for(User listUser : userList)
        {
            if(listUser.Id == userIdToGet)
            {
                return listUser;
            }
        }
        return null;
    }
      
    @TestVisible
    private Set<ID> getAllChildRoleIds(Set<ID> roleIds, Set<UserRole> allRoles)
    {
            
        Set<ID> currentRoleIds = new Set<ID>();
        
            for(ID userRoleID : roleIds)
            {
                for(UserRole userRole : allRoles)
                {
                    if(userRoleID == userRole.ParentRoleID)
                    {
                        currentRoleIds.add(userRole.id);
                    }
                }
            }
        
        if(currentRoleIds.size() > 0)
        {
            System.debug('Current Roles: ' + currentRoleIds);
            currentRoleIds.addAll(getAllChildRoleIds(currentRoleIds, allRoles));
        }
        System.debug('full current roles ' + currentRoleIds);
        return currentRoleIds;
    }
    
    @TestVisible
    private boolean isUserPartner(Set<UserRole> allRolesSet, ID currentUserRoleID)
    {
        for (UserRole ur : allRolesSet)
        {
            if(ur.id == currentUserRoleID)
            {
                return true;
            }
        }
        return false;
    }
    

}