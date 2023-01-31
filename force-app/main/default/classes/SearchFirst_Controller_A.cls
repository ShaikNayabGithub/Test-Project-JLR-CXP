public without sharing abstract class SearchFirst_Controller_A {
    public SearchFirst_PopupController_A popupController { get; set; }
    public SearchFirst_Controller_A getThis() { return this; }
    
	public final Integer MAXRESULTS = 200;
	public boolean moreRecords {get; set;}
    
    public SearchFirst_HostController pageController { get; 
        set {
            if (value != null) {
                pageController = value;
                if(!pageController.objectControllers.contains(this)){
                    pageController.objectControllers.add(this);
                }
            } 
        }
    }
    
    public abstract void Search();
    public abstract void Reset();
    public abstract PageReference CreateRecord();
    
    protected Set<Id> GetRecordsWithReadAccess(List<sObject> allRecords)
    {
        Set<Id> foundIds = new Set<Id>();
        Set<Id> readableRecords = new Set<Id>();

        for(sObject record : allRecords){
        	foundIds.add(record.Id);
        }
        if(foundIds.size() > this.MAXRESULTS){
        	moreRecords = true;
        	return readableRecords;
        }
        
        List<UserRecordAccess> recordsWithReadAccess = [Select RecordId from UserRecordAccess where UserId = :UserInfo.getUserId() and RecordId IN :foundIds and HasReadAccess = true];
        for (UserRecordAccess accessRecord : recordsWithReadAccess) {
            readableRecords.add(accessRecord.RecordId);
        }
        
        return readableRecords;
    }
    
    protected String AddTowhereClause(String whereClause, String[] fieldNames, String variableName, String value)
    {
        if(String.isNotEmpty(value)){
            if(String.isNotEmpty(whereClause)) { whereClause += ' And '; }
            whereClause += String.format('( {0}=:{1}', new String[]{fieldNames[0], variableName});
            for (integer i = 1; i < fieldNames.size(); i++){
                whereClause += String.format(' Or {0}=:{1}', new String[]{fieldNames[i], variableName});
            }
            whereClause += ' )';
        }
        return whereClause;
    }
}