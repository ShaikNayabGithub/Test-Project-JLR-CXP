@isTest
public class LCConvertAccountType_ControllerTest {
    static TestMethod void convertRecordTypeTest(){       
          User portaluser = TestUtility.createPortaluser('India','Sales Executive');     
        System.RunAs(portaluser){
               insert new TriggerFramework__c(Is_Enable_Primary_Account_Creation__c = true);
           Account account = TestUtility.createIndividualAccount();
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            LCConvertAccountType_Controller.convertRecordType(account.Id);
            LCConvertAccountType_Controller.getAccount(account.Id);            
            LCConvertAccountType_Controller.convertRecordType(account.Id);
        }
        
    }

}