@isTest
public class JLREventOnAccountControllerTest {
 static TestMethod void getActivityListTest(){       
          User portaluser = TestUtility.createPortaluser('India','Sales Executive');     
        System.RunAs(portaluser){
               insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);
           Account account = TestUtility.createIndividualAccount();
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            List<Task> activitiesList = new List<Task>();
                activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today() , Visible_to_Retailer__c = true, WhatId=account.id ));
                activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today().addDays(-1), Visible_to_Retailer__c = true, WhatId=account.id));
            insert activitiesList;
            JLREventOnAccountController.getActivityList(account.Id);
            JLREventOnAccountController.getActivityList([Select Primary_Account__c FROM Account Where Id=:account.Id].Primary_Account__c);
        }
        
    }
}