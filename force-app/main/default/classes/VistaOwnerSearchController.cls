public with sharing class VistaOwnerSearchController {
	
	public String modelId {get; set;}
	public String modelName {get; set;}
	public String ownershipFrom {get; set;}
	public String ownershipTo {get; set;}
	private String fromDate;
	private String toDate;
	public String channelPreference {get; set;}
	public String campaignId {get; set;}
	public String campaignName {get; set;}
	public String country {get; set;}
	
	private ApexPages.StandardSetController setCon;
	private Integer maxResults = 100; //per page - max 5000 in total
	private String campaignMembersQuery;
	private Integer maxCampaignMembers = 5000;
	public Integer numSearchResults {get; set;}
	
	public List<String> FeatureNames {get; set;}
	public Map<String, List<SelectOption>> FeaturePicklists {get; set;}
	public Map<String, String> FeatureValues {get; set;}
	public Map<String, String> FeatureLabels {get; set;}
	
    public VistaOwnerSearchController(){
    	/*if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().containsKey('model')){
    		modelId = ApexPages.currentPage().getParameters().get('model');
    		modelName = [SELECT Name FROM Product2 WHERE Id = :modelId].Name;
    	}*/
    	numSearchResults = 0;
    	CreateFeatures();
    }
    
    public void Search(){
    	numSearchResults = 0;
    	setCon = null;
    	if(IsSearchCriteriaValid()){
	  		setCon = new ApexPages.StandardSetController(Database.getQueryLocator(BuildSearchQuery()));
    		setCon.setPageSize(maxResults);
    		numSearchResults = setCon.getResultSize();
    		if(numSearchResults == 0){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Stock_Search_No_Results));
    		}
    	}
    }
    
    public boolean IsSearchCriteriaValid(){
    	Integer monthsFrom = 0;
    	Integer monthsTo = 0;
		try{
			fromDate = null;
			if(String.IsNotBlank(ownershipFrom)){
				monthsFrom = Integer.valueOf(ownershipFrom);
				Date dtFrom = Date.today().addMonths(0-monthsFrom);
				fromDate = String.valueOf(dtFrom);
				fromDate = fromDate.substring(0, 10);
			}
			if(String.IsNotBlank(ownershipTo)){
				monthsTo = Integer.valueOf(ownershipTo);
				Date dtTo = Date.today().addMonths(0-monthsTo);
				toDate = String.valueOf(dtTo);
				toDate = toDate.substring(0, 10);
			}
			if(String.IsNotBlank(ownershipFrom) && String.IsNotBlank(ownershipTo)){
				if(monthsFrom > monthsTo){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Vista_Ownership_Fields_Inverted));
					return false;
				}
			}
		}
		catch(TypeException e){
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Vista_Ownership_Fields_Numeric));
		    return false;
		}
		return true;
    }
    
    public String BuildSearchQuery(){
    	String searchCriteria = '';
    	if(String.IsNotBlank(modelId)){
    		searchCriteria += ' AND Vehicle__r.Model__c = \'' + modelId +  '\'';
    	}
    	if(String.IsNotBlank(fromDate)){
    		searchCriteria += ' AND Role_Created__c < ' + fromDate;
    	}
    	if(String.IsNotBlank(toDate)){
    		searchCriteria += ' AND Role_Created__c > ' + toDate;
    	}
    	if(String.IsNotBlank(channelPreference)){
    		searchCriteria += ' AND Account__r.' + channelPreference + ' = false'; //field on Account is 'opt out' so only show results where this is false
    	}
    	else{
    		searchCriteria += ' AND (Account__r.PersonHasOptedOutOfEmail = false OR Account__r.PersonDoNotCall = false OR Account__r.Direct_Mail_Opt_Out__pc = false)';
    	}
    	if(String.IsNotBlank(country)){
    		searchCriteria += ' AND Account__r.Country_ISO_Code__c = \'' + country + '\'';
    	}
    	String whereClause = ' Vehicle__c != NULL AND Account__c != NULL AND Account__r.IsPersonAccount = true AND Role__c = \'Current Owner\'';
    	if(String.IsNotBlank(searchCriteria)){
    		whereClause += searchCriteria;
    	}
    	whereClause += BuildFeaturesQuery();
    	String searchQuery = 'SELECT Account__c, Account__r.PersonContactId, Account__r.Firstname, Account__r.Lastname, Account__r.Name, Account__r.BillingCity, Account__r.BillingPostalCode, Vehicle__c, Vehicle__r.Name, Vehicle__r.Model__r.Name, Role_Created__c';
    	for(String feature : FeatureNames){
    		searchQuery += ', Vehicle__r.' + feature;
    	}
    	searchQuery += String.Format(' FROM Role__c WHERE {0} ORDER BY Vehicle__r.Name LIMIT 5000', new List<String>{whereClause});
    	campaignMembersQuery = String.Format('SELECT Account__r.PersonContactId FROM Role__c WHERE {0}', new List<String>{whereClause});
    	System.debug('Query: ' +  searchQuery);
    	return searchQuery;
    }
    
    public String BuildFeaturesQuery(){//change here
    	String featuresQuery = '';
    	for(String feature : FeaturePicklists.keySet()){
    		String[] values = FeatureValues.get(feature).split(',');
    		String subQuery = '';
    		for(String selectedValue : values){
    			selectedValue = selectedValue.replace('[', '');
    			selectedValue = selectedValue.replace(']', '');
    			selectedValue = selectedValue.trim();
    			if(String.IsNotBlank(selectedValue)){
	    			if(String.IsNotBlank(subQuery)){
    					subQuery += ' OR ';
    				}
    				subQuery += 'toLabel(Vehicle__r.' + feature + ')=\'' + selectedValue + '\'';
    			}
    		}
    		if(String.IsNotBlank(subQuery)){
    			featuresQuery += ' AND (' + subQuery  + ')';
    		}
    	}
    	return featuresQuery;
    }
    
    public List<Role__c> getSearchResults(){
    	if(setCon == null){
    		return null;
    	}
    	List<Role__c> results = (List<Role__c>)setCon.getRecords();
    	return (List<Role__c>)setCon.getRecords();
    }
    
    public boolean getHasNextPage(){
    	if(setCon != null){
    		return setCon.getHasNext();
    	}
    	return false;
    }
    
    public boolean getHasPreviousPage(){
    	if(setCon != null){
    		return setCon.getHasPrevious();
    	}
    	return false;
    }
    
    public void ShowNextPage(){
    	if(setCon != null){
    		setCon.next();
    	}
    }
    
    public void ShowPreviousPage(){
    	if(setCon != null){
    		setCon.previous();
    	}
    }
    
    public void ShowFirstPage(){
    	if(setCon != null){
    		setCon.first();
    	}
    }
    
    public void ShowLastPage(){
    	if(setCon != null){
    		setCon.last();
    	}
    }
    
    public Integer getCurrentPage(){
    	if(setCon != null){
    		return setCon.getPageNumber();
    	}
    	return 0;
    }
    
    public Integer getTotalPages(){
    	if(setCon != null){
    		return (Integer)(Math.ceil((Double)setCon.getResultSize()/(Double)setCon.getPageSize()));
    	}
    	return 0;
    }
    
    public String getCurrentPageOfTotalPages(){
    	return String.format(System.Label.Vista_Page_of_Pages, new List<String>{''+getCurrentPage(), ''+getTotalPages()});
    }
    
    public void CreateFeatures(){
    	FeatureNames = new List<String>();
    	FeaturePicklists = new Map<String, List<SelectOption>>();
    	FeatureValues = new Map<String, String>();
		FeatureLabels = new Map<String, String>();
		Map<String, BRS_FeatureGroupFieldMappingByCode__c> featureGroups = BRS_FeatureUtilities.FeatureGroupFieldMappingByCode;
    	for(String s : featureGroups.keySet()){
    		String featureName = featureGroups.get(s).Field_Name__c;
    		if(String.IsNotBlank(featureName) && !featureName.endsWith('__c')){
    			featureName += '__c';
    		}
    		Map<String, Schema.SObjectField> assetFields = Asset.getSObjectType().getDescribe().fields.getMap();
    		if(assetFields.containsKey(featureName)){
    			Schema.DescribeFieldResult fieldSchema = assetFields.get(featureName).getDescribe();
    			String featureLabel = fieldSchema.getLabel();
	    		List<SelectOption> featurePicklist = getSpecificFieldPicklist(fieldSchema);
	    		if(featurePicklist != null){
	    			FeaturePicklists.put(featureName, featurePicklist);
	    			FeatureValues.put(featureName, '');
	    			FeatureLabels.put(featureName, featureLabel);
	    			FeatureNames.add(featureName);
    			}
    		}
    	}
    }
    
    public List<SelectOption> getSpecificFieldPicklist(Schema.DescribeFieldResult fieldDescribe){
      /*Schema.DescribeSObjectResult assetObject = Asset.getSObjectType().getDescribe();
      	Map<String, Schema.SObjectField> assetFields = assetObject.fields.getMap();
      	Schema.DescribeFieldResult colourField = assetFields.get('Colour__c').getDescribe();*/
      	Set<String> addedLabels = new Set<String>();//forces uniqueness
    	List<SelectOption> fieldPicklist = new List<SelectOption>();
    	fieldPicklist.add(new SelectOption('', System.Label.Any_Dashed));
    	for(Schema.PicklistEntry f : fieldDescribe.getPicklistValues()){
    		if(!addedLabels.Contains(f.getLabel())) {
    			fieldPicklist.add(new SelectOption(f.getLabel(), f.getLabel()));
    			addedLabels.add(f.getLabel());
    		}
    	}
	    return fieldPicklist;
    }
    
    public List<SelectOption> ChannelPreferencePicklist{
    	get{
    		if(ChannelPreferencePicklist == null){
		    	ChannelPreferencePicklist = new List<SelectOption>();
		    	ChannelPreferencePicklist.add(new SelectOption('', System.Label.Any_Dashed));
    			//ChannelPreferencePicklist.add(new SelectOption('Jaguar_Email_Opt_Out__pc', System.Label.Jaguar_Email));
    			//ChannelPreferencePicklist.add(new SelectOption('Jaguar_Phone_Opt_Out__pc', System.Label.Jaguar_Phone));
    			//ChannelPreferencePicklist.add(new SelectOption('Jaguar_SMS_Opt_Out__pc', System.Label.Jaguar_SMS));
    			//ChannelPreferencePicklist.add(new SelectOption('Jaguar_Whitemail_Opt_Out__pc', System.Label.Jaguar_Mail));
    			//ChannelPreferencePicklist.add(new SelectOption('Land_Rover_Email_Opt_Out__pc', System.Label.Land_Rover_Email));
    			//ChannelPreferencePicklist.add(new SelectOption('Land_Rover_Phone_Opt_Out__pc', System.Label.Land_Rover_Phone));
    			//ChannelPreferencePicklist.add(new SelectOption('Land_Rover_SMS_Opt_Out__pc', System.Label.Land_Rover_SMS));
    			//ChannelPreferencePicklist.add(new SelectOption('Land_Rover_Whitemail_Opt_Out__pc', System.Label.Land_Rover_Mail));
    			ChannelPreferencePicklist.add(new SelectOption('PersonHasOptedOutOfEmail', System.Label.Vista_Email));
    			ChannelPreferencePicklist.add(new SelectOption('PersonDoNotCall', System.Label.Vista_Phone_SMS));
    			ChannelPreferencePicklist.add(new SelectOption('Direct_Mail_Opt_Out__pc', System.Label.Vista_Direct_Mail));
    		}
    		return ChannelPreferencePicklist;
    	}
    	set;
    }
    
    public List<SelectOption> CountryPicklist{
    	get{
    		if(CountryPicklist == null){
    			CountryPicklist = new List<SelectOption>();
    			CountryPicklist.add(new SelectOption('', System.Label.Any_Dashed));
    			Map<String, List<String>> dependentMap = GetDependentOptions('User', 'Market__c', 'Country_ISO_Code__c');
    			if(currentUser != null && String.IsNotBlank(currentUser.Market__c)){
    				if(dependentMap.containsKey(currentUser.Market__c)){
    					for(String s : dependentMap.get(currentUser.Market__c)){
    						CountryPicklist.add(new SelectOption(s, s));
    					}
    				}
    			}
    		}
    		return CountryPicklist;
    	}
    	set;
    }
    
    public boolean getShowCountryPicklist(){
    	if(CountryPicklist != null){
	    	return CountryPicklist.size() > 2; //'all' + more than one country
    	}
    	return false;
    }
    
    public boolean getCanAddCampaignMembers(){
    	return setCon != null && setCon.getResultSize() <= maxCampaignMembers;
    }
    
    public void AddToCampaign(){
    	if(String.IsNotBlank(campaignId)){
    		Set<Id> idsToAdd = new Set<Id>();
    		Set<Id> idsAlreadyAdded = new Set<Id>();
    		if(getCanAddCampaignMembers() && String.IsNotBlank(campaignMembersQuery)){
    			Set<Id> existingMembers = GetExistingCampaignMembers();
		    	for(Role__c r : Database.query(campaignMembersQuery)){
    				if(String.IsNotBlank(r.Account__r.PersonContactId)){
    					Id contactId = r.Account__r.PersonContactId;
    					if(!existingMembers.contains(contactId)){
    						idsToAdd.add(contactId);
    					}
    					else{
    						idsAlreadyAdded.add(contactId);
    					}
		    		}
    			}
    		}
    		if(idsToAdd.size() > 0){
    			List<CampaignMember> newMembers = new List<CampaignMember>();
    			for(Id contactId: idsToAdd){
    				newMembers.add(new CampaignMember(CampaignId=campaignId, ContactId=contactId));
    			}
    			insert newMembers;
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.Format(System.Label.Vista_Campaign_Members_Added, new List<String>{'' + newMembers.size(), campaignName})));
    		}
    		if(idsAlreadyAdded.size() > 0){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.Format(System.Label.Vista_Campaign_Members_Exist, new List<String>{'' + idsAlreadyAdded.size()})));
    		}
    	}
    	else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Vista_No_Campaign_Selected));
    }
    
    public void RemoveFromCampaign(){
    	if(String.IsNotBlank(campaignId)){
    		Set<Id> idsToRemove = new Set<Id>();
    		if(getCanAddCampaignMembers() && String.IsNotBlank(campaignMembersQuery)){
		    	for(Role__c r : Database.query(campaignMembersQuery)){
    				if(String.IsNotBlank(r.Account__r.PersonContactId)){
    					Id contactId = r.Account__r.PersonContactId;
    					idsToRemove.add(contactId);
		    		}
    			}
    		}
    		if(idsToRemove.size() > 0){
    			List<CampaignMember> deleteMembers = [SELECT Id FROM CampaignMember WHERE CampaignId = :campaignId AND ContactId IN :idsToRemove];
    			delete deleteMembers;
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.Format(System.Label.Vista_Campaign_Members_Deleted, new List<String>{'' + deleteMembers.size(), campaignName})));
    		}
    		else{
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.Format(System.Label.Vista_No_Existing_Campaign_Members, new List<String>{campaignName})));
    		}
    	}
    	else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Vista_No_Campaign_Selected));
    }
    
    public Set<Id> GetExistingCampaignMembers(){
    	Set<Id> existingMembers = new Set<Id>();
    	for(CampaignMember member : [SELECT ContactId FROM CampaignMember WHERE CampaignId = :campaignId]){
    		existingMembers.add(member.ContactId);
    	}
    	return existingMembers;
    }
    
    public void SetMaxResults(Integer newValue){
    	maxResults = newValue;
    }
    
    public void SetMaxCampaignMembers(Integer newValue){
    	maxCampaignMembers = newValue;
    }
    
    public boolean getUserIsMarketing(){
    	if(currentUser != null){
    		return currentUser.UserPermissionsMarketingUser;
    	}
		return false;
    }
    
    public User currentUser{
    	get{
    		if(currentUser == null){
    			currentUser = [SELECT UserPermissionsMarketingUser, Market__c FROM User WHERE Id = :UserInfo.getUserId()];
    		}
    		return currentUser;
    	}
    	set;
    }
    
	public Map<String,List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
    	//http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/
    	Map<String,List<String>> objResults = new Map<String,List<String>>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!objGlobalMap.containsKey(pObjName)){
            return objResults;
        }
        Schema.SObjectType pType = objGlobalMap.get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        if(!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)){
            return objResults; 
        }
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        Bitset objBitSet = new Bitset();
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){        	
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            String pControllingLabel = ctrl_entry.getLabel();
            objResults.put(pControllingLabel,new List<String>());
        }
         objResults.put('',new List<String>());
         objResults.put(null,new List<String>());
         for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){        	
           	Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
            String pEntryStructure = JSON.serialize(dep_entry);                
            TPicklistEntry objDepPLE = (TPicklistEntry)JSON.deserialize(pEntryStructure, TPicklistEntry.class);
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
            	if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){            		
		            String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
                    objResults.get(pControllingLabel).add(objDepPLE.label);
                }
            }
        } 
        return objResults;
    }
    
}