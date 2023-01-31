public with sharing class PdiQuotaBoardController {
    @AuraEnabled
    //This method will return data from PDI_Quota__c object based on the month/year passed from PDI Quota screen
    public static List<PDI_Quota__c> fetchPdiQuota (Integer Year, Integer Month){
        return [SELECT Id, 
                Name, 
                Retailer__r.Name,		
                Retailer__c,
                Month_Start__c,
                Allocation_Day_1__c,
                Allocation_Day_2__c, 
                Allocation_Day_3__c,
                Allocation_Day_4__c,
                Allocation_Day_5__c,
                Allocation_Day_6__c,
                Allocation_Day_7__c,
                Allocation_Day_8__c,
                Allocation_Day_9__c,
                Allocation_Day_10__c,
                Allocation_Day_11__c,
                Allocation_Day_12__c,
                Allocation_Day_13__c,
                Allocation_Day_14__c,
                Allocation_Day_15__c,
                Allocation_Day_16__c,
                Allocation_Day_17__c,
                Allocation_Day_18__c,
                Allocation_Day_19__c,
                Allocation_Day_20__c,
                Allocation_Day_21__c,
                Allocation_Day_22__c,
                Allocation_Day_23__c,
                Allocation_Day_24__c,
                Allocation_Day_25__c,
                Allocation_Day_26__c,
                Allocation_Day_27__c,
                Allocation_Day_28__c,
                Allocation_Day_29__c,
                Allocation_Day_30__c,
                Allocation_Day_31__c
                FROM PDI_Quota__c 
                where CALENDAR_MONTH(Month_Start__c) = :Month and CALENDAR_YEAR(Month_Start__c) = :Year ];
    }
    
    @AuraEnabled
    public static String saveTargetRecords(String PdiData){
        //This method will save data from PDI Quota screen
        String successMessage = 'Success';
        try{
            List<PDI_Quota__c> PdiDataList = (List<PDI_Quota__c>)JSON.deserialize(PdiData, List<PDI_Quota__c>.class);
            List<PDI_Quota__c> upsertTargetList = new List<PDI_Quota__c>();
            for(PDI_Quota__c targetWrapper: PdiDataList){
                upsertTargetList.add(targetWrapper);
            }
            if(upsertTargetList.size() > 0) upsert upsertTargetList; 
        } 
        catch(exception exp) {
            successMessage = ''+exp.getMessage();
        }
        return successMessage;
    }
    
    @AuraEnabled
    //public static Map<Integer, String> GetDays(Integer Year, Integer Month){
    public static GetDayswithHolidayWrapper GetDays(Integer Year, Integer Month){
        //This method will return day and number of days in a given month. Month and Year is passed from PDI Quota screen
        Map<Integer, String> WeekMap2 = new Map<Integer, String>();
        Map<Integer, String> FinalMap = new Map<Integer, String>();
        Map<String, Integer> WeekMap = new Map<String, Integer>();
        //This variable holds if a day is a holiday or not
        Map<Integer, Boolean> holidayList = new Map<Integer, Boolean>();
        Integer noOfDays = Date.daysInMonth(Year, Month);
        system.debug(noOfDays);
        WeekMap2.put(1,'Sun');
        WeekMap2.put(2,'Mon');
        WeekMap2.put(3,'Tue');
        WeekMap2.put(4,'Wed');
        WeekMap2.put(5,'Thu');
        WeekMap2.put(6,'Fri');
        WeekMap2.put(7,'Sat');
        
        WeekMap.put('Sun',1);
        WeekMap.put('Mon',2);
        WeekMap.put('Tue',3);
        WeekMap.put('Wed',4);
        WeekMap.put('Thu',5);
        WeekMap.put('Fri',6);
        WeekMap.put('Sat',7);
        
        DateTime dt = DateTime.newInstance(Year, Month,1);
        DateTime myDateTime = (DateTime)dt;
        String StartDay = myDateTime.format('E');
        Integer max = 7;
        Integer StartNum;
        startNum = WeekMap.get(StartDay);
        system.debug(StartNum);
       
        for(Integer i=1 ; i<=noOfDays; i++){
            system.debug(startNum);
            system.debug('inside for loop' + WeekMap2.get(startNum));
            String j = WeekMap2.get(StartNum);
            FinalMap.put(i, j);
               
            // Get the default business hours
            BusinessHours bh = [SELECT Id,Name  FROM BusinessHours WHERE Name='Korea'];

            system.debug('bh'+bh);
            // Create Datetime on May 28, 2013 at 1:06:08 AM in the local timezone.
            Datetime targetTime = Datetime.newInstance(Year, Month, i, 9, 0, 0);

            system.debug('targetTime'+targetTime);

            // Find whether the time is within the default business hours
            Boolean IsWorkingDay= BusinessHours.isWithin(bh.id, targetTime);     
            holidayList.put(i,!IsWorkingDay);
            if(startNum < max){
                
                startNum++;
            }
            else{
                startNum = 1;
            }
        }
        system.debug(FinalMap);

      

        GetDayswithHolidayWrapper daysWithHolidayVar = new GetDayswithHolidayWrapper();
        daysWithHolidayVar.finalMap_1 = FinalMap;
        daysWithHolidayVar.holiday =holidayList;
        //system.debug(daysWithHolidayVar.finalMap_1);
        //system.debug(daysWithHolidayVar.holiday);
        Boolean hasPermission = FeatureManagement.checkPermission('Manage_PDI_Quota');
		system.debug(hasPermission);
        daysWithHolidayVar.pdiViewPermission =hasPermission;
        system.debug(daysWithHolidayVar);

        //return FinalMap;
        return daysWithHolidayVar;
        
    }
    
    
    @AuraEnabled
    public static List<String> GetYearMonth(){
	List<String> yearMonth = New List<String>();
        //for(PDIQuota_YearMonthSetting__mdt fieldData : PDIQuota_YearMonthSetting__mdt.getAll().values()){
        for(PDIQuota_YearMonthSetting__mdt fieldData : [select Id,Year__c,Active__c,rownumber__c from PDIQuota_YearMonthSetting__mdt ORDER BY  rownumber__c ASC]){
	if (fieldData.Active__c){
		yearMonth.add(fieldData.Year__c);
	}
	}
       
	return yearMonth;
    }

    @AuraEnabled
    public static String getLangofUserLoggedin(){
        User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug(u.LanguageLocaleKey);
        return u.LanguageLocaleKey;
    }
    
    public class GetDayswithHolidayWrapper {
         @AuraEnabled
        public Map<Integer, String> finalMap_1{get;set;}
         @AuraEnabled
        public Map<Integer, Boolean> holiday{get;set;}
         @AuraEnabled
		public Boolean pdiViewPermission{get;set;}

        
    }
}