public class TimeAdapter_HHMMSS implements I_TimeAdapter{
    public Time parse(string timeString)
    {
    	if(timeString.length() < 6){throw new TypeException('TimeAdapter_HHMMSS.parse: Invalid time format');}
    	
    	string hoursString = timeString.mid(0,2);
    	string minutesString = timeString.mid(2,2);
    	string secondsString = timeString.mid(4,2);
    	
    	integer hours = integer.valueOf(hoursString);
    	integer minutes = integer.valueOf(minutesString);
    	integer seconds = integer.valueOf(secondsString);
    	
    	return Time.newInstance(hours, minutes, seconds, 0);
    }
}