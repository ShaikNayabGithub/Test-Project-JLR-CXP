public without sharing class SearchFirst_ContactPopupController extends SearchFirst_PopupController_A {
    public CustomContact PopupContact { get; set; }
    private CustomContact selectedContact;
    
    public Boolean ShowPhoneField { get {
         return (String.isEmpty(this.searchFirstController.pageController.searchParameters.Phone) || this.searchFirstController.pageController.searchParameters.Phone != this.selectedContact.Phone.Value);
    }}
    public Boolean ShowMobilePhoneField { get { 
        return ((String.isEmpty(this.searchFirstController.pageController.searchParameters.Phone) || this.searchFirstController.pageController.searchParameters.Phone != this.selectedContact.MobilePhone.Value));
    }}
    public Boolean ShowEmailField { get { 
        return String.isEmpty(this.searchFirstController.pageController.searchParameters.Email);
    }}
    
    
    public SearchFirst_ContactPopupController() {
        this.PopupContact = new CustomContact();
    }
    

    public override PageReference MakeRecordKnown()
    {
        if(String.isNotEmpty(this.PopupContact.Phone.Value) && ShowPhoneField){
            return this.CheckFieldMatches(this.PopupContact, this.selectedContact, CustomContact.PhoneDescription);
        } 
        else if(String.isNotEmpty(this.PopupContact.MobilePhone.Value) && ShowMobilePhoneField){
            return this.CheckFieldMatches(this.PopupContact, this.selectedContact, CustomContact.MobilePhoneDescription);
        } 
        else if(String.isNotEmpty(this.PopupContact.Email.Value) && ShowEmailField){
            return this.CheckFieldMatches(this.PopupContact, this.selectedContact, CustomContact.EmailDescription);
        }
        return null;
    }

    public override void ShowPopup()
    {
        this.PopupContact.FirstName.Value = ApexPages.currentPage().getParameters().get('conName');
        
        this.selectedContact = new CustomContact();
        
        this.selectedContact.RecordId = ApexPages.currentPage().getParameters().get('conId');
        this.selectedContact.Phone.Value = ApexPages.currentPage().getParameters().get('conPhone');
        this.selectedContact.Email.Value = ApexPages.currentPage().getParameters().get('conEmail');
        this.selectedContact.MobilePhone.Value = ApexPages.currentPage().getParameters().get('conMobile');    
        this.selectedContact.AccountId.Value = ApexPages.currentPage().getParameters().get('conAccId');   
        
        this.SetRecordAccessAttempt(this.selectedContact.RecordId);
        this.ShowPopup = true;
    }

    public override void ClosePopup()
    {
        this.selectedContact = null;
        this.ErrorTitle = '';
        this.ErrorMessage = '';
        this.recordAccessAttempt = null;
        
        this.ShowPopup = false;
    }
    
    protected override PageReference ShareRecord()
    {
        AccountShare parentShare = new AccountShare();
        
        parentShare.AccountAccessLevel = 'edit';
        parentShare.OpportunityAccessLevel = 'none';
        parentShare.CaseAccessLevel = 'none';
        parentShare.AccountId = (Id)this.selectedContact.AccountId.Value;
        
        parentShare.UserOrGroupId = UserInfo.getUserId();
        
        insert parentShare;
        this.StoreShareSetting(parentShare.Id);
        if(this.recordAccessAttempt != null){
        	delete recordAccessAttempt;
        }
        return new PageReference('/' + selectedContact.RecordId);
    }
}