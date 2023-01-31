@isTest
private class VME_PartnerUserIntoGroup_Handler_Test {
        @testSetup static void itShould() {
                // Given
                //create a user for login
                User testUser = VME_TestDataUtilityClass.createSalesforceUser();
                Insert testUser;
                // When
                // Then
        }
        public static testMethod void postiveScenario() {
                //create a user for login
                User testUser = [SELECT Id From User WHERE Name = 'JLR ADMIN' AND username='etadmin@ettestjlr.utiltest' LIMIT 1 ];
                System.runAs(testUser) {
                        System.debug('VME_PartnerUserIntoGroup_Handler_Test postiveScenario');
                        Group in_Group = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName='VME_All_Partners_India_only' LIMIT 1];
                        System.debug('Group Details :: '+in_Group);
                        //Inserting Group Partner Setting
                        //create Retailer Record
                        Account retailer = VME_TestDataUtilityClass.createRetailer();
                        Insert retailer;
                        //Create Retailer Contact
                        Contact rtCon = VME_TestDataUtilityClass.CreateRetailerContact('Retailer Contact');
                        rtCon.AccountId = retailer.id;
                        Insert rtCon;

                        //converting contact to partner user
                        Id partnerProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Executive'].id;
                        User partnerUser = new User(FirstName = 'Sumit', LastName = 'Cyrus', alias = 'test123', email = 'test123@noemail.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = partnerProfileId, country = 'United States', IsActive = true, ContactId = rtCon.Id, Market__c = 'IN', Is_Marketing_User__c = true, timezonesidkey = 'America/Los_Angeles', username = 'etuser@emailnopart.sumit');
                        Insert partnerUser;
                        //getting group member id into set for chekcing
                        Set<Id> groupMbrIdSet = new Set<Id>();
                        for(GroupMember grpMbr: [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId =: in_Group.Id]) {
                                groupMbrIdSet.add(grpMbr.UserOrGroupId);
                        }
                        System.debug('Group Member :: '+ groupMbrIdSet);
                        System.debug('partnerUser Member :: '+ partnerUser);
                        System.assertEquals(true,groupMbrIdSet.contains(partnerUser.Id),'Checking the new partner user added to VME_All_Partners_India_only Group');
                }
        }
        public static testMethod void negativeScenario() {
                //create a user for login
                User testUser =  [SELECT Id From User WHERE Name = 'JLR ADMIN' AND username='etadmin@ettestjlr.utiltest' LIMIT 1 ];
                System.runAs(testUser) {
                        System.debug('VME_PartnerUserIntoGroup_Handler_Test negativeScenario');
                        Group in_Group = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName='VME_All_Partners_India_only' LIMIT 1];
                        System.debug('Group Details :: '+in_Group);
                        //Inserting Group Partner Setting
                        //create Retailer Record
                        Account retailer = VME_TestDataUtilityClass.createRetailer();
                        Insert retailer;
                        //Create Retailer Contact
                        Contact rtCon = VME_TestDataUtilityClass.CreateRetailerContact('Retailer Contact');
                        rtCon.AccountId = retailer.id;
                        Insert rtCon;
                        Id partnerProfileId = [select id from profile where name = 'Sales Executive'].id;
                        User partnerUser = new User(FirstName = 'Sumit', LastName = 'Cyrus', alias = 'test123', email = 'test123@noemail.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = partnerProfileId, country = 'United States', IsActive = true, ContactId = rtCon.Id, Market__c = 'IN', Is_Marketing_User__c = true, timezonesidkey = 'America/Los_Angeles', username = 'etusertest@sumit.partcom');
                        Insert partnerUser;
                        partnerUser.Market__c = 'IN';
                        Update partnerUser;

                        //getting group member id into set for chekcing
                        Set<Id> groupMbrIdSet = new Set<Id>();
                        for(GroupMember grpMbr: [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId =: in_Group.Id]) {
                                groupMbrIdSet.add(grpMbr.UserOrGroupId);
                        }
                        System.debug('Group Member :: '+ groupMbrIdSet);
                        System.debug('partnerUser Member :: '+ partnerUser);
                        System.assertEquals(true,groupMbrIdSet.contains(partnerUser.Id),'Checking the updated partner user added to VME_All_Partners_India_only Group');
                }
        }
}