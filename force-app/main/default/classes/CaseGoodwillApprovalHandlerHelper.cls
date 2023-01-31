public without sharing class CaseGoodwillApprovalHandlerHelper {
        //changed as per CXPD-2617 Goodwill Case Approval Modifications
        //specifically for Korea market, goodwill process should not trigger automatically
        //User will explictly click on approval button to trigger approval process
        //gets a list of all users. This was part of CaseGoodwillApprovalHandler class earlier but it was not
        //fetching all users if submit is done through community user. hence created a new class "without sharing" tag
    public Map<Id, User> getAllUsersHelper()
    {
        Map<Id, User> userMap = new Map<Id, User>();
        List<User> userList = [SELECT Id, Country_ISO_Code__c, ContactId, ProfileId, ManagerId FROM User
                               WHERE aop_Has_AoP_Community_Access__c = false AND IsActive = true];
        //system.debug('user list In getallusers');
        //system.debug(userList.size());
        //system.debug(userlist);
        for(User u : userList)
        {
            userMap.put(u.Id, u);
        }
        return userMap;
    }
}