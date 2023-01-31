@isTest
public class SearchFirst_ContactPopupController_Test {
    static testmethod void MakeRecordKnown_ReturnsNull_GivenEmptyPhoneMobileAndEmail()
    {
        SearchFirst_ContactPopupController controller = new SearchFirst_ContactPopupController();
        controller.PopupContact = new CustomContact();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNull_GivenNonMatchingPhoneNumbers()
    {
        SearchFirst_ContactPopupController controller = BuildController();
        controller.PopupContact.Phone.Value = '1234567890';
        controller.ShowPopup();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNull_GivenMatchingPhoneNumbersAndShowPhoneFieldEqualsFalse()
    {
        SearchFirst_ContactPopupController controller = BuildController();
        controller.PopupContact.Phone.Value = '1234567890';
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('conPhone', controller.PopupContact.Phone.Value);
        controller.ShowPopup();
        
        controller.searchFirstController.pageController.searchParameters.Phone = controller.PopupContact.Phone.Value;
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNotNull_GivenMatchingPhoneNumbersAndShowPhoneFieldEqualsTrue()
    {
        SearchFirst_ContactPopupController controller = BuildController();
        
        Account account;
        System.RunAs(new User(Id=UserInfo.getUserId())){
            account = TestClass_AccountCreator.CreateRetailer();
        }
        
        controller.PopupContact.Phone.Value = '1234567890';
        
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('conPhone', controller.PopupContact.Phone.Value);
        System.currentPageReference().getParameters().put('conAccId', account.Id);
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
        SearchFirst_ContactPopupController controller = BuildController();
        controller.PopupContact.MobilePhone.Value = '1234567890';
        controller.ShowPopup();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNull_GivenMatchingMobileNumbersAndShowPhoneFieldEqualsFalse()
    {
        SearchFirst_ContactPopupController controller = BuildController();
        controller.PopupContact.MobilePhone.Value = '1234567890';
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('conMobile', controller.PopupContact.MobilePhone.Value);
        controller.ShowPopup();
        
        controller.searchFirstController.pageController.searchParameters.Phone = controller.PopupContact.MobilePhone.Value;
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNotNull_GivenMatchingMobileNumbersAndShowPhoneFieldEqualsTrue()
    {
        SearchFirst_ContactPopupController controller = BuildController();
        
        Account account;
        System.RunAs(new User(Id=UserInfo.getUserId())){
            account = TestClass_AccountCreator.CreateRetailer();
        }
        
        controller.PopupContact.MobilePhone.Value = '1234567890';
        
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('conMobile', controller.PopupContact.MobilePhone.Value);
        System.currentPageReference().getParameters().put('conAccId', account.Id);
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
        SearchFirst_ContactPopupController controller = BuildController();
        controller.PopupContact.Email.Value = '1234567890';
        controller.ShowPopup();
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNull_GivenMatchingEmailsAndShowEmailFieldEqualsFalse()
    {
        SearchFirst_ContactPopupController controller = BuildController();
        controller.PopupContact.Email.Value = '1234567890';
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('conEmail', controller.PopupContact.Email.Value);
        controller.ShowPopup();
        
        controller.searchFirstController.pageController.searchParameters.Email = controller.PopupContact.Email.Value;
        
        PageReference result = controller.MakeRecordKnown();
        
        System.assertEquals(null, result);
    }
    
    static testmethod void MakeRecordKnown_ReturnsNotNull_GivenMatchingEmailsAndShowEmailFieldEqualsTrue()
    {
        SearchFirst_ContactPopupController controller = BuildController();
        
        Account account;
        System.RunAs(new User(Id=UserInfo.getUserId())){
            account = TestClass_AccountCreator.CreateRetailer();
        }
        
        controller.PopupContact.Email.Value = '1234567890';
        
        Test.setCurrentPageReference(new PageReference(''));
        System.currentPageReference().getParameters().put('conEmail', controller.PopupContact.Email.Value);
        System.currentPageReference().getParameters().put('conAccId', account.Id);
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
        SearchFirst_ContactPopupController controller = new SearchFirst_ContactPopupController();
        controller.ShowPopup = true;
        
        controller.ClosePopup();
        
        System.assert(!controller.ShowPopup);
    }
    
    
    private static SearchFirst_ContactPopupController BuildController()
    {
        SearchFirst_ContactPopupController controller = new SearchFirst_ContactPopupController();
        
        controller.searchFirstController = new SearchFirst_ContactController();
        controller.searchFirstController.pageController = new SearchFirst_HostController();
        controller.searchFirstController.pageController.searchParameters = new SearchFirstSearchParameters();    
        
        return controller;
    }
}