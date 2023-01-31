public class UserHandler {
    
    public void checkUsers (List<User> users) {
        
        List<User> partnerUsers = new List<User>();
        List<String> partnerUsersSerialised = new List<String>();
        
        for (User u : users) {
            
            if (u.IsActive == true && u.IsPortalEnabled == true && u.ContactId != null && u.UserType == 'PowerPartner' && u.Contact_Queue_ID__c != null) {
                //partnerUsers.add(u);
                partnerUsersSerialised.add(JSON.serialize(u));
            }
        }
        
        if (partnerUsersSerialised.size() > 0) {
            //AddUserToRetailerQueue addToQueue = new AddUserToRetailerQueue(); 
            
            //addToQueue.add(partnerUsers);
            AddUserToRetailerQueue.add(partnerUsersSerialised);
        }
        
        Set<Id> userIds = new Set<Id>();
        for(User u : users){
            userIds.add(u.Id);
        }
        AccountSharingSetter.SetAccountSharingForNewUsers(userIds);
        
    }
    
    public void removeUsers (List<User> users) {
        
        List<String> partnerUsersSerialised = new List<String>();
        
        for (User u : users) {
            if (u.IsActive == true && u.IsPortalEnabled == true && u.ContactId != null && u.UserType == 'PowerPartner' && u.Contact_Queue_ID__c != null) {
                partnerUsersSerialised.add(JSON.serialize(u));
            }
        }
        
        if (partnerUsersSerialised.size() > 0) {
            AddUserToRetailerQueue.remove(partnerUsersSerialised);
        }
        
    }
    
    public void moveUsers (List<UpdatedRetailerQueue> users){
        
        List<String> partnerUsersSerialised = new List<String>();
        
        for(UpdatedRetailerQueue urq : users){
            partnerUsersSerialised.add(JSON.serialize(urq));
        }
        
        if(partnerUsersSerialised.size() > 0) {
            AddUserToRetailerQueue.move(partnerUsersSerialised);
        }
    }
    
    //loop through updated user records and determine if the user profile has been updated and, if it has, determine if user needs to be removed from/added to a retailer queue
    public void checkUsersForUpdatedProfile(Map<Id, User> oldUserMap, List<User> newUsers){
        List<User> addUserToQueue = new List<User>();
        List<User> removeUserFromQueue = new List<User>();
        Set<Id> userProfilesSet = loadQueueProfiles();
        for(User u : newUsers){
            User oldu = oldUserMap.get(u.Id);
            if(oldu != null){
                //remove the user from the retailer queue if the user profile has changed from a profile that adds user to queue to one that doesn't
                //add the user to the retailer queue if the user profile has changed from a profile that doesn't add user to queue to one that does
                if(u.profileId != oldu.profileId){ //if the user's profile has changed
                    if(!userProfilesSet.contains(oldu.profileId) && userProfilesSet.contains(u.profileId)){ //only add to queue if new profile adds users to queue and if the old profile didn't
                        addUserToQueue.add(u);
                    }
                    if(userProfilesSet.contains(oldu.profileId) && !userProfilesSet.contains(u.profileId)){ //remove from retailer queue if the old profile added retailer queue and the new one doesn't
                        removeUserFromQueue.add(u);
                    }
                }
            }
        }
        if(addUserToQueue.size() > 0){
            checkUsers(addUserToQueue);
        }
        if(removeUserFromQueue.size() > 0){
            removeUsers(removeUserFromQueue);
        }
    }
    
    //loop through updated CONTACT records and determine if the AccountId has been updated and, if it has, determine if user needs to be removed from/added to a corresponding retailer queue
    public void checkUsersForUpdatedAccount(Map<Id, Contact> oldContactMap, List<Contact> newContacts){
        List<User> addUserToQueue = new List<User>();
        Map<Id, Id> contactToOriginalQueue = new Map<Id, String>();
        Set<Id> userProfilesSet = loadQueueProfiles();
        List<UpdatedRetailerQueue> usersToMove = new List<UpdatedRetailerQueue>();
        for(Contact c : newContacts){
            Contact oldc = oldContactMap.get(c.Id);
            if(oldc != null && oldc.AccountId != c.AccountId){
                contactToOriginalQueue.put(c.Id, oldc.Account_Queue_Id__c); //track original queue id
            }
        }
        if(contactToOriginalQueue.size() > 0){
          List<User> contactUsers = [SELECT Id, ProfileId, IsActive, IsPortalEnabled, ContactId, UserType, Contact_Queue_ID__c FROM User WHERE ContactId IN :contactToOriginalQueue.keySet()];
          for(User u : contactUsers){
              if (u.IsActive == true && u.IsPortalEnabled == true && u.ContactId != null && u.UserType == 'PowerPartner') {
                  if(userProfilesSet.contains(u.ProfileId)){ //only need to amend retailer queue if user profile adds user to queue
                      usersToMove.add(new UpdatedRetailerQueue(u.Id, u.Contact_Queue_ID__c, contactToOriginalQueue.get(u.ContactId))); //need to remove user from original queue
                  }
              }
          }
        }
        if(usersToMove.size() > 0){
          moveUsers(usersToMove);
        }
    }
    
    private Set<Id> loadQueueProfiles(){ //load from custom settings the profiles for which users should be added to the relevant retailer queues (contact_queue_id__c)
        List<User_Profile_for_Queues__c> userQueueProfilesList = User_Profile_for_Queues__c.getAll().values();
        Set<Id> userQueueProfileSet = new Set<Id>(); //Convert `List` to `Set` to use the .contains method below, using the Profile IDs
        // Add profile ID to user set
        for(User_Profile_for_Queues__c prof : userQueueProfilesList) {
            userQueueProfileSet.add((Id)prof.profile_id__c);
        }
        return userQueueProfileSet;
    }
    
    public void PreInsert(List<User> users){
        UserMarketingStatusSetter userMarketingStatusSetter = new UserMarketingStatusSetter();
        userMarketingStatusSetter.SetStatus(users);        
    }
    public void PreUpdate(List<User> users){
        UserMarketingStatusSetter userMarketingStatusSetter = new UserMarketingStatusSetter();
        userMarketingStatusSetter.SetStatus(users);        
    }
    
    public class UpdatedRetailerQueue {
        public Id userId;
        public Id currentQueueId;
        public Id oldQueueId;
        
        public UpdatedRetailerQueue(Id user, Id currentQueue, Id oldQueue){
            this.userId = user;
            this.currentQueueId = currentQueue;
            this.oldQueueId = oldQueue;
        }
    }
    
}