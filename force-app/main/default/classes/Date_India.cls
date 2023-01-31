public class Date_India implements I_DateAdapter{//rename
    public Date parse(string dateString)
    {
    	List<string> componentArray = dateString.split('-');
    	if(componentArray.Size() < 3){throw new TypeException('Invalid Date format');}
    	
    	integer day = integer.valueOf(componentArray[0]);
    	integer month = integer.valueOf(componentArray[1]);
    	integer year = integer.valueOf(componentArray[2]);
    	
    	return Date.newInstance(year, month, day);
    }
}