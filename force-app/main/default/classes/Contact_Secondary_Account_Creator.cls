public class Contact_Secondary_Account_Creator {
  public static Id retailerContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
    public List<Contact> createClonedSecondaryContact(Set<Id> primconts, List<Account> seCccs)
    {
        Map<Id,Account> primaryAcctoSecondaryAcc = new Map<Id,Account>();
        for(Account acc : seCccs){
           primaryAcctoSecondaryAcc.put(acc.primary_account__c, acc);
        }
        
        
        List<Contact> newlyCreatedContacts = new List<Contact>();
        List<Contact> primaryContacts = [SELECT Id,
                           Contacts__c,
                           X18_Digit_ID__c,
                                         AccountId,
                           Account_Country_Iso_Code__c, 
                           Account_Name_Local__c,
                           Account_Pseudo_Owner_Id__c,
                           Account_Queue_ID__c,
                           Additional_Notes__c,
                           Address_Validation_Status__c,
                           CanAllowPortalSelfReg,
                           Annual_Mileage__c,
                           aopcom_contactPortrait__c,
                           Are_All_Preferences_Set__c,
                           AssistantName,
                           Assistant_Name_Hidden__c,
                           Assistant_Phone_Hidden__c,
                           AssistantPhone,
                           Birthdate,
                           Birthdate_Hidden__c,
                           Birthday__c, Calculated_Email__c, Campaign_from_Lead__c, Change_Current_Car_months__c,
                           Checked_for_Deletion__c, Confirm_Deceased__c, CurrencyIsoCode, OwnerId,
                           Contact_Owner_Phone_Number__c,RecordTypeId, Contact_Region_or_Market__c,
                           aop_Country__c, Country_ISO_Code__c, CreatedById, Jigsaw,
                           Deceased_Date__c, Data_Quality_Description__c, Data_Quality_Score__c,
                           Department, Description, Dislikes_About_Current_Car__c,
                           DMS_Identifier__c, Driving_Experience_Interests__c, Email,
                           Email2__c, Email3__c, Employment_Status__c,Essential_Use_of_the_Car__c,
                           Fax, FirstNameLocal, FPACE_Marketing__c, Gender__c, Guest_Name__c,
                           Net_Worth__c, Historical_Contact__c, HNW_contact__c, HomePhone, Household_Income__c,
                           IndividualId, Interests__c, aop_Is_Qualified_for_Events__c, Jaguar_Gold_Starred__c,
                           Jaguar_Gold_Starred_Date__c, Jaguar_Red_Flagged__c,
                           Jaguar_Red_Flagged_Date__c, 
                           Direct_Mail_Opt_Out__c, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, et4ae5__HasOptedOutOfMobile__c,
                           Language__c,
                           LastModifiedById,
                           LastNameLocal,
                           LastName,
                           aop_Last_Qualifying_Event__c,
                           LastCURequestDate,
                           LastCUUpdateDate,
                           LeadSource,
                           Likes_About_Current_Car__c,
                           MailingAddress,
                           Marital_Status__c,
                           Membership_Number__c,
                           MENA_Reference__c,
                           MENA_Reference2__c,
                           MobilePhone,
                           et4ae5__Mobile_Country_Code__c,
                           Must_Have_Features__c,
                           Name,
                           Next_Activity_Date__c,
                           No_of_Cars_In_Household__c,
                           No_of_Children__c,
                           No_of_Passengers__c,
                           No_of_People_In_Household__c	,
                           Number_of_Open_Cases__c,
                           Occupation__c,
                           LA_Opt_In__c,
                           OtherAddress,
                           OtherPhone,
                           Other_Phone_Hidden__c,
                           Owners_Club_Requested__c	,
                           Parent_Record__c,
                           Parent_Record_Local__c,
                           Pass_Duplicate_Rule__c,
                           Phone,
                           Preferred_Contact_Time__c,
                           Primary_Account__c,
                           Primary_Contact__c,
                           Privacy_Code__c,
                           ReportsToId,
                           Retailer__c,
                           Retailer_Local__c,
                           Retailer_Name__c,
                           Service_advisor_name__c,
                           Site__c,
                           Space_and_Towing__c,
                           State__c,
                           aop_Suspended_for_Events__c,
                           aop_Suspension_Reason__c,
                           TimeLastSentToDMS__c,
                           Title,
                           Trade_In_Valuation__c,
                           Translation_Language_Key__c,
                           Unable_To_Contact__c	,
                           Unsubscribe_Reason__c,
                           Usual_Method_of_Finance__c,
                           LA_Subject__c,
                           Who_Else_Will_be_Driving_the_Car__c,
                           Who_is_the_Main_Driver__c,
                           Work_Order_contact_Email_Address__c,
                           Work_Order_contact_First_Name__c,
                           Work_Order_contact_Home_Phone__c,
                           Work_Order_contact_Mobile_Phone__c,
                           Work_Order_contact_Surname__c,
                           Work_Order_contact_Title__c,
                           Work_Order_contact_Work_Phone__c,
                           Zip_Postal_Code__c
                           FROM Contact WHERE Id IN :primconts];
       
        
        for(Contact primary : primaryContacts){
            
             Contact secondary = new Contact();
       
        if(primary != null)
        {
            secondary = primary.clone(false,true,false,false);
           //if(primary. != null ){  secondary. = primary.; }
     
        }
        secondary.RecordTypeId = retailerContactRecordType;
        secondary.Primary_Account__c = primary.AccountId; // secAcc.Id;
        secondary.AccountId = primaryAcctoSecondaryAcc.get(primary.accountId).Id; // acc.Id
        secondary.Primary_Contact__c = Primary.Id;
        secondary.ownerId = primaryAcctoSecondaryAcc.get(primary.accountId).OwnerId;
        newlyCreatedContacts.add(secondary);
         }
        insert newlyCreatedContacts;
        return newlyCreatedContacts;
    }
    
    
}