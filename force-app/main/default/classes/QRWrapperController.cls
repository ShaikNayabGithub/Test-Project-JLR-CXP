public class QRWrapperController {

    public string iSOCode = null;
    public string upperName = null;
    public string upperLastName = null;
    public string upperEventName = null;
    public string formatDate = null;

    
    
    public String FirstNameString;
    public String EventNameString;
    public String LastNameString;
    public String nationalityOption;
    public String CampId;
    public DateTime unformatDate;
    public string CampTimeZone;
    
    
    public string getformatDate()
    {
        system.debug('In get format date');
        if(formatDate == null)
        {
            formatDate = formattingDate();
        }
        return formatDate;
        
    }
    
    public string getUpperName()
    {
        if(upperName == null)
        {
            upperName = convertFirstNameToUpper();
        }
        return upperName;
        
    }
    
    public string getUpperLastName()
    {
        if(upperLastName == null)
        {
            upperLastName = convertLastNameToUpper();
        }
        return upperLastName;
        
    }
    
    public string getUpperEventName()
    {
        if(upperEventName == null)
        {
            upperEventName = convertEventNameToUpper();
        }
        return upperEventName;
        
    }  
    
    
    public void setEventNameString(String s)
    {
        EventNameString = s;
    }
    
    public void setCampId(String s)
    {
        CampID = s;
    }
    
    public string getCampId()
    {
        return campId;
    }
    
    public void setUnFormatDate(DateTime d)
    {
        unformatDate = d;
    }
    
    public DateTime getUnformatDate()
    {
        return unFormatDate;
    }
    
    public string getEventNameString()
    {
        return FirstNameString;
        
    }
    
    public void setFirstNameString(String s)
    {
        FirstNameString = s;
    }
    
    public string getFirstNameString()
    {
        return FirstNameString;
        
    }
    
    public void setCampTimeZone(String s)
    {
        CampTimeZone = s;
    }
    
    public string getCampTimeZone()
    {
        return CampTimeZone;
        
    }
    
    public void setLastNameString(String s)
    {
        LastNameString = s;
    }
    
    public string getLastNameString()
    {
        return LastNameString;
        
    }
    
    public string convertLastNameToUpper()
    {
        System.debug(LastNameString);
        string toUpper = null;
        if(LastNameString != null)
        {
            toUpper = LastNameString.toUpperCase();
        }
        return toUpper;
    
    }
    
    public string convertFirstNameToUpper()
    {
        System.debug(FirstNameString);
        string toUpper = null;
        if(FirstNameString != null)
        {
            toUpper = FirstNameString.toUpperCase();
        }
        return toUpper;
    
    }
    
    public string convertEventNameToUpper()
    {
        System.debug(EventNameString);
        string toUpper = null;
        if(EventNameString != null)
        {
            toUpper = EventNameString.toUpperCase();
        }
        return toUpper;
    
    }
    
    public string formattingDate()
    {
        system.debug('In formatting date');
        String returnString;
        if(unFormatDate != null)
        {
            
            string tZone = GetTimeZoneString();
            system.debug(tZone);
            if(tZone != null)
            {
                DateTime theTime = unFormatDate;
                long gmtMilli = unFormatDate.millisecondGmt();
                Date gmtTime = unFormatDate.dateGmt();
                System.debug('GMT Time ' + gmtTime);
                Time gmtTimeTime = unFormatDate.timeGmt();
                System.debug('GMT TimeTime ' + gmtTimeTime);
                
                DateTime gmtDate = DateTime.newInstanceGMT(gmtTime, gmtTimeTime);
                
                System.debug('GMT Date' + gmtTime);
                Timezone theZone = Timezone.getTimeZone(tZone);
                System.debug('Timezone ' + theZone);
                integer offset = theZone.getOffset(gmtDate);
                integer minOffset = offset/60000;
                System.debug('offset ' + offset);
                DateTime newDate = gmtDate.addMinutes(minOffset);
                
                
                string formatDate = newDate.format('dd/MM/yyyy', tZone);
                
                
                System.debug('original date '  + unFormatDate);
                System.debug('gmtDate '  + gmtDate);
                System.debug('new date '  + newDate);
                returnString = formatDate;
                System.debug('Returning ' + formatDate);
            }
            
        }
        return returnString;
    }
    
    public string GetTimeZoneString()
    {
        System.debug('in get timezone' + CampId);
        //Campaign camp = [SELECT aop_Event_TimeZone__c FROM Campaign WHERE Id=: CampId LIMIT 1];
        //System.debug(camp.aop_Event_TimeZone__c);
            if(CampTimeZone != null)
            {
                Map<string, aop_TimeZone_Offsets__c> timezoneMap = aop_TimeZone_Offsets__c.getAll();
                for(aop_TimeZone_Offsets__c tZone : timezoneMap.values())
                {
                    if(tZone.aop_Campaign_TimeZone__c == CampTimeZone)
                    {
                        return tZone.Name;
                    }
                }
            }
        return null;
    }
}