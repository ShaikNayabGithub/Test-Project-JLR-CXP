public class Vista_Date_Adapter {
	public Date Parse(String dateTimeString)
	{
		if(String.isBlank(dateTimeString)) { return Date.newInstance(0, 0, 0); }
		
		String datestring = dateTimeString.substringBefore('T');
		return Date.valueOf(datestring);
	}
}