/*
* @description  Helper class for Case.trigger
* @author       Uvais Komath@Changi Consulting
* @V1.0         Uvais Komath - Created - 28-Mar-2019 - Separates new logic from existing Handler
* 
* Updated       June 2022 - Mike Backhouse. Added Korea handling
*/
public class CaseTriggerHelper {
    
    /*
* @description  marks Escalation Dates for various levels based on businesshours
* @author       Uvais Komath@Changi Consulting
*/
    public static void setEscalationDates(List<case> allRecords)
    {
        setKoreaEscalationDates(allRecords);

        List<case> changedCases = CaseTriggerFilter.getMenaRecords(allRecords);
        if(!changedCases.isEmpty())
        {
            List<Escalation_Settings__mdt> es = [SELECT Level__c,Priority__c,Number_of_business_hours__c
                                                 FROM Escalation_Settings__mdt]; 
            
            
            Id BusinessHourId=[SELECT Id FROM BusinessHours WHERE Name =: Label.MenaBusinessHour].Id;
            
            Map<String,Decimal> priotityLevelToHoursMap = new Map<String,Decimal>();
            //create Priority-Level to Business Hours SLA Map
            for(Escalation_Settings__mdt esv : es)
            {
                priotityLevelToHoursMap.put(esv.Priority__c+esv.Level__c,esv.Number_of_business_hours__c);
                
            }
            
            for(Case cs : changedCases)  
            {
                
                DateTime followup= cs.Next_Follow_up_Date__c <> null ? cs.Next_Follow_up_Date__c : System.Today();
                
                if(!String.isBlank(cs.Priority))
                {
                    cs.Level_1_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'1')));
                    cs.Level_2_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'2')));
                    cs.Level_3_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'3')));
                    cs.Level_4_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'4')));
                }
            } 
        }
    }

    private static void setKoreaEscalationDates(List<case> allRecords) {
        List<case> changedCases = CaseTriggerFilter.getKoreaRecords(allRecords);
        if(!changedCases.isEmpty())
        {
            List<Escalation_Settings__mdt> es = [SELECT Level__c,Priority__c,Number_of_business_hours__c
                                                 FROM Escalation_Settings__mdt]; 
            
            
            Id BusinessHourId=[SELECT Id FROM BusinessHours WHERE Name =: Label.KoreaBusinessHour].Id;
            
            Map<String,Decimal> priotityLevelToHoursMap = new Map<String,Decimal>();
            //create Priority-Level to Business Hours SLA Map
            for(Escalation_Settings__mdt esv : es)
            {
                priotityLevelToHoursMap.put(esv.Priority__c+esv.Level__c,esv.Number_of_business_hours__c);
                
            }
            
            for(Case cs : changedCases)  
            {
                
                DateTime followup= cs.Next_Follow_up_Date__c <> null ? cs.Next_Follow_up_Date__c : System.Today();
                
                if(!String.isBlank(cs.Priority))
                {
                    cs.Level_1_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'1')));
                    cs.Level_2_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'2')));
                    cs.Level_3_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'3')));
                    cs.Level_4_Escalation_Date__c=BusinessHours.Add(BusinessHourId,followup,3600000*Integer.valueof(priotityLevelToHoursMap.get(cs.Priority+'4')));
                }
            } 
        }
    }
}