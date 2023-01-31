@isTest
@TestVisible
private class ResetPasswordControllerTest {
    
    // Success Test
    @testSetup static void createData()
    {
        CreateTestData ctd = new CreateTestData();
        ctd.loadJUDAANMarketSettingsData();
    }
    private static testMethod void successTest(){
        
        // Preparation
        User u = createTestDataOnChangePassword();
        ApexPages.CurrentPage().getParameters().put('id', u.Id); //SiteCrypto.EncryptIdHex(u.Id));
        ApexPages.CurrentPage().getParameters().put('lang', 'ja');
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
		ApexPages.CurrentPage().getParameters().put('brand', 'landrover');
        ResetPasswordController ctrl = new ResetPasswordController();
        ctrl.password = 'PASSWORD1234';
        ctrl.confirmPassword = 'PASSWORD1234';
        
        // Start Test
        Test.StartTest();
        ctrl.init();
        ctrl.changePassword();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals('', ctrl.errorMessage);
    }
    
    // Unknown User Error Test In Constractor Class
    private static testMethod void unknownUserTestInConstructor(){
        
        // Preparation
        ApexPages.CurrentPage().getParameters().put('id', 'XXXXXXXXXXXXXXXXXX');
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        ApexPages.CurrentPage().getParameters().put('brand', 'landroverJaguar');
        // Start Test
        Test.StartTest();
        ResetPasswordController ctrl = new ResetPasswordController();
        ctrl.init();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.ChangePassword_Failed_Error_Message, ctrl.errorMessage);
    }
    
    // Change Password Page Expired Error Test
    private static testMethod void passwordPageExpiredTest(){
        
        // Preparation
        User u = createTestDataOnChangePassword();
        ApexPages.CurrentPage().getParameters().put('id',  u.Id); //SiteCrypto.EncryptIdHex(u.Id));
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        ResetPasswordController.availabilityTime = -1;
        
        // Start Test
        Test.StartTest();
        ResetPasswordController ctrl = new ResetPasswordController();
        ctrl.init();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.Change_Password_Page_Expired_Error_Message, ctrl.errorMessage);
    }
    
    // Password Required Error Test
    private static testMethod void passwordRequiredTest(){
        
        // Preparation
        User u = createTestDataOnChangePassword();
        ApexPages.CurrentPage().getParameters().put('id',  u.Id); //SiteCrypto.EncryptIdHex(u.Id));
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        ResetPasswordController ctrl = new ResetPasswordController();
        ctrl.password = 'PASSWORD';
        ctrl.confirmPassword = null;
        
        // Start Test
        Test.StartTest();
        ctrl.init();
        ctrl.changePassword();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.Not_Input_Error_Message, ctrl.errorMessage);
    }
    
    // Password Mismatch Error Test
    private static testMethod void passwordMismatchTest(){
        
        // Preparation
        User u = createTestDataOnChangePassword();
        ApexPages.CurrentPage().getParameters().put('id',  u.Id); //SiteCrypto.EncryptIdHex(u.Id));
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        ResetPasswordController ctrl = new ResetPasswordController();
        ctrl.password = 'PASSWORD';
        ctrl.confirmPassword = 'COMFIRMPASSWORD';
        
        // Start Test
        Test.StartTest();
        ctrl.init();
        ctrl.changePassword();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.Password_Mismatch_Error_Message, ctrl.errorMessage);
    }
    
    // Password Policy Error Test
    private static testMethod void passwordPolicyTest(){
        
        // Preparation
        User u = createTestDataOnChangePassword();
        ApexPages.CurrentPage().getParameters().put('id',  u.Id); //SiteCrypto.EncryptIdHex(u.Id));
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        ResetPasswordController ctrl = new ResetPasswordController();

        ctrl.password = 'PASS';
        ctrl.confirmPassword = 'PASS';
        
        // Start Test
        Test.StartTest();
        ctrl.init();
        ctrl.changePassword();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.Password_Policy_Error_Message, ctrl.errorMessage);
    }
    
    //  Unknown User Error Test In changePassword Method
    private static testMethod void unknownUserTestInchangePassword(){
        
        // Preparation
        ApexPages.CurrentPage().getParameters().put('id', 'XXXXXXXXXXXXXXXXXX');
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        // Start Test
        Test.StartTest();
        ResetPasswordController ctrl = new ResetPasswordController();
        ctrl.init();
        ctrl.changePassword();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.ChangePassword_Failed_Error_Message, ctrl.errorMessage);
    }
    
    // Unexpected Error Test
    private static testMethod void unExpectedErrorTest(){
        
        // Preparation
        User u = createTestDataOnChangePassword();
        ApexPages.CurrentPage().getParameters().put('id',  u.Id); //SiteCrypto.EncryptIdHex(u.Id));
        ApexPages.CurrentPage().getParameters().put('market', 'jp');
        ResetPasswordController ctrl = new ResetPasswordController();
        ctrl.userList = null;
        
        // Start Test
        Test.StartTest();
        ctrl.changePassword();
        Test.StopTest();
        
        // Result confirmation
        System.assertEquals(Label.ChangePassword_Failed_Error_Message, ctrl.errorMessage);
    }
    
    // Create Test Data Method
    private static User createTestDataOnChangePassword(){
        CreateTestData ctd = new CreateTestData();
        Account acc = ctd.createPersonalAccount();
        insert acc;
        Lead l = ctd.createLead(acc);
        insert l;
        User u = ctd.createCustomerCommunityUser(acc);
        u.Udaan_Active__c = true;
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert u;
        }
        return u;
    }
}