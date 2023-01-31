public class AddUserToRetailerQueue {
    
    @future
    public static void add(List<String> partnerUsers) {
        
        // Omstamtoate grpi[ ,e,ners list]
        List<GroupMember> groupMembers = new List<GroupMember>();
        
        List<User_Profile_for_Queues__c> userProfilesList = User_Profile_for_Queues__c.getAll().values();
        
        if(userProfilesList.size()>0) {
            
            // Convert `List` to `Set` to use the .contains method below, using the Profile IDs
            Set<Id> userProfilesSet = new Set<Id>();
            
            // Add profile ID to user set
            for(User_Profile_for_Queues__c prof : userProfilesList) {
                userProfilesSet.add((Id)prof.profile_id__c);
            }
            
            
            // Deserialize
            for (String userSer : partnerUsers) {
                
                User u = (User)JSON.deserialize(userSer, User.class);
                
                System.debug(u.profileId);
                if (userProfilesSet.contains(u.profileId)) {
                    GroupMember groupMem = new GroupMember(UserOrGroupId = u.Id, GroupId = u.Contact_Queue_ID__c);
                    groupMembers.add(groupMem);
                    
                }
            }
            
            insert groupMembers;
        }
    }
    
    @future
    public static void remove(List<String> partnerUsers) {
               
        List<User_Profile_for_Queues__c> userProfilesList = User_Profile_for_Queues__c.getAll().values();
        
        if(userProfilesList.size()>0) {
            
            // Convert `List` to `Set` to use the .contains method below, using the Profile IDs
            Set<Id> userProfilesSet = new Set<Id>();
            
            // Add profile ID to user set
            for(User_Profile_for_Queues__c prof : userProfilesList) {
                userProfilesSet.add((Id)prof.profile_id__c);
            }
            
            
            // Deserialize
            Set<Id> userIds = new Set<Id>();
            Set<String> groupIds = new Set<String>();
 
            for (String userSer : partnerUsers) {
                
                User u = (User)JSON.deserialize(userSer, User.class);
                
                if (!userProfilesSet.contains(u.profileId)) {
                    userIds.add(u.Id);
                    groupIds.add(u.Contact_Queue_ID__c);
                }
            }
            
            List<GroupMember> queueMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId IN :userIds AND GroupId IN :groupIds];
            delete queueMembers;
        }
    }
    
    @future
    public static void move(List<String> partnerUsers) {
        List<GroupMember> newGroupMembers = new List<GroupMember>();
    
        // Deserialize
        Set<Id> userIds = new Set<Id>();
        Set<String> groupIds = new Set<String>();
 
        for (String userSer : partnerUsers) {           
            UserHandler.UpdatedRetailerQueue urq = (UserHandler.UpdatedRetailerQueue)JSON.deserialize(userSer, UserHandler.UpdatedRetailerQueue.class);
            
            GroupMember groupMem = new GroupMember(UserOrGroupId = urq.userId, GroupId = urq.currentQueueId);
            newGroupMembers.add(groupMem);
                
            userIds.add(urq.userId);
            groupIds.add(urq.oldQueueId);
        }
            
        List<GroupMember> oldGroupMembers = [SELECT Id FROM GroupMember WHERE UserOrGroupId IN :userIds AND GroupId IN :groupIds];
        delete oldGroupMembers;
        insert newGroupMembers;
    }
    
}