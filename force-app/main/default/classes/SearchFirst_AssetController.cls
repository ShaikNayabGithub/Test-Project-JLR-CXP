public without sharing class SearchFirst_AssetController extends SearchFirst_Controller_A {
    public List<Asset> knownAssets { get; private set; }
    public List<Asset> unknownAssets { get; private set; }
    
    public SearchFirst_AssetController()
    {
        this.knownAssets = new List<Asset>();
        this.unknownAssets = new List<Asset>();
    }
    

    public override void Search()
    {
        String whereClause = '';
        moreRecords = false;
        whereClause = this.AddTowhereClause(whereClause, new String[] {'VIN__c', 'Short_VIN__c', 'Registration_Number__c'}, 
            'AssetIdentifier', pageController.searchParameters.AssetIdentifier);
        if(String.isEmpty(whereClause)){ return; }
        
        String AssetIdentifier = pageController.searchParameters.AssetIdentifier;
        String query = String.Format('Select VIN__c, Short_VIN__c, Registration_Number__c, AccountId, Account.IsPersonAccount, Account.PersonMobilePhone, Account.Phone, Account.PersonEmail From Asset Where {0}', new List<string> {whereClause});
        query += ' LIMIT ' + (this.MAXRESULTS + 1);
        
        List<sObject> foundAssets = Database.query(query);
            
        Set<Id> assetsWithReadAccess = this.GetRecordsWithReadAccess(foundAssets);
        
        if(!moreRecords){
	        for(sObject foundObject : foundAssets){
    	        Asset foundAsset = (Asset)foundObject;
            	if(assetsWithReadAccess.contains(foundAsset.Id)){
  	              knownAssets.add(foundAsset);
    	        } else {
        	        if(foundAsset.Account.IsPersonAccount){
	        	    	unknownAssets.add(foundAsset);
                	}
            	}
            }
        }
    }

    public override void Reset()
    {
        knownAssets.clear();
        unknownAssets.clear();
        moreRecords = false;
    }

    public override PageReference CreateRecord()
    {
        PageReference pageRef = new PageReference('/02i/e?retURL=%2F02i%2Fo' + ((String.isNotEmpty(pageController.searchParameters.RecordTypeId) && pageController.searchParameters.RecordTypeObject == Asset.sObjectType.getDescribe().getName())? '&RecordType='+pageController.searchParameters.RecordTypeId : ''));/*+ (pageController.searchParameters.Firstname != null?'&name_firstcon2='+ pageController.searchParameters.Firstname : '') + 
            (pageController.searchParameters.Lastname != null?'&name_lastcon2='+ pageController.searchParameters.Lastname : '') + 
            (pageController.searchParameters.Phone != null?'&con10='+ pageController.searchParameters.Phone : '') + 
            (pageController.searchParameters.Email != null?'&con15='+ pageController.searchParameters.Email : '') + (String.isNotEmpty(pageController.searchParameters.RecordTypeId)? '&RecordType='+pageController.searchParameters.RecordTypeId : ''));*/
        pageRef.getParameters().put('nooverride','1');
        return pageRef;
    }
}