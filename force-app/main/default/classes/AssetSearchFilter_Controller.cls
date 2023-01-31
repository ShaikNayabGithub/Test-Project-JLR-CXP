public class AssetSearchFilter_Controller {

    public List<Asset> AssetSearchResults {get; set;}
    public String searchName {get; set{
        if(String.IsNotBlank(searchName)) { searchName = String.escapeSingleQuotes(searchName); }
    }}
    public List<String> searchFields {get; set;}
    public List<String> searchCriteria {get; set;}
    public List<String> searchValues {get; set;}
    public Integer maxResults = 20;
    public List<Integer> searchFieldIndex {get; set;}
    public Integer numberSearchFields {get; set;}
    public boolean resultsUpdated = false;
    public boolean withSharing = false;
    private String additionalColumns = '';
    private String extraClause = '';
    
    public AssetSearchFilter_Controller(){
        this(3);
    }
    
    public AssetSearchFilter_Controller(Integer numberFields){
        numberSearchFields = numberFields;
        searchFieldIndex = new List<Integer>();
        searchFields = new List<String>();
        searchCriteria = new List<String>();
        searchValues = new List<String>();
        for(Integer i=0; i<numberSearchFields; i++){
            searchFieldIndex.add(i);
            searchFields.add('--none--');
            searchCriteria.add('--none--');
            searchValues.add('');
        }
    }

    public List<SelectOption> AvailableFields{
        get{
            if(AvailableFields == null){
                availableFields = new List<SelectOption>();
                availableFields.add(new SelectOption('--none--', '--' + System.Label.None + '--'));
                for(Schema.FieldSetMember fsm : SObjectType.Asset.FieldSets.Asset_Search.getFields()){
                    availableFields.add(new SelectOption(fsm.getFieldPath(), fsm.getLabel()));
                }
            }
            return availableFields;
        }
        set;
    }
    
    public List<SelectOption> AvailableCriteria{
        get{
            if(AvailableCriteria == null){
                availableCriteria = new List<SelectOption>();
                availableCriteria.add(new SelectOption('--none--', '--' + System.Label.None + '--'));
                availableCriteria.add(new SelectOption('equals', System.Label.Stock_Search_Equals));
                availableCriteria.add(new SelectOption('not equal to', System.Label.Stock_Search_Not_Equals));
                availableCriteria.add(new SelectOption('starts with', System.Label.Stock_Search_Starts_With));
                availableCriteria.add(new SelectOption('contains', System.Label.Stock_Search_Contains));
                availableCriteria.add(new SelectOption('does not contain', System.Label.Stock_Search_Not_Contains));
            }
            return availableCriteria;
        }
        set;
    }
    
    public String ConstructQuery(){
        String whereClause = '';
        String innerSearch = '';
        if(String.IsNotBlank(searchName)){
            innerSearch += 'AND Name LIKE \'%' + searchName + '%\' ';
        }
        for(Integer i=0; i<numberSearchFields; i++){
            if(searchFields[i]==null){
                searchFields[i] = '';
            }
            if(searchCriteria[i]==null){
                searchCriteria[i] = '';
            }
            if(String.IsNotBlank(searchFields[i]) && String.IsNotBlank(searchCriteria[i]) && String.IsNotBlank(searchValues[i])){
                if(searchFields[i] != '--none--' && searchCriteria[i] != '--none--'){
                    innerSearch += 'AND ' + DatabaseSearchTerm(searchFields[i], searchCriteria[i], searchValues[i]);
                }
            }
        }
        if(String.IsNotBlank(innerSearch)){
            whereClause += 'WHERE ' + innerSearch.substring(4);
        }
        //in some scenarios we need to add further search criteria - such as 'WHERE Status IN x'
        if(String.IsNotBlank(extraClause)){
            if(String.IsNotBlank(innerSearch)){
                whereClause += ' AND ' + extraClause;
            }
            else{
                whereClause += ' WHERE ' + extraClause;
            }
        }
        return whereClause;
    }
    
    public void AddSearchColumn(String searchColumn){
        additionalColumns += ', ' + searchColumn;
    }
    
    public void AddWhereClause(String searchClause){
        if(String.IsBlank(extraClause)){
            extraClause = searchClause;
        }
        else{
            extraClause += ' AND ' + searchClause;
        }
    }
    
    public String DatabaseSearchTerm(String fieldValue, String criteriaValue, String valueValue){
        //equals, not equal to, starts with, contains, does not contain
        String fieldName = fieldValue;
        if(fieldName.equalsIgnoreCase('BRAND__c') || fieldName.equalsIgnoreCase('MODEL__C') || fieldName.equalsIgnoreCase('DERIVATIVE__C')){
            fieldName = fieldName.substring(0, fieldName.length() - 1) + 'r.Name';
        }
        if(criteriaValue.equalsIgnoreCase('NOT EQUAL TO')){
            return ' (NOT ' + fieldName + ' LIKE \'' + valueValue + '\')';
        }
        else if(criteriaValue.equalsIgnoreCase('STARTS WITH')){
            return fieldName + ' LIKE \'' + valueValue + '%\'';
        }
        else if(criteriaValue.equalsIgnoreCase('CONTAINS')){
            return fieldName + ' LIKE \'%' + valueValue + '%\'';
        }
        else if(criteriaValue.equalsIgnoreCase('DOES NOT CONTAIN')){
            return ' (NOT ' + fieldName + ' LIKE \'%' + valueValue + '%\')';
        }
        else{
            return fieldName + ' LIKE \'' + valueValue + '\'';
        }
    }
    
    public void PerformSearch(){
        String whereClause = ConstructQuery();
        String actualQuery = 'SELECT Id, Name, Status' + additionalColumns;
        for(Schema.FieldSetMember fsm : SObjectType.Asset.FieldSets.Asset_Search.getFields()){
            actualQuery += ', ' + fsm.getFieldPath();
        }
        actualQuery += ' FROM Asset ';
        actualQuery += ConstructQuery();
        actualQuery += ' ORDER BY LastModifiedDate DESC';
        
        List<Asset> tempResults = new List<Asset>();
        
        try{
            tempResults = Database.query(actualQuery);
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
            
            
            
        AssetSearchResults = new List<Asset>();
        if(withSharing){
            Set<String> foundIds = SObjectUtilities.GetFieldValues(tempResults, 'Id');
            Set<Id> allowedRecords = new Set<Id>();
            for(UserRecordAccess ura : [SELECT RecordId FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId IN :foundIds AND HasReadAccess = true]){
                allowedRecords.add(ura.RecordId);
            }
            for(Asset a : tempResults){
                if(allowedRecords.contains(a.Id) && AssetSearchResults.size() < maxResults){
                    AssetSearchResults.add(a);
                }
            }
            if(AssetSearchResults.size() < allowedRecords.size()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Stock_Search_More_Results_Available));
            }
        }
        else{
            Integer resultCount = 0;
            for(Asset a : tempResults){
                if(resultCount < maxResults){
                    AssetSearchResults.add(a);
                    resultCount++;
                }
            }
            if(AssetSearchResults.size() < tempResults.size()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Stock_Search_More_Results_Available));
            }
        }
        if(AssetSearchResults.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Stock_Search_No_Results));
        }
        resultsUpdated = true;
    }
    
    public void ClearSearch(){
        searchName = '';
        for(Integer i=0; i<numberSearchFields; i++){
            searchFields[i] = '--none--';
            searchCriteria[i] = '--none--';
            searchValues[i] = '';
        }
    }

}