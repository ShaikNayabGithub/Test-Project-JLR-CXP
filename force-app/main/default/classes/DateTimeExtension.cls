public class DateTimeExtension {
    public static DateTime AddHours(DateTime dateTimeInstance, Integer hours)
    {
        Integer daysToAdd = 0;
        
        while(hours >= 24){
            daysToAdd++;
            hours -= 24;
        }
        while(hours <= -24){
            daysToAdd--;
            hours += 24;
        }
        
        DateTime updatedDate = dateTimeInstance.addDays(daysToAdd);
        DateTime updatedTime = updatedDate.addHours(hours);
        
        return updatedTime;
    }

    public static Datetime Now { get {
        if(Now == null) return Datetime.now();
        else return Now;
    } set; }
}