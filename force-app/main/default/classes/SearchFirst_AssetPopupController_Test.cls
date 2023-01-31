@isTest
public class SearchFirst_AssetPopupController_Test {
    static testmethod void MakeRecordKnown_ReturnsNull_GivenEmptyParameters()
    {
        SearchFirst_AssetPopupController controller = new SearchFirst_AssetPopupController();
        controller.PopupAccount = new CustomAccount();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNull_GivenNonMatchingHomePhoneNumbers()
    {
        SearchFirst_AssetPopupController controller = BuildController();
        controller.PopupAccount.PersonHomePhone.Value = '1234567890';
        controller.ShowPopup();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNotNull_GivenPhoneNumbers()
    {
        SearchFirst_AssetPopupController controller = BuildController();
        
        Account account;
        System.RunAs(new User(Id=UserInfo.getUserId())){
            account = TestClass_AccountCreator.CreateRetailer();
        }
        
        controller.PopupAccount.Phone.Value = '1234567890';
        
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('homePhone', controller.PopupAccount.Phone.Value);
        System.currentPageReference().getParameters().put('accountId', account.Id);
        System.currentPageReference().getParameters().put('assetId', account.Id);
        controller.ShowPopup();
            
        
        PageReference result;
        User newUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
        System.runAs(newUser){
            result = controller.MakeRecordKnown();
        }
        
        System.assertNotEquals(null, result);
    }
    
    
    static testmethod void MakeRecordKnown_ReturnsNull_GivenNonMatchingMobileNumbers()
    {
        SearchFirst_AssetPopupController controller = BuildController();
        controller.PopupAccount.PersonMobilePhone.Value = '1234567890';
        controller.ShowPopup();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNotNull_GivenMatchingMobileNumbers()
    {
        SearchFirst_AssetPopupController controller = BuildController();
        
        Account account;
        System.RunAs(new User(Id=UserInfo.getUserId())){
            account = TestClass_AccountCreator.CreateRetailer();
        }
        
        controller.PopupAccount.PersonMobilePhone.Value = '1234567890';
        
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('mobile', controller.PopupAccount.PersonMobilePhone.Value);
        System.currentPageReference().getParameters().put('accountId', account.Id);
        System.currentPageReference().getParameters().put('assetId', account.Id);
        controller.ShowPopup();
            
        
        PageReference result;
        User newUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
        System.runAs(newUser){
            result = controller.MakeRecordKnown();
        }
        
        System.assertNotEquals(null, result);
    }
    
    
    static testmethod void MakeRecordKnown_ReturnsNull_GivenNonMatchingEmails()
    {
        SearchFirst_AssetPopupController controller = BuildController();
        controller.PopupAccount.PersonEmail.Value = '1234567890';
        controller.ShowPopup();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNotNull_GivenMatchingEmails()
    {
        SearchFirst_AssetPopupController controller = BuildController();
        
        Account account;
        System.RunAs(new User(Id=UserInfo.getUserId())){
            account = TestClass_AccountCreator.CreateRetailer();
        }
        
        controller.PopupAccount.PersonEmail.Value = '1234567890';
        
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('email', controller.PopupAccount.PersonEmail.Value);
        System.currentPageReference().getParameters().put('accountId', account.Id);
        System.currentPageReference().getParameters().put('assetId', account.Id);
        controller.ShowPopup();
            
        
        PageReference result;
        User newUser = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'Delegated NSC Administrator' limit 1][0]);
        System.runAs(newUser){
            result = controller.MakeRecordKnown();
        }
        
        System.assertNotEquals(null, result);
    }
    
    
    static testmethod void ClosePopup_SetsShowPopupToFalse_WhenCalled()
    {
        SearchFirst_AssetPopupController controller = new SearchFirst_AssetPopupController();
        controller.ShowPopup = true;
        
        controller.ClosePopup();
        
        System.assert(!controller.ShowPopup);
    }
    
    
    private static SearchFirst_AssetPopupController BuildController()
    {
        SearchFirst_AssetPopupController controller = new SearchFirst_AssetPopupController();
        
        controller.searchFirstController = new SearchFirst_AssetController();
        controller.searchFirstController.pageController = new SearchFirst_HostController();
        controller.searchFirstController.pageController.searchParameters = new SearchFirstSearchParameters();    
        
        return controller;
    }
}