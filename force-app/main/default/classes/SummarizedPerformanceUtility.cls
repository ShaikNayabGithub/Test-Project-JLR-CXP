public class SummarizedPerformanceUtility {
    private static Map<String, String> localeMappedToCountryCode = new Map<String, String>();
    static {
         localeMappedToCountryCode.put('AR', 'America/Sao_Paulo');
       localeMappedToCountryCode.put('BR', 'America/Sao_Paulo');
       localeMappedToCountryCode.put('CL', 'America/Sao_Paulo');
       localeMappedToCountryCode.put('CO', 'America/Sao_Paulo');
       localeMappedToCountryCode.put('CR', 'America/Sao_Paulo');
       localeMappedToCountryCode.put('MX', 'America/Sao_Paulo');
       localeMappedToCountryCode.put('PE', 'America/Sao_Paulo');
       localeMappedToCountryCode.put('SG', 'Asia/Singapore');
       localeMappedToCountryCode.put('ID', 'Asia/Singapore');
       localeMappedToCountryCode.put('MY', 'Asia/Singapore');
       localeMappedToCountryCode.put('NZ', 'Asia/Singapore');
       localeMappedToCountryCode.put('PH', 'Asia/Singapore');
       localeMappedToCountryCode.put('TH', 'Asia/Singapore');
       localeMappedToCountryCode.put('VN', 'Asia/Singapore');
       localeMappedToCountryCode.put('BN', 'Asia/Singapore');
       localeMappedToCountryCode.put('HK', 'Asia/Singapore');
       localeMappedToCountryCode.put('KH', 'Asia/Singapore');
       localeMappedToCountryCode.put('LA', 'Asia/Singapore');
       localeMappedToCountryCode.put('MM', 'Asia/Singapore');
       localeMappedToCountryCode.put('MN', 'Asia/Singapore');
       localeMappedToCountryCode.put('MO', 'Asia/Singapore');
       localeMappedToCountryCode.put('NC', 'Asia/Singapore');
       localeMappedToCountryCode.put('TW', 'Asia/Singapore');
       localeMappedToCountryCode.put('JP', 'Asia/Tokyo');
       localeMappedToCountryCode.put('IN', 'Asia/Kolkata');

    }
    
          
    public static List<Summarised_Pipeline_Performance_Metric__c> SetDateProperties(List<Summarised_Pipeline_Performance_Metric__c> snapshots) {
       List<Summarised_Pipeline_Performance_Metric__c> updatedRecords = new List<Summarised_Pipeline_Performance_Metric__c>();
       Map<String, TimeZone> TimeZoneMap = new Map<String, TimeZone>();
       
       for (Summarised_Pipeline_Performance_Metric__c rs : snapshots)
       {
           // if no ISO Code, default to GMT
           if (String.isEmpty(rs.Country_ISO_Code__c) || !localeMappedToCountryCode.containsKey(rs.Country_ISO_Code__c)) {
               updatedRecords.add(new Summarised_Pipeline_Performance_Metric__c(
                Id = rs.Id,
                Year__c = rs.CreatedDate.year(),
                Day__c = rs.CreatedDate.day(),
                Month__c = rs.CreatedDate.month(),
                Reporting_Date__c = date.newInstance( rs.CreatedDate.year(), rs.CreatedDate.month(), rs.CreatedDate.day())   
                ));
           } else {
                TimeZone tz;
               String locale = localeMappedToCountryCode.get(rs.Country_ISO_Code__c);
               if( TimeZoneMap.containsKey(locale)) {
                   tz = TimeZoneMap.get(locale);
               } else {
                   tz = TimeZone.getTimeZone(locale);
                   TimeZoneMap.put(locale, tz);
               }
               Integer offset = tz.getOffset(rs.CreatedDate);
               DateTime dt = rs.CreatedDate.addSeconds(offset/1000);
               Date localDate = dt.date();
               updatedRecords.add(new Summarised_Pipeline_Performance_Metric__c(
                    Id = rs.Id,
                    Year__c = localDate.year(),
                    Day__c = localDate.day(),
                    Month__c = localDate.month(),
                    Reporting_Date__c = date.newInstance( localDate.year(), localDate.month(), localDate.day())
                ));        
           }             
       }
       return updatedRecords;
   }
}