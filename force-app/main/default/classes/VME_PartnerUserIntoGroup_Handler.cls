/*--
||      Name : VME_PartnerUserIntoGroup_Handler.apxc
||      Created By: Sumit Kumar @Marlabs Private Limited
||      Purpose : This will have the logic of when partner user got created , hence to put into india group and share QMSP L1
||      Created Date : 20/06/2019
||      Modified By:<Your Name>
||      Modified Date :<Date>
||      Reason :<Reason>
--*/
public class VME_PartnerUserIntoGroup_Handler {
        public static final String partnerLicenceName = 'Partner Community';
        public VME_PartnerUserIntoGroup_Handler() {}
        public void onAfterInsert(Map < Id, User > newUserMap, Map < Id, User > oldUserMap, List < User > newUsers, List < User > oldUsers) {
                PutUserIntoGroup(newUserMap, oldUserMap, newUsers, oldUsers);
        }
        private void PutUserIntoGroup(Map < Id, User > newUserMap, Map < Id, User > oldUserMap, List < User > newUsers, List < User > oldUsers) {
                Boolean proceed = false;
                if(newUserMap !=null && !newUserMap.isEmpty() ) {
                List < User > getMyUserList = [SELECT Id, Market__c, IsActive, UserRoleId, UserRole.Name, Profile.UserLicense.Name FROM User WHERE Id IN: newUserMap.keySet() AND ContactId != null AND Contact.AccountId != null AND Profile.UserLicense.Name = : partnerLicenceName];
                for (User usr: getMyUserList) {
                        //adding India user into India Group
                        if (usr.IsActive && usr.Market__c != null && (usr.Market__c == 'IN' || usr.Market__c == 'India')) {
                            //if any one user validated the criteriah then go for the logic. hence single time boolean check    
                            proceed = true;
                            break;//if found one valid user then break the loop and proceed for logic
                        } else {
                                //MENA coming soon
                        }
                }
            	//If any user updated meeting above conditon then run below logic
                If(proceed) {
                        List < GroupMember > groupMemberList = new List < GroupMember > ();
                        Map < String, String > market_groupName_map = new Map < String, String > ();
                        for (VME_CXP_Partner_Group_Sharing_By_Market__mdt grp: [Select id, Group_API_Name__c, Market__c from VME_CXP_Partner_Group_Sharing_By_Market__mdt]) {
                                market_groupName_map.put(grp.Market__c, grp.Group_API_Name__c);
                        }
                        Map < String, Id > groupName_sfId_map = new Map < String, Id > ();
                        //Get the groups that the user should be added to
                        List < Group > in_Group_List = [select Id, DeveloperName from Group Where DeveloperName = : market_groupName_map.values()];
                        for (Group grp: in_Group_List) {
                                groupName_sfId_map.put(grp.DeveloperName, grp.Id);
                        }
                        //get the userLicense for Partner User Check
                        // loop the users that have been created
                        for (User usr: getMyUserList) {
                                //adding India user into India Group
                                if (usr.IsActive && usr.Market__c != null && (usr.Market__c == 'IN' || usr.Market__c == 'India')) {
                                        GroupMember gm = new GroupMember();
                                        gm.GroupId = groupName_sfId_map.get(market_groupName_map.get(usr.Market__c));
                                        gm.UserOrGroupId = usr.Id;
                                        if (market_groupName_map.containsKey(usr.Market__c) && groupName_sfId_map.containsKey(market_groupName_map.get(usr.Market__c))) {
                                                groupMemberList.add(gm);
                                        }
                                } else {
                                        //MENA coming soon
                                }
                        }
                        if (!groupMemberList.isEmpty()) {
                                System.debug('Group Member List is ' + groupMemberList);
                                Insert groupMemberList;
                        }
                }
        }
}
}