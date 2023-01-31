@isTest
private class ActivateUserControllerTest {
    
    
    // Success Test
    @testSetup static void createData()
    {
        CreateTestData ctd = new CreateTestData();
        ctd.loadJUDAANMarketSettingsData();
    }
    private static TestMethod void successTest(){
    
        // Preparation
        Boolean activeFlag = false;
        User u = createTestDataOnActivateUser(activeFlag);
        ApexPages.CurrentPage().getParameters().put('id', u.Id);
        ApexPages.CurrentPage().getParameters().put('lang', 'ja');
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
		ApexPages.CurrentPage().getParameters().put('brand', 'jaguar');
		Test.StartTest();
        ActivateUserController auc = new ActivateUserController();
        User usr = [ SELECT Id FROM User WHERE Id =: userInfo.getUserId() ];
        system.runAs(usr){
            // Start Test
           
            auc.activateUser();
           
        } 
        Test.StopTest();
        // Result confirmation
        System.assertEquals(null, auc.errorMsg);
        
    }
    
    // Not Fountd User Error Test
    private static TestMethod void notFoundUserTest(){
    
        // Preparation
        ApexPages.CurrentPage().getParameters().put('id', 'XXXXXXXXXXXXXXXXXX');
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
		 ApexPages.CurrentPage().getParameters().put('brand', 'jaguar');
        ActivateUserController auc = new ActivateUserController();
        
        // Start Test
        Test.StartTest();
        auc.activateUser();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.Activate_User_Error_Message, auc.errorMsg);
        
    }
    
    // Page Expired Error Test
    private static TestMethod void pageExpiredTest(){
    
        // Preparation
        Boolean activeFlag = false;
        User u = createTestDataOnActivateUser(activeFlag);
        ApexPages.CurrentPage().getParameters().put('id', u.Id);
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
		ApexPages.CurrentPage().getParameters().put('brand', 'jaguar');
        //JPVME in vme but not source ApexPages.CurrentPage().getParameters().put('brand', 'bmw');
        ActivateUserController.availabilityTime = -1;
        ActivateUserController auc = new ActivateUserController();
        
        // Start Test
        Test.StartTest();
        auc.activateUser();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.Activate_User_Expired_Error_Message, auc.errorMsg);
        
    }
    
    // Already Activated Test
    private static TestMethod void alreadyActivatedTest(){
    
        // Preparation
        Boolean activeFlag = true;
        User u = createTestDataOnActivateUser(activeFlag);
        ApexPages.CurrentPage().getParameters().put('id', u.Id);
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
		ApexPages.CurrentPage().getParameters().put('brand', 'jaguar');
        ActivateUserController auc = new ActivateUserController();
        
        // Start Test
        Test.StartTest();
        auc.activateUser();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(null, auc.errorMsg);
        
    }
    
    // Unexprcted Error Test
    private static TestMethod void unExpectedErrorTest(){
    
        // Preparation
        Boolean activeFlag = false;
        User u = createTestDataOnActivateUser(activeFlag);
        ApexPages.CurrentPage().getParameters().put('id', u.Id);
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        ActivateUserController auc = new ActivateUserController();
        
        // Start Test
        Test.StartTest();
        auc.activateUser();
        Test.StopTest();
            
        // Result confirmation 
        //System.assertEquals(Label.Activate_User_Error_Message,auc.errorMsg);
        
    }
    
    // Create Test Data Method
    private static User createTestDataOnActivateUser(Boolean act){
        CreateTestData ctd = new CreateTestData();
            User usrAdmin = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
                Account acc;
                Lead l;
                User u;
                System.runAs(usrAdmin) {
         acc = ctd.createPersonalAccount();
        insert acc;

        system.assertEquals('TestFirstName', acc.LastName);
		system.assertEquals('TestLastName', acc.FirstName);
        system.assertEquals('testCommunityUser@jlr.com', acc.PersonEmail);
        
         l = ctd.createLead(acc);
        insert l;
        
        system.assertEquals('TestFirstName', l.LastName);
		system.assertEquals('TestLastName', l.FirstName);
        system.assertEquals('testCommunityUser@jlr.com', l.Email);
        
         u = ctd.createCustomerCommunityUser(acc);
        
        if(act){
            u.Udaan_Active__c = true;
        }else{
            u.isActive = false;
            u.Udaan_Active__c = false;
        } 

        insert u;
                }
        system.assert(  u.Username.contains('testCommunityUser@jlr.com') );
        system.assertEquals('testCommunityUser@jlr.com', u.Email);
        Contact con = [Select id from contact Where AccountId = :acc.Id Limit 1];
        system.assertEquals(con.Id, u.ContactId);
   
        return u;
        
        
    }
  
    
}