public class AccountPhoneNumberFormatter {
    
    public static void phoneFormatterOnInsertUpdate(List<Account> newAccount){
        for(Account Acc:newAccount)
        {
            if(Acc.Country_ISO_Code__c=='AU')
            {
              	acc.PersonAssistantPhone=CXP_UtilityClass.phoneNumberFormatter(acc.PersonAssistantPhone, '61', '0');
              	acc.PersonHomePhone=CXP_UtilityClass.phoneNumberFormatter(acc.PersonHomePhone, '61', '0');
                acc.PersonMobilePhone=CXP_UtilityClass.phoneNumberFormatter(acc.PersonMobilePhone, '61', '0');
                acc.PersonOtherPhone=CXP_UtilityClass.phoneNumberFormatter(acc.PersonOtherPhone, '61', '0');
                acc.Phone=CXP_UtilityClass.phoneNumberFormatter(acc.Phone, '61', '0');
               
                acc.Assistant_Phone_Hidden__pc=CXP_UtilityClass.phoneNumberFormatter(acc.Assistant_Phone_Hidden__pc, '61', '0');
                acc.Other_Phone_Hidden__pc=CXP_UtilityClass.phoneNumberFormatter(acc.Other_Phone_Hidden__pc, '61', '0');
                acc.Work_Order_contact_Home_Phone__pc=CXP_UtilityClass.phoneNumberFormatter(acc.Work_Order_contact_Home_Phone__pc, '61', '0');
                acc.Work_Order_contact_Mobile_Phone__pc=CXP_UtilityClass.phoneNumberFormatter(acc.Work_Order_contact_Mobile_Phone__pc, '61', '0');
                acc.Work_Order_contact_Work_Phone__pc=CXP_UtilityClass.phoneNumberFormatter(acc.Work_Order_contact_Work_Phone__pc, '61', '0');

            }
        }
    }
}