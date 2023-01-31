public class CXP_UtilityClass {
    
    public static string phoneNumberFormatter(string phoneNumber, string countryIsoForReplace, string prefixNumber)
    {
        if(string.isNotBlank(phoneNumber) && phoneNumber !=null)
        {
            phoneNumber=phoneNumber.replaceAll('[^0-9]', '');
            if(string.isNotBlank(countryIsoForReplace) 
               && countryIsoForReplace!=null 
               && phoneNumber.startsWith(countryIsoForReplace))
                phoneNumber=phoneNumber.removeStart(countryIsoForReplace);
            if( prefixNumber!=null 
               && string.isNotBlank(prefixNumber) 
               && !phoneNumber.startsWith(prefixNumber))
                phoneNumber=prefixNumber+phoneNumber;   
        }
        return phoneNumber;
    }
}