public class SearchFirst_AccountPopupController extends SearchFirst_PopupController_A {//do not delete, currently unused but likely to be brough back in.  It is still (loosely) referenced in code
    public Account PopupAccount { get; set; }
    private Account selectedAccount;
	
	public SearchFirst_AccountPopupController() {
		this.PopupAccount = new Account();
	}
	

	public override PageReference MakeRecordKnown()
	{
		/*if(String.isNotEmpty(this.PopupAccount.Phone)){
			return this.CheckFieldMatches(this.PopupAccount, this.selectedAccount, Account.Phone.getDescribe());
		}*/
		return null;
	}

	public override void ShowPopup()
	{
		/*this.selectedAccount = new Account();
		
		this.selectedAccount.Id = ApexPages.currentPage().getParameters().get('accId');
		this.selectedAccount.Name = ApexPages.currentPage().getParameters().get('accName');
		this.selectedAccount.Phone = ApexPages.currentPage().getParameters().get('accPhone');		
		
		this.ShowPopup = true;*/
	}

	public override void ClosePopup()
	{
		/*this.selectedAccount = null;
		this.ShowPopup = false;
		this.ErrorTitle = '';*/
	}
	
	protected override PageReference ShareRecord()
	{
		/*AccountShare accountShare = new AccountShare();
			
		accountShare.AccountAccessLevel = 'edit';
		accountShare.AccountId = selectedAccount.Id;
		accountShare.UserOrGroupId = UserInfo.getUserId();
		accountShare.OpportunityAccessLevel = 'none';
		accountShare.CaseAccessLevel = 'none';
		
		insert accountShare;*/
		return new PageReference('/' + selectedAccount.Id);
	}
}