public with sharing class DemandMatrixReportController {
    
    public class wrapperClass {
        @AuraEnabled
        public string Brand {get; set;}
        @AuraEnabled
        public Map<string, Integer> brandMap {get; set;}
        @AuraEnabled
        public Map<string, Integer> grandMap {get; set;}
        @AuraEnabled
        public Map<string, Map<string, Integer>> ModelCountMap {get; set;}	
    }
    
    public class SelectOptionWrapper implements Comparable{
        @AuraEnabled 
        public String label {get;set;}
        @AuraEnabled 
        public String value {get;set;}
        @AuraEnabled 
        public boolean selected {get;set;}
        
        public SelectOptionWrapper(String lab, String val, Boolean sel) {
            this.label = lab;
            this.value = val;
            this.selected = sel;
        }
        
        public Integer compareTo(Object compareTo) 
        {
            SelectOptionWrapper jobsWrapper = (SelectOptionWrapper)compareTo;
            if (label == jobsWrapper.label) return 0;
            if (label > jobsWrapper.label) return 1;
            return -1;        
        }
    }
    
    @AuraEnabled 
    public static boolean CXPpermission(){
        Boolean returnValue = false;
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =:Userinfo.getUserId()];
        for(PermissionSetAssignment psa: lstcurrentUserPerSet){
            if(psa.PermissionSet.Name.equals('CXP_Demand_Matrix_Report'))
                returnValue = true;
        }
        return returnValue;
    }
    
    @AuraEnabled 
    public static boolean Portalpermission(){
        Boolean returnValue = false;
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =:Userinfo.getUserId()];
        for(PermissionSetAssignment psa: lstcurrentUserPerSet){
            if(psa.PermissionSet.Name.equals('Portal_Demand_Matrix_Report'))
                returnValue = true;
        }
        return returnValue;
    }
    
    @AuraEnabled 
    public static List<SelectOptionWrapper> fetchCountryValues(){
        List<SelectOptionWrapper > CountryValues = new List<SelectOptionWrapper>();
        for(Demand_Matrix_Country__mdt countryRec : [Select MasterLabel, Country__c from Demand_Matrix_Country__mdt]){
            CountryValues.add(new SelectOptionWrapper(countryRec.Country__c, countryRec.MasterLabel, false));
            system.debug('countryRec::'+countryRec);
        }
        CountryValues.sort();
        CountryValues.add(0, new SelectOptionWrapper('All', 'All', true));
        return CountryValues;
    }
    
    @AuraEnabled 
    public static List<String> fetchColumnValues(){
        List<string> columnHeaders = new List<String>();
        //columnHeaders.add('Open Leads');
        columnHeaders.add('New Leads');
        //columnHeaders.add('Lost Leads');
        columnHeaders.add('Open Opportunities');
        columnHeaders.add('New Opportunities');
        columnHeaders.add('Lost Opportunities');
        columnHeaders.add('Opportunities Converted to a Sales');
        columnHeaders.add('Closing Opportunities (Still Open)');
        columnHeaders.add('Resurrected Lost Opportunity');
        columnHeaders.add('Resurrected Opportunities Converted to Sales');
        columnHeaders.add('Lead Visiting Showroom (Walk-ins)');
        columnHeaders.add('Neglected Opportunities');
        columnHeaders.add('Test Drive');
        columnHeaders.add('Vista Handovers');
        return columnHeaders;
    }
    
    @AuraEnabled 
    public static List<wrapperClass> fetchTableData(string startDate, string endDate, string Country){
        system.debug('here:::'+startDate+' '+endDate+' '+Country);
        string startDateDay1;
        if(string.isNotBlank(startDate))
        	startDateDay1 = startDate.substringBefore('-')+'-'+startDate.substringBetween('-')+'-01';
        Map<string, Map<string, Map<string, Integer>>> brandModelCountMap = new Map<string, Map<string, Map<string, Integer>>>();
        Map<string, Map<string, Integer>> brandCountMap = new Map<string, Map<string, Integer>>();
        
        string barredModels = '(\'S-TYPE\',\'XJ\')';
        List<string> CountryValues = new List<string>();
        if(string.isBlank(Country) || Country=='All'){
        	for(Demand_Matrix_Country__mdt countryRec : [Select MasterLabel, Country__c from Demand_Matrix_Country__mdt])
            CountryValues.add(countryRec.MasterLabel);
        }
        else
            CountryValues.add(Country);
        
        string query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Lead where recordtype.name = \'Streamlined Lead Process\' and status not in (\'Qualified\', \'Lost\') and brand__c != null and Primary_Model_Interest__r.name not in '+ barredModels;
        /*if(string.isNotBlank(startDate))
            query += ' and createddate < '+ getCurrentUserDate(startDateDay1, false);
        else
            query += ' and createddate < THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Open Leads', CountryValues, brandModelCountMap, brandCountMap);*/
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Lead where recordtype.name = \'Streamlined Lead Process\' and brand__c != null and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and createddate >= '+ getCurrentUserDate(startDate, false);
        if(string.isNotBlank(endDate))
            query += ' and createddate <= '+ getCurrentUserDate(endDate, true);
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and createddate = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'New Leads', CountryValues, brandModelCountMap, brandCountMap);
        
        /*query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Lead where recordtype.name = \'Streamlined Lead Process\' and brand__c != null and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and Date_Lost__c >= '+startDate;
        if(string.isNotBlank(endDate))
            query += ' and Date_Lost__c <= '+endDate;
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and Date_Lost__c = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Lost Leads', CountryValues, brandModelCountMap, brandCountMap);*/
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and Enquiry_Type__c != \'Resurrected Lead\' and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and id not in (select OpportunityId from OpportunityHistory where StageName in (\'Handover & RDA\', \'Lost\') and createddate < '+ getCurrentUserDate(startDate, false) + ') and createddate < '+ getCurrentUserDate(startDate, false);
        else
            query += ' and id not in (select OpportunityId from OpportunityHistory where StageName in (\'Handover & RDA\', \'Lost\') and createddate <= THIS_MONTH) and  createddate <= THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Open Opportunities', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and Enquiry_Type__c != \'Resurrected Lead\' and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and createddate >= '+ getCurrentUserDate(startDate, false);
        if(string.isNotBlank(endDate))
            query += ' and createddate <= '+ getCurrentUserDate(endDate, true);
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and createddate = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'New Opportunities', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and Enquiry_Type__c != \'Resurrected Lead\' and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and Date_Lost__c >= '+startDate;
        if(string.isNotBlank(endDate))
            query += ' and Date_Lost__c <= '+endDate;
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and Date_Lost__c = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Lost Opportunities', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select COUNT_DISTINCT(OpportunityId), Opportunity.Primary_Model_Interest__r.name ModelName, Opportunity.brand__r.name BrandName from OpportunityHistory where Opportunity.recordtype.name = \'Sales Process with RDA\' and Opportunity.brand__c != null and Opportunity.Enquiry_Type__c != \'Resurrected Lead\' and stagename = \'Handover & RDA\' and Opportunity.Primary_Model_Interest__r.name not in '+ barredModels;        
        if(string.isNotBlank(startDate))
         	query += ' and createddate >= '+ getCurrentUserDate(startDate, false);
        if(string.isNotBlank(endDate))
            query += ' and createddate <= '+ getCurrentUserDate(startDate, true);
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and createddate = THIS_MONTH';
        query += ' and Opportunity.country_iso_code__c in:CountryValues GROUP BY Opportunity.brand__r.name, Opportunity.Primary_Model_Interest__r.name';
        populateMaps(query, 'Opportunities Converted to a Sales', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and Enquiry_Type__c != \'Resurrected Lead\' and Primary_Model_Interest__r.name not in '+ barredModels;
        /*if(string.isNotBlank(startDate)){
            query += ' and Date_Lost__c < '+startDate;
            query += ' and ((StageName not in (\'Handover & RDA\', \'Lost\') and IsClosed = FALSE  and createddate < '+getCurrentUserDate(startDateDay1, false)+')';
            query += ' or createddate >= '+ getCurrentUserDate(startDate, false)+')';
        }
        if(string.isNotBlank(endDate)){
            query += ' and Date_Lost__c > '+endDate;
            query += ' and createddate <= '+getCurrentUserDate(endDate, true);
        }
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and ((StageName not in (\'Handover & RDA\', \'Lost\') and IsClosed = FALSE  and createddate < THIS_MONTH) or createddate = THIS_MONTH) and Date_Lost__c != THIS_MONTH';*/
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Closing Opportunities (Still Open)', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and StageName not in (\'Handover & RDA\', \'Lost\') and Enquiry_Type__c = \'Resurrected Lead\' and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and createddate >= '+ getCurrentUserDate(startDate, false);
        if(string.isNotBlank(endDate))
            query += ' and createddate <= '+ getCurrentUserDate(endDate, true);
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and createddate = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Resurrected Lost Opportunity', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and Enquiry_Type__c = \'Resurrected Lead\' and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and Handed_Over_Date__c >= '+startDate;
        if(string.isNotBlank(endDate))
            query += ' and Handed_Over_Date__c <= '+endDate;
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and Handed_Over_Date__c = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Resurrected Opportunities Converted to Sales', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and LeadSource = \'Walk-in\' and Primary_Model_Interest__r.name not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and createddate >= '+ getCurrentUserDate(startDate, false);
        if(string.isNotBlank(endDate))
            query += ' and createddate <= '+ getCurrentUserDate(endDate, true);
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and createddate = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Lead Visiting Showroom (Showroom Visitors)', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Primary_Model_Interest__r.name ModelName, brand__r.name BrandName from Opportunity where recordtype.name = \'Sales Process with RDA\' and brand__c != null and Primary_Model_Interest__r.name not in '+ barredModels;
        /*if(string.isNotBlank(startDate)){
            query += ' and id not in (Select opportunityid from opportunityfieldhistory where createddate >= '+ get7DyasBeforeDate(startDate);
            if(string.isNotBlank(endDate))
                query += ' and createddate <= '+ getCurrentUserDate(endDate, true);
             query += ')';
        }*/
        if(string.isNotBlank(endDate))
            query += ' and id not in (Select opportunityid from opportunityfieldhistory where createddate >= '+ get7DyasBeforeDate(endDate, true) + ' and createddate <= '+ getCurrentUserDate(endDate, true) + ') and createddate <= '+ getCurrentUserDate(endDate, true);
        else
        	query += ' and lastmodifieddate != LAST_N_Days:7 and lastactivitydate != LAST_N_Days:7';
        query += ' and country_iso_code__c in:CountryValues GROUP BY brand__r.name, Primary_Model_Interest__r.name';
        populateMaps(query, 'Neglected Opportunities', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Model__c ModelName, Brand__c BrandName from event where brand__c != null and what.type = \'Opportunity\' and subject like \'%Test Drive%\' and Test_Drive_Status__c = \'Finished\' and Model__c not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and StartDateTime >= '+ getCurrentUserDate(startDate, false);
        if(string.isNotBlank(endDate))
            query += ' and EndDateTime <= '+ getCurrentUserDate(endDate, true);
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and EndDateTime = THIS_MONTH';
        query += ' and country_iso_code__c in:CountryValues GROUP BY Brand__c, Model__c';
        populateMaps(query, 'Test Drive', CountryValues, brandModelCountMap, brandCountMap);
        
        query = 'select count(id), Model__r.Model_Alternative__c ModelName, Brand__r.name BrandName from asset where brand__c != null and accountId != null and Model__r.Model_Alternative__c not in '+ barredModels;
        if(string.isNotBlank(startDate))
            query += ' and Handover_Date__c  >= '+startDate;
        if(string.isNotBlank(endDate))
            query += ' and Handover_Date__c  <= '+endDate;
        if(string.isBlank(startDate) && string.isBlank(endDate))
            query += ' and Handover_Date__c  = THIS_MONTH';
        query += ' and MENA_Product_Country_Code__c  in:CountryValues GROUP BY brand__r.name, Model__r.Model_Alternative__c';
        populateMaps(query, 'Vista Handovers', CountryValues, brandModelCountMap, brandCountMap);
        
        Map<string, Integer> grandCount = new Map<String, Integer>();
        for(string key : brandCountMap.keyset()){
            for(string innerKey : brandCountMap.get(key).keyset()){
                if(grandCount.containsKey(innerKey))
                    grandCount.put(innerKey, grandCount.get(innerKey) + brandCountMap.get(key).get(innerKey));
                else
                    grandCount.put(innerKey, brandCountMap.get(key).get(innerKey));
            }
        }
        
        List<wrapperClass> dataToReturn = new List<wrapperClass>();
        for(string key : brandCountMap.keyset()){
            wrapperClass dataToAdd = new wrapperClass();
            dataToAdd.Brand = key;
            dataToAdd.brandMap = brandCountMap.get(key);
            dataToAdd.grandMap = grandCount;
            dataToAdd.ModelCountMap = brandModelCountMap.get(key);
            
            dataToReturn.add(dataToAdd);
        }
        system.debug('dataToReturn::'+dataToReturn);
        return dataToReturn;
    }
    
    public static void populateMaps(string query, string columnKey, list<string> CountryValues, Map<string, Map<string, Map<string, Integer>>> brandModelCountMap, Map<string, Map<string, Integer>> brandCountMap){
        system.debug('Column Query:::' + columnKey + ' - ' + query);
        List<AggregateResult> aggregRecs = database.query(query);
        for(AggregateResult aggregRec : aggregRecs){
            string Model = (string)aggregRec.get('ModelName');
            string Brand = (string)aggregRec.get('BrandName');
            integer count = (integer)aggregRec.get('expr0');
            
            if(string.isBlank(Model))
                Model = ' -';
            
            if(brandModelCountMap.containsKey(Brand)){
                if(brandModelCountMap.get(Brand).containsKey(Model))
                    brandModelCountMap.get(Brand).get(Model).put(columnKey, count);
                else
                    brandModelCountMap.get(Brand).put(Model, new Map<string, integer>{columnKey=>count});
            }
            else
                brandModelCountMap.put(Brand, new Map<string, Map<string, Integer>>{Model=>new Map<string, integer>{columnKey=>count}});
            
            if(columnKey == 'Closing Opportunities (Still Open)'){
                integer openOpp = brandModelCountMap.get(Brand).get(Model).get('Open Opportunities');
                integer NewOpp = brandModelCountMap.get(Brand).get(Model).get('New Opportunities');
                integer LostOpp = brandModelCountMap.get(Brand).get(Model).get('Lost Opportunities');
                if(openOpp == null)	openOpp = 0;
                if(NewOpp == null)	NewOpp = 0;
                if(LostOpp == null)	LostOpp = 0;
                count = openOpp + NewOpp - LostOpp;
                if(count<0)
                    count = 0;
                brandModelCountMap.get(Brand).get(Model).put(columnKey, count);
            }
            
            if(brandCountMap.containsKey(Brand)){
                if(brandCountMap.get(Brand).containsKey(columnKey))
                    brandCountMap.get(Brand).put(columnKey, brandCountMap.get(Brand).get(columnKey) + count);
                else
                    brandCountMap.get(Brand).put(columnKey, count);
            }
            else
                brandCountMap.put(Brand, new Map<string, integer>{columnKey=>count});
        }
    }
    
    public static string getCurrentUserDate(string dateValue, Boolean isEnddate){
        string returnDate;
        integer year = integer.valueOf(dateValue.substringBefore('-'));
        integer month = integer.valueOf(dateValue.substringBetween('-'));
        integer day = integer.valueOf(dateValue.substringAfterLast('-'));
        Datetime dateTimeNew = Datetime.newInstanceGmt(year,month,day,00,00,00);
        if(isEnddate)
            dateTimeNew = Datetime.newInstanceGmt(year,month,day+1,00,00,00);
        dateTimeNew = dateTimeNew.addSeconds(-(userinfo.getTimeZone().getOffset(dateTimeNew)/1000));
        returnDate = dateTimeNew.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return returnDate;
    }
    
    public static string get7DyasBeforeDate(string dateValue, Boolean isEnddate){
        string returnDate;
        integer year = integer.valueOf(dateValue.substringBefore('-'));
        integer month = integer.valueOf(dateValue.substringBetween('-'));
        integer day = integer.valueOf(dateValue.substringAfterLast('-'));
        Datetime dateTimeNew = Datetime.newInstanceGmt(year,month,day,00,00,00);
        if(isEnddate)
            dateTimeNew = Datetime.newInstanceGmt(year,month,day+1,00,00,00);
        dateTimeNew = dateTimeNew.addDays(-7);
        dateTimeNew = dateTimeNew.addSeconds(-(userinfo.getTimeZone().getOffset(dateTimeNew)/1000));
        returnDate = dateTimeNew.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        return returnDate;
    }
}