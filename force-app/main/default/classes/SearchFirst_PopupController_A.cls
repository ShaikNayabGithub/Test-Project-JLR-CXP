public without sharing abstract class SearchFirst_PopupController_A {
    public Boolean ShowPopup { get; set; }
    public String ErrorTitle { get; protected set; }
    public String ErrorMessage { get; protected set; }
    
    public SearchFirst_Controller_A searchFirstController { get; 
        set {
            if (value != null) {
                searchFirstController = value;
                searchFirstController.popupController = this;
            } 
        }
    }
    
    public boolean isAccessAvailable { get; 
    	private set {
	    	isAccessAvailable = value;
	    	if(!value){
	    		this.SetErrorMessage();
	    	}	
    	} 
    }
    
    protected RecordAccessAttempts__c recordAccessAttempt;


    public abstract PageReference MakeRecordKnown();
    public abstract void ShowPopup();
    public abstract void ClosePopup();
    protected abstract PageReference ShareRecord();
    
    
    protected PageReference CheckFieldMatches(CustomSObject userInput, CustomSObject record, Schema.DescribeFieldResult field)
    {
    	String fieldName = field.getName();
        if(userInput.Fields.get(fieldName).Value == record.Fields.get(fieldName).Value){
            return ShareRecord();
        }
        this.ErrorTitle = System.Label.Incorrect + ' ' + field.getLabel();
        
        String attemptsName = record.RecordId + '_' + UserInfo.getUserId();
        if(this.recordAccessAttempt == null){
        	this.recordAccessAttempt = new RecordAccessAttempts__c();
        	this.recordAccessAttempt.Name = attemptsName;
        	this.recordAccessAttempt.NumberOfAttempts__c = 1;
        }
        else {
        	this.recordAccessAttempt.NumberOfAttempts__c++;
        	this.isAccessAvailable = (this.recordAccessAttempt.NumberOfAttempts__c < 3);
        }
        upsert this.recordAccessAttempt;
        this.SetErrorMessage();
        return null;
    }
    
    protected void StoreShareSetting(Id shareRecordId)
    {
        ObjectShareRecord__c objectShareRecord = new ObjectShareRecord__c(Name=shareRecordId,Created_Date__c=DateTime.now());
        objectShareRecord.Name = shareRecordId;
        objectShareRecord.Created_Date__c = DateTime.now();
        insert objectShareRecord;
    }
    
    protected void SetRecordAccessAttempt(Id recordId)
    {
    	String attemptsName = recordId + '_' + UserInfo.getUserId();
        this.recordAccessAttempt = RecordAccessAttempts__c.getInstance(attemptsName);
    	this.isAccessAvailable = (recordAccessAttempt == null || recordAccessAttempt.NumberOfAttempts__c < 3);
    }
    
    private void SetErrorMessage()
    {
    	if(String.isEmpty(this.ErrorTitle)){
    		this.ErrorTitle = System.Label.AccessBlocked;
    	}
    	
    	if(recordAccessAttempt.NumberOfAttempts__c < 3){
    		this.ErrorMessage = String.Format(System.Label.sfAttemptsRemaining, new List<String>{ String.valueOf(3 - recordAccessAttempt.NumberOfAttempts__c) });
    	} 
    	else {
    		this.ErrorMessage = System.Label.sfNoAttemptsRemaining;
    	}
    }
}