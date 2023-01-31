public class DateTimeAdapter {
	private final I_DateAdapter dateAdapter;
	private final I_TimeAdapter timeAdapter;
	
	public DateTimeAdapter(I_DateAdapter dateAdapter, I_TimeAdapter timeAdapter)
	{
		this.dateAdapter = dateAdapter;
		this.timeAdapter = timeAdapter;
	}
	
    public DateTime parseDateTime(string dateTimeString)
    {
    	List<string> date_timeStringArray = dateTimeString.split(' ');
    	if(date_timeStringArray.Size() < 2){throw new TypeException('DateTimeAdapter.parse: Invalid DateTime format');}
    	
    	Date dateComponent = dateAdapter.parse(date_timeStringArray[0]);
    	Time timeComponent = timeAdapter.parse(date_timeStringArray[1]);
    	
    	return DateTime.newInstance(dateComponent, timeComponent);
    }
    
    public Date parseDate(string dateString)
    {
    	return dateAdapter.parse(dateString);
    }
    
    public Time parseTime(string timeString)
    {
    	return timeAdapter.parse(timeString);
    }
}