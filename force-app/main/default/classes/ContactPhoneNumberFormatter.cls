public class ContactPhoneNumberFormatter {
    public static void phoneFormatterOnInsertUpdate(List<Contact> newContact){
        for(Contact Con:newContact)
        {
            if(Con.Country_ISO_Code__c=='AU' || Con.Account_Country_Iso_Code__c=='AU')
            {
                Con.AssistantPhone=CXP_UtilityClass.phoneNumberFormatter(Con.AssistantPhone, '61', '0');
                Con.HomePhone=CXP_UtilityClass.phoneNumberFormatter(Con.HomePhone, '61', '0');
                Con.MobilePhone=CXP_UtilityClass.phoneNumberFormatter(Con.MobilePhone, '61', '0');
                Con.OtherPhone=CXP_UtilityClass.phoneNumberFormatter(Con.OtherPhone, '61', '0');
                Con.Phone=CXP_UtilityClass.phoneNumberFormatter(Con.Phone, '61', '0');
                
                Con.Assistant_Phone_Hidden__c=CXP_UtilityClass.phoneNumberFormatter(Con.Assistant_Phone_Hidden__c, '61', '0');
                Con.Other_Phone_Hidden__c=CXP_UtilityClass.phoneNumberFormatter(Con.Other_Phone_Hidden__c, '61', '0');
                Con.Work_Order_contact_Home_Phone__c=CXP_UtilityClass.phoneNumberFormatter(Con.Work_Order_contact_Home_Phone__c, '61', '0');
                Con.Work_Order_contact_Mobile_Phone__c=CXP_UtilityClass.phoneNumberFormatter(Con.Work_Order_contact_Mobile_Phone__c, '61', '0');
                Con.Work_Order_contact_Work_Phone__c=CXP_UtilityClass.phoneNumberFormatter(Con.Work_Order_contact_Work_Phone__c, '61', '0');
            }
        }
    }
    
}