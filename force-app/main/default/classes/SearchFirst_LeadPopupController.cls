public without sharing class SearchFirst_LeadPopupController extends SearchFirst_PopupController_A {//do not delete, currently unused but likely to be brough back in.  It is still (loosely) referenced in code
    public CustomLead PopupLead { get; set; }
    private CustomLead selectedLead;
    
    public SearchFirst_LeadPopupController() {
        this.PopupLead = new CustomLead ();
    }
    
    public Boolean ShowPhoneField { get {
         return (String.isEmpty(this.searchFirstController.pageController.searchParameters.Phone) || this.searchFirstController.pageController.searchParameters.Phone != this.selectedLead.Phone.Value);
    }}
    public Boolean ShowMobilePhoneField { get { 
        return ((String.isEmpty(this.searchFirstController.pageController.searchParameters.Phone) || this.searchFirstController.pageController.searchParameters.Phone != this.selectedLead.MobilePhone.Value));
    }}
    public Boolean ShowEmailField { get { 
        return String.isEmpty(this.searchFirstController.pageController.searchParameters.Email);
    }}
    

     public override PageReference MakeRecordKnown()
    {
        if(String.isNotEmpty(this.PopupLead.Phone.Value) && ShowPhoneField){
            return this.CheckFieldMatches(this.PopupLead, this.selectedLead, CustomLead.PhoneDescription);
        } 
        else if(String.isNotEmpty(this.PopupLead.MobilePhone.Value) && ShowMobilePhoneField){
            return this.CheckFieldMatches(this.PopupLead, this.selectedLead, CustomLead.MobilePhoneDescription);
        } 
        else if(String.isNotEmpty(this.PopupLead.Email.Value) && ShowEmailField){
            return this.CheckFieldMatches(this.PopupLead, this.selectedLead, CustomLead.EmailDescription);
        }
        return null;
    }
    /*
    public override PageReference MakeRecordKnown()
    {
        
        if(String.isNotEmpty(this.PopupLead.Phone)){
            return this.CheckFieldMatches(this.PopupLead, this.selectedLead, CustomLead .PhoneDescription);
        } 
        else if(String.isNotEmpty(this.PopupLead.MobilePhone)){
            return this.CheckFieldMatches(this.PopupLead, this.selectedLead, CustomLead .MobilePhoneDescription);
        }
        else if(String.isNotEmpty(this.PopupLead.Email)){
            return this.CheckFieldMatches(this.PopupLead, this.selectedLead, CustomLead .EmailDescription);
        }
        
        return null;
    }
    */
    
    
    

    public override void ShowPopup()
    {
        this.selectedLead = new CustomLead();
        
        this.selectedLead.RecordId  = ApexPages.currentPage().getParameters().get('leadId');
        //this.selectedLead.Name = ApexPages.currentPage().getParameters().get('leadName');
        this.selectedLead.Phone.Value = ApexPages.currentPage().getParameters().get('leadPhone');
        this.selectedLead.Email.Value = ApexPages.currentPage().getParameters().get('leadEmail');
        this.selectedLead.MobilePhone.Value = ApexPages.currentPage().getParameters().get('leadMobilePhone');
        
        this.SetRecordAccessAttempt(this.selectedLead.RecordId);
        this.ShowPopup = true;
    }

    public override void ClosePopup()
    {
        this.selectedLead = null;
        this.ErrorTitle = '';
        this.ErrorMessage = '';
        this.recordAccessAttempt = null;
        
        this.ShowPopup = false;
    }
    
    protected override PageReference ShareRecord()
    {
        LeadShare leadShare = new LeadShare();
        leadShare.LeadAccessLevel = 'read';
        leadShare.LeadId = selectedLead.RecordId;
        leadShare.UserOrGroupId = UserInfo.getUserId();
        insert leadShare;
        
        return new PageReference('/' + selectedLead.RecordId);
    }
}