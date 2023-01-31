public without sharing class SearchFirst_AssetPopupController extends SearchFirst_PopupController_A {
    public CustomAccount PopupAccount { get; set; }
    private CustomAccount selectedAccount;
    private CustomAsset selectedAsset;
    
    
    public SearchFirst_AssetPopupController() {
        this.PopupAccount = new CustomAccount();
    }
    

    public override PageReference MakeRecordKnown()
    {
        if(String.isNotEmpty(this.PopupAccount.Phone.Value)){
            return this.CheckFieldMatches(this.PopupAccount, this.selectedAccount, CustomAccount.PhoneDescription);
        } 
        else if(String.isNotEmpty(this.PopupAccount.PersonMobilePhone.Value)){
            return this.CheckFieldMatches(this.PopupAccount, this.selectedAccount, CustomAccount.PersonMobilePhoneDescription);
        } 
        else if(String.isNotEmpty(this.PopupAccount.PersonEmail.Value)){
            return this.CheckFieldMatches(this.PopupAccount, this.selectedAccount, CustomAccount.PersonEmailDescription);
        }
        return null;
    }

    public override void ShowPopup()
    {
        this.selectedAsset = new CustomAsset();
        this.selectedAccount = new CustomAccount();
        
        this.selectedAsset.RecordId = ApexPages.currentPage().getParameters().get('assetId');
        this.selectedAccount.RecordId = ApexPages.currentPage().getParameters().get('accountId');
        this.selectedAccount.Phone.Value = ApexPages.currentPage().getParameters().get('homePhone');
        this.selectedAccount.PersonEmail.Value = ApexPages.currentPage().getParameters().get('email');
        this.selectedAccount.PersonMobilePhone.Value = ApexPages.currentPage().getParameters().get('mobile');
        
        this.SetRecordAccessAttempt(this.selectedAccount.RecordId);
        this.ShowPopup = true;
    }

    public override void ClosePopup()
    {
        this.selectedAccount = null;
        this.selectedAsset = null;
        this.ErrorTitle = '';
        this.ErrorMessage = '';
        this.recordAccessAttempt = null;
        
        this.ShowPopup = false;
    }
    
    protected override PageReference ShareRecord()
    {
        AccountShare parentShare = new AccountShare();
        
        parentShare.AccountId = this.selectedAccount.RecordId;   
        parentShare.AccountAccessLevel = 'edit';
        parentShare.OpportunityAccessLevel = 'none';
        parentShare.CaseAccessLevel = 'none';   
        parentShare.UserOrGroupId = UserInfo.getUserId();
        
        insert parentShare;
        this.StoreShareSetting(parentShare.Id);
        if(this.recordAccessAttempt != null){
            delete recordAccessAttempt;
        }
        return new PageReference('/' + selectedAsset.RecordId);
    }
}