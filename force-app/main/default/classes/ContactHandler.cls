public class ContactHandler {
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();    
    public static Id retailerContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
    public static Id jlrContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    public static Id EmployeeContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
    
    private static final Map<String, Map<SObjectType, String>> fieldMapping = new Map<String, Map<SObjectType, String>>{
        Schema.Contact.FirstNameLocal.getDescribe().getName()=>new Map<SObjectType, String>{ 
            Schema.Task.SObjectType=>Schema.Task.First_Name_Local__c.getDescribe().getName(),
                Schema.Event.SObjectType=>Schema.Event.First_Name_Local__c.getDescribe().getName()},
                    Schema.Contact.LastNameLocal.getDescribe().getName()=>new Map<SObjectType, String>{ 
                        Schema.Task.SObjectType=>Schema.Task.Last_Name_Local__c.getDescribe().getName(),
                            Schema.Event.SObjectType=>Schema.Event.Last_Name_Local__c.getDescribe().getName()}
    };
        
        private static final Map<SObjectType, String> childRelationshipMap = new Map<SObjectType, String>{
            Schema.Task.SObjectType=>Schema.Task.WhoId.getDescribe().getName(),
                Schema.Event.SObjectType=>Schema.Event.WhoId.getDescribe().getName()
                };
                    
                    
         public void PreCreate(List<Contact> contacts)
                {
                    PrimaryAccountContactLogic prcl = new PrimaryAccountContactLogic();
                    List<Contact> contactsForConsents = new List<Contact>();
                    List<Contact> newSecondaryContacts = new List<Contact>();
                    Set<Id> newSecondaryContactAccountIds = new Set<Id>();
                    if (UserInfo.getUserType()=='Standard' || UserInfo.getUserType()=='PowerPartner')  {
                        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
                        sObjectCountrySetter.SetCountryFromOwner(contacts,  new List<Schema.DescribeFieldResult> { Contact.MailingCountry.getDescribe(), Contact.aop_Country__c.getDescribe() });
                    }

                    //List<Contact> snapInContacts = New List<Contact>();
                    
                    for(Contact c : contacts){
                        /*if(c.LA_Opt_In__c != null && c.LA_Opt_In__c != ''){
                            snapInContacts.add(c);                                     
                        }*/
                        if(c.AccountId != null && c.RecordTypeId == retailerContactRecordType){
                			newSecondaryContacts.add(c); 
                			newSecondaryContactAccountIds.add(c.AccountId);
            			}
                        if (c.AccountId != null && c.IndividualId == null && c.RecordTypeId == retailerContactRecordType) contactsForConsents.add(c);
                    }

                    if (!contactsForConsents.isEmpty()) ConsentHandler.setConsents(contactsForConsents);

                    /*if(!snapInContacts.isEmpty()){
                        for(Contact c : contacts){
                            switch on c.LA_Opt_In__c{
                                when 'LY'{
                                    c.et4ae5__HasOptedOutOfMobile__c = false;
                                    c.DoNotCall = false;
                                    c.Direct_Mail_Opt_Out__c = false;
                                    c.HasOptedOutOfEmail = false;
                                    c.Land_Rover_Whitemail_Opt_Out__c = false;
                                    c.Land_Rover_Email_Opt_Out__c = false;
                                    c.Land_Rover_Phone_Opt_Out__c = false;
                                    c.Land_Rover_SMS_Opt_Out__c = false;
                                    c.Jaguar_Whitemail_Opt_Out__c  = false;
                                    c.Jaguar_Email_Opt_Out__c = false;
                                    c.Jaguar_Phone_Opt_Out__c  = false;
                                    c.Jaguar_SMS_Opt_Out__c = false;
                                }
                                when 'LN'{                         
                                    c.Land_Rover_Whitemail_Opt_Out__c = true;
                                    c.Land_Rover_Email_Opt_Out__c = true;
                                    c.Land_Rover_Phone_Opt_Out__c = true;
                                    c.Land_Rover_SMS_Opt_Out__c = true;
                                    c.Jaguar_Whitemail_Opt_Out__c  = false;
                                    c.Jaguar_Email_Opt_Out__c = false;
                                    c.Jaguar_Phone_Opt_Out__c  = false;
                                    c.Jaguar_SMS_Opt_Out__c = false;
                                    
                                }
                                when 'JY'{
                                    c.Jaguar_Whitemail_Opt_Out__c  = false;
                                    c.Jaguar_Email_Opt_Out__c = false;
                                    c.Jaguar_Phone_Opt_Out__c  = false;
                                    c.Jaguar_SMS_Opt_Out__c = false;
                                    c.Land_Rover_Whitemail_Opt_Out__c = false;
                                    c.Land_Rover_Email_Opt_Out__c = false;
                                    c.Land_Rover_Phone_Opt_Out__c = false;
                                    c.Land_Rover_SMS_Opt_Out__c = false;
                                }
                                when 'JN'{
                                    c.Jaguar_Whitemail_Opt_Out__c  = true;
                                    c.Jaguar_Email_Opt_Out__c = true;
                                    c.Jaguar_Phone_Opt_Out__c  = true;
                                    c.Jaguar_SMS_Opt_Out__c = true;
                                    c.Land_Rover_Whitemail_Opt_Out__c = false;
                                    c.Land_Rover_Email_Opt_Out__c = false;
                                    c.Land_Rover_Phone_Opt_Out__c = false;
                                    c.Land_Rover_SMS_Opt_Out__c = false;
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                        
                    }

                    for(Contact c : contacts){
                        if(c.AccountId != null && c.RecordTypeId == retailerContactRecordType){
                            newSecondaryContacts.add(c); 
                            newSecondaryContactAccountIds.add(c.AccountId);
                        }
                    }*/
                    if(!newSecondaryContacts.isEmpty()){
                        prcl.preCreateSecondaryContact(false, newSecondaryContacts, newSecondaryContactAccountIds);
                    }
                    
                    //Added By Suhan Jain on June2020 as part of CXPD-714
        ContactPhoneNumberFormatter.phoneFormatterOnInsertUpdate(contacts);
                    
                }
    
    public void PreUpdate(List<Contact> currentContacts, List<Contact> oldContacts, Map<Id,Contact> oldContactsMap) 
    {
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        ChildSObjectLocalFieldUpdater childSObjectLocalFieldUpdater = new ChildSObjectLocalFieldUpdater(fieldMapping, childRelationshipMap);
        
        sObjectCountrySetter.EqualiseCountryAndCodes(currentContacts, oldContacts, Contact.MailingCountry.getDescribe());
        childSObjectLocalFieldUpdater.UpdateChildren(currentContacts, oldContacts);
        
        //Added By Suhan Jain on June2020 as part of CXPD-714
        ContactPhoneNumberFormatter.phoneFormatterOnInsertUpdate(currentContacts);

        VehicleOwnersController.UpdateImportantInfoHasChangedOnContact(currentContacts, oldContactsMap);
        
        for (Contact c : currentContacts) {
            Contact oldCon = oldContactsMap.get(c.Id);

            //Update Contactability Last Modified Date
            if (c.Email != oldCon.Email || c.Phone != oldCon.Phone || c.MobilePhone != oldCon.MobilePhone) c.Contactability_Last_Modified_Date__c = Datetime.now();
        }
    }
    
    public void PostUpdate(List<Contact> currentContacts, List<Contact> oldContacts, Map<Id,Contact> oldContactsMap) 
    {
        
        PrimaryContactUpdate pcu = new PrimaryContactUpdate();
        List<Contact> contactsPrimary = new List<Contact>();
        Set<Id> primaryContactsId = new Set<Id>();
        List<Contact> contactsForConsents = new List<Contact>();

        for(Contact c : currentContacts){
            Contact oldContact = oldContactsMap.get(c.Id);

            if(c.Primary_Contact__c != null && oldContactsMap.get(c.id).Primary_Contact__c == null){
                contactsPrimary.add(c);
                primaryContactsId.add(c.Primary_Contact__c);
            }
            
            if (c.AccountId != null && c.IndividualId != null && c.RecordTypeId == retailerContactRecordType && ConsentHandler.syncConsents && (c.HasOptedOutOfEmail != oldContact.HasOptedOutOfEmail || c.DoNotCall != oldContact.DoNotCall || c.et4ae5__HasOptedOutOfMobile__c != oldContact.et4ae5__HasOptedOutOfMobile__c || c.Direct_Mail_Opt_Out__c != oldContact.Direct_Mail_Opt_Out__c)) contactsForConsents.add(c);
        }

        if (!contactsForConsents.isEmpty()) ConsentHandler.updateConsents(contactsForConsents);

        Map<ID,List<Contact>> JPRetAccountContactMap = JPFetchRecords(currentContacts);
        if(JPRetAccountContactMap.keySet().size() > 0){
            JPValidateDefaultRetailerOwner(JPRetAccountContactMap);
        }
        if( !contactsPrimary.isEmpty()){
            pcu.PostCreatePrimaryContact(contactsPrimary, primaryContactsId);
        }
       
        
    }
    public void PostCreate(List<Contact> contacts)
    {
        SetRetailerForRetailerContact setRetailerForRetailerContact = new SetRetailerForRetailerContact();
        List<Contact> contactsForConsents = new List<Contact>();

        setRetailerForRetailerContact.SetRetailer(contacts);
        
                 PrimaryContactUpdate pcu = new PrimaryContactUpdate();
        List<Contact> contactsPrimary = new List<Contact>();
        Set<Id> primaryContactsId = new Set<Id>();
        Map<ID,List<Contact>> JPRetAccountContactMap = JPFetchRecords(contacts);
        for(Contact c : contacts){
            if(c.Primary_Contact__c != null){
                contactsPrimary.add(c);
                primaryContactsId.add(c.Primary_Contact__c);
            }
            
            if (c.AccountId != null && c.IndividualId != null && c.RecordTypeId == retailerContactRecordType) contactsForConsents.add(c);
        }
        
        if (!contactsForConsents.isEmpty()) ConsentHandler.updateConsents(contactsForConsents);

        if(JPRetAccountContactMap.keySet().size() > 0){
            JPValidateDefaultRetailerOwner(JPRetAccountContactMap);
        }
        if( !contactsPrimary.isEmpty()){
            pcu.PostCreatePrimaryContact(contactsPrimary, primaryContactsId);
        }
        
        
    }
    
    public void duplicateChecker(List<Contact> newContacts){
        
        Schema.DescribeSObjectResult r = Contact.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        String currentUrl = String.valueOf(URL.getCurrentRequestUrl()).toLowerCase();
        if(!(currentUrl.containsIgnoreCase('/'+keyPrefix+'/e') || currentUrl.containsIgnoreCase('/aura'))){
            for(Contact acct: newContacts){
                acct.Pass_Duplicate_Rule__c = true;
            }
        }
    }
    
    // Shuho - Validate Retailer to have only one Default user marked on Contact
    public Map<ID,List<Contact>> JPFetchRecords (List<Contact> Contacts){
        Map<ID,List<Contact>> JPRetAccountContactMap = new Map<ID,List<Contact>>();
        for(Contact c : Contacts){
            if(c.RecordTypeID == EmployeeContactRecordType && (c.Contact_Region_or_Market__c == 'JP' || c.Contact_Region_or_Market__c == 'Japan') && c.Default_Retailer_Record_Owner__c == TRUE){
                List<Contact> JPEmployeeContacts = JPRetAccountContactMap.get(c.AccountID);
                if(JPEmployeeContacts == null)
                    JPRetAccountContactMap.put(c.AccountID,new List<Contact>{c});
                else{
                    JPEmployeeContacts.add(c);
                    JPRetAccountContactMap.put(c.AccountID,JPEmployeeContacts);
                }
            }
        }
        return JPRetAccountContactMap;
    }
    
    // Shuho - Validate Retailer to have only one Default user marked on Contact
    public void JPValidateDefaultRetailerOwner(Map<ID,List<Contact>> JPRetAccountContactMap){ 
        for(AggregateResult ar : [Select Count(Id),AccountID from Contact where Default_Retailer_Record_Owner__c = TRUE AND AccountID IN: JPRetAccountContactMap.keyset() Group By AccountID]){
            if( (Integer)ar.get('expr0') > 1 ){
                for( Contact con : JPRetAccountContactMap.get((ID)ar.get('AccountID'))){
                    con.addError('There is already an existing Contact who is the Default owner, please contact NSC Admin.');
                }
            }
        }
    }
    
}