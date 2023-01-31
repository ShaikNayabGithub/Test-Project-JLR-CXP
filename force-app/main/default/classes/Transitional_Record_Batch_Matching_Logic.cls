public class Transitional_Record_Batch_Matching_Logic {
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    public static List<Dispensable_Value__mdt> spamValues =  [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Category__c, Is_Full_Text__c FROM Dispensable_Value__mdt];
    
    
    public List<Transitional_Record__c> processRetailerTrans(List<Transitional_Record__c> transRecords){
        
        //search
        // Email_Address_1__c,
        Set<string> setEmailsLowerCase = new Set<String>();
        //  Business_Telephone_Number__c, Home_Telephone_Number__c, Mobile_Telephone_Number__c 
        List<User> dummyOwners;
        Set<String> setNumber = new Set<String>();
        List<Account> potentialMatches = new List<Account>();
        //country_code__c
        Set<String> setCountryIsoCode = new Set<String>();
        List<Account> accsToCreate = new List<Account>();
        //can't use stripped values when selecting large
        Set<String> setCompanyNames = new Set<String>();
        Map<String, List<Account>> countryToListRetailerAccountMap = new   Map<String, List<Account>>();
        //Map
        Map<String, List<Account>> countryToListAccountMap = new   Map<String, List<Account>>();
        Map<String, Account> tranIdToAccountMap = new  Map<String, Account>(); 
        Set<Id> retailerAccountIdsAndParents = new Set<Id>();
        TransitionalRecordAccountCreator rnAccountCreator = new TransitionalRecordAccountCreator();
        //can't use stripped values when selecting large
        Set<String> setLastNames = new Set<String>();
        Map<String,String> isoToCountry = new Map<String,String>();
        
        List<aop_NationalityToISOCode__c> phoneDiallingNumber = [SELECT aop_ISO_Code__c, Dialing_Code__c FROM aop_NationalityToISOCode__c WHERE aop_ISO_Code__c != null AND Dialing_Code__c != NULL ];
        // aop_NationalityToISOCode__c
        for(aop_NationalityToISOCode__c code : phoneDiallingNumber){
            if(!isoToCountry.containsKey(code.aop_ISO_Code__c)){
                isoToCountry.put(code.aop_ISO_Code__c, code.Dialing_Code__c);
            }
        }
        //Get Parameters to select
        for(Transitional_Record__c tran : transRecords){
            if(tran.Email_Address_1__c != null && tran.Email_Address_1__c != null){
                
                setEmailsLowerCase.add(tran.Email_Address_1__c.toLowerCase());
            }
            if(tran.Business_Telephone_Number__c != null && tran.Business_Telephone_Number__c != null){
                
                setNumber.add(tran.Business_Telephone_Number__c);
            }
            if(tran.Home_Telephone_Number__c != null && tran.Home_Telephone_Number__c != null){
                
                setNumber.add(tran.Home_Telephone_Number__c);
            }
            
            if(tran.country_code__c != null && tran.country_code__c != '' ){
                setCountryIsoCode.add(tran.country_code__c);
            }
            
            if(tran.Company_Name__c != null && tran.Company_Name__c != '' ){
                setCompanyNames.add(tran.Company_Name__c);
            }
            if(tran.Surname_Field_1__c != null && tran.Surname_Field_1__c != '' ){
                setLastNames.add(tran.Surname_Field_1__c);
            }
            
            
            
            
        }
        //Search
        
  
      //  system.debug('setCompanyNames');
      //  system.debug(setCompanyNames);
      //  system.debug('setCountryIsoCode');
      //  system.debug(setCountryIsoCode);
        potentialMatches = [SELECT Id,FirstName,Recordtype.name,  Parent_Retailer__c  ,Brand__c,Parent.Name, Name, LastName,Country_ISO_Code__c, RecordtypeId,PersonMobilePhone, PersonHomePhone, PersonOtherPhone, Phone, Retailer_Email__c, PersonEmail, email2__pc ,email3__pc, 
                            (SELECT Id, FirstName, LastName FROM Contacts) FROM Account WHERE ((RecordtypeId = :individualRecordType OR RecordtypeId = :corporateRecordType ) 
                                                                                               AND Country_Iso_code__c IN :setCountryIsoCode  
                                                                                               AND (Name IN :setCompanyNames OR LastName IN :setLastNames)) or (RecordtypeId = :retailerRecordType AND Country_Iso_code__c IN :setCountryIsoCode AND Retailer_Type__c = 'Importer' )  ];
        
        //PersonMobilePhone, PersonHomePhone, PersonOtherPhone, Phone, Retailer_Email__c, PersonEmail, email2__pc ,email3__pc
       // system.debug('potentialMatches');
        
        for(Account acc : potentialMatches){
      //      system.debug('acc '+acc.Name + '  ' + acc.Country_ISO_Code__c+ '  '+acc.recordtype.name);
            if(acc.RecordTypeId != retailerRecordType){
                if( countryToListAccountMap.containsKey(acc.country_iso_Code__c)) {
                    List<Account> accs = countryToListAccountMap.get(acc.country_iso_Code__c);
                    accs.add(acc);
                    countryToListAccountMap.put(acc.country_iso_Code__c, accs);
          //          system.debug('added to list');
                } else {
         //           system.debug('added to new list');
                    countryToListAccountMap.put(acc.country_iso_Code__c, new List<Account> { acc });
                }
            }else{
                if(countryToListRetailerAccountMap.containsKey(acc.country_iso_Code__c)) {
                    List<Account> accs = countryToListRetailerAccountMap.get(acc.country_iso_Code__c);
                    accs.add(acc);
                    countryToListRetailerAccountMap.put(acc.country_iso_Code__c, accs);
                } else {
                    countryToListRetailerAccountMap.put(acc.country_iso_Code__c, new List<Account> { acc });
                }
            }
            
            
            
            
        }
        dummyOwners = [Select id , name, contact.accountid,contact.account.Brand__c, country_iso_code__c FROM User where Name Like '%DummyIMP%'AND IsActive = true ];
      //  system.debug('countryToListAccountMap' +countryToListAccountMap);
        /*

1 Company Name + Email	             Account Name + Account: Email	 
2 Company Name + ANY Phone			Account Name + Account: ANY Phone 	
3Company Name
AND First Name + Last Name				Account Name
AND Contact: First Name + Last Name	
5First Name + Last Name + email					First Name + Last Name + ANY email	
6 First Name + Last Name + ANY Phone					First Name + Last Name + ANY phone
*/
        /*do we want to loop through all records each time for best match, very time consuming*/
        For(Transitional_Record__c tran : transRecords){
          //  system.debug('tran.Country_Code__c '+tran.Country_Code__c);
            
            if(tran.Country_Code__c != null &&  countryToListAccountMap.containsKey(tran.Country_Code__c) ){
                List<Account> accPotentials = countryToListAccountMap.get(tran.Country_Code__c);
                string tranPhone;
                string tranMobPhone;
                string tranBusPhone;
            //    system.debug('cut down list');//isoToCountry
                if( tran.Country_Code__c != null && isoToCountry.containsKey(tran.Country_Code__c) ){
                    if(tran.Business_Telephone_Number__c != null && tran.Business_Telephone_Number__c != ''){
             //           tranBusPhone = isoToCountry.get(tran.Country_Code__c ) + tran.Business_Telephone_Number__c;
                    } 
                    if(tran.Home_Telephone_Number__c != null && tran.Home_Telephone_Number__c != ''){
                        tranPhone = isoToCountry.get(tran.Country_Code__c ) + tran.Home_Telephone_Number__c;
               //         system.debug('tranPhone '+tranPhone);
                    }
                    if(tran.Mobile_Telephone_Number__c != null && tran.Mobile_Telephone_Number__c != ''){
                        tranMobPhone = isoToCountry.get(tran.Country_Code__c ) + tran.Mobile_Telephone_Number__c;
                 //       system.debug('tranMobPhone '+tranMobPhone);
                    }
                    
                }
                for(Account acc : accPotentials){
                    
                    
                    
                //    system.debug('Name '+acc.name);
                //    system.debug('Id '+acc.Id);
                    //1 Company Name + Email	             Account Name + Account: Email	 
                    if(acc.RecordtypeId == corporateRecordType &&  acc.Name == tran.Company_Name__c && acc.Retailer_Email__c != null && acc.Retailer_Email__c == tran.Email_Address_1__c){
                        //Match One
                    //    system.debug('Matched on 1 '+acc);
                        tran.Matched_Existing_Account__c = acc.Id;
                        break;
                        
                    }
                    // 2 Company Name + ANY Phone			Account Name + Account: ANY Phone 	
                    // PersonMobilePhone, PersonHomePhone, PersonOtherPhone, Phone,
                    if(acc.RecordtypeId == corporateRecordType &&  acc.Name == tran.Company_Name__c &&  (    (acc.Phone != null && acc.phone == tran.Business_Telephone_Number__c ) ||  (acc.Phone != null && acc.phone == tran.Home_Telephone_Number__c )  ||  (acc.Phone != null && acc.phone == tran.Mobile_Telephone_Number__c )  ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tran.Business_Telephone_Number__c )  ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tran.Home_Telephone_Number__c )  ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tran.Mobile_Telephone_Number__c )  ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tran.Business_Telephone_Number__c )   ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tran.Home_Telephone_Number__c )  ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tran.Mobile_Telephone_Number__c )  ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tran.Business_Telephone_Number__c )  ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tran.Home_Telephone_Number__c )    ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tran.Mobile_Telephone_Number__c ) 
                       ) 
                      ){
                          //Match Two
                    //      system.debug('Matched on 2 '+acc);
                          tran.Matched_Existing_Account__c = acc.Id;
                          break;
                          
                      }
                    if( acc.RecordtypeId == corporateRecordType &&  acc.Name == tran.Company_Name__c &&  (    (acc.Phone != null && acc.phone == tranBusPhone )    ||  (acc.Phone != null && acc.phone == tranPhone )   ||  (acc.Phone != null && acc.phone == tranMobPhone )    ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tranBusPhone )  ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tranPhone )  ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tranMobPhone ) ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tranBusPhone )  ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tranPhone ) ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tranMobPhone )  ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tranBusPhone )    ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tranPhone )  ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tranMobPhone )
                       ) 
                      ){
                          //Match Two
                   //       system.debug('Matched on 2 on isocode '+acc);
                          tran.Matched_Existing_Account__c = acc.Id;
                          break;
                          
                      }
                    if(acc.RecordtypeId == corporateRecordType &&  acc.Name == tran.Company_Name__c && acc.contacts != null && acc.contacts.size() > 0 ){
                    //    system.debug('Matched on 3 with contacts '+acc);
                        boolean foundContact = false;
                        for(Contact con : acc.contacts){    
                       //     system.debug('Matched on 3 with con '+con);
                            if(!foundContact && con.FirstName != null && con.LastName != null  && tran.First_Name__c == con.FirstName  && tran.Surname_Field_1__c == con.LastName ){
                                foundContact = true;
                            }                                           
                        }
                        if(foundContact){
                        //    system.debug('Matched on 3 '+acc);
                            tran.Matched_Existing_Account__c = acc.Id;
                            break;
                        }
                        
                    }
                  //  system.debug('LastName '+acc.LastName);
                  //  system.debug('tran.Surname_Field_1__c '+tran.Surname_Field_1__c);
                 //   system.debug('FirstName '+acc.FirstName);
                 //   system.debug('tran.First_Name__c '+tran.First_Name__c);
                   // system.debug(acc);            
                    if(acc.RecordtypeId == individualRecordType  &&    acc.LastName != null &&  acc.LastName == tran.Surname_Field_1__c &&    acc.FirstName != null &&  acc.FirstName == tran.First_Name__c &&  tran.Email_Address_1__c != null &&
                       
                       ( 
                           (acc.PersonEmail != null && acc.PersonEmail == tran.Email_Address_1__c)
                           || (acc.email2__pc != null && acc.email2__pc == tran.Email_Address_1__c)
                           || (acc.email3__pc != null && acc.email3__pc == tran.Email_Address_1__c)                 
                       )
                       
                      ){
                         // system.debug('Matched on 4 '+acc);
                          tran.Matched_Existing_Account__c = acc.Id;
                          break;
                          
                      }
                    if(acc.RecordtypeId == individualRecordType  &&    acc.LastName != null &&  acc.LastName == tran.Surname_Field_1__c &&    acc.FirstName != null &&  acc.FirstName == tran.First_Name__c  &&     (  (acc.Phone != null && acc.phone == tran.Business_Telephone_Number__c )   ||  (acc.Phone != null && acc.phone == tran.Home_Telephone_Number__c )  ||  (acc.Phone != null && acc.phone == tran.Mobile_Telephone_Number__c )   ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tran.Business_Telephone_Number__c )    ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tran.Home_Telephone_Number__c )     ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tran.Mobile_Telephone_Number__c )   ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tran.Business_Telephone_Number__c ) ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tran.Home_Telephone_Number__c ) ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tran.Mobile_Telephone_Number__c )   ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tran.Business_Telephone_Number__c )    ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tran.Home_Telephone_Number__c )  ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tran.Mobile_Telephone_Number__c )     
                       ) ){
                        //  system.debug('Matched on 5 '+acc);
                          tran.Matched_Existing_Account__c = acc.Id;
                          break;
                          
                      }
                    
                    if(acc.RecordtypeId == individualRecordType  &&    acc.LastName != null &&  acc.LastName == tran.Surname_Field_1__c &&    acc.FirstName != null &&  acc.FirstName == tran.First_Name__c  &&
                       
                       ( 
                           (acc.Phone != null && acc.phone == tranBusPhone )  ||  (acc.Phone != null && acc.phone == tranPhone ) ||  (acc.Phone != null && acc.phone == tranMobPhone ) ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tranBusPhone )  ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tranPhone )  ||  (acc.PersonMobilePhone != null && acc.PersonMobilePhone == tranMobPhone )  ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tranBusPhone )   ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tranPhone )  ||  (acc.PersonHomePhone != null && acc.PersonHomePhone == tranMobPhone ) ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tranBusPhone )   ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tranPhone )  ||  (acc.PersonOtherPhone != null && acc.PersonOtherPhone == tranMobPhone )      
                       )
                       
                      ){
                         // system.debug('Matched on 5 non country '+acc);
                          tran.Matched_Existing_Account__c = acc.Id;
                          break;
                          
                      }
                }
            }
            
            if(tran.Matched_Existing_Account__c == null){
                Account acc = rnAccountCreator.tranNewAccountCreator(tran);
                for(User usr : dummyOwners){
                    
                    // LB or KW 
                    if(usr.country_iso_code__c != null && usr.country_iso_code__c != 'LB' && usr.country_iso_code__c != 'KW' && usr.country_iso_code__c == tran.Country_Code__c){
                        acc.ownerid = usr.Id; 
                        acc.Owner_Retailer__c  = String.valueOf(usr.Contact.accountId);
                        break;
                    }
                    if(usr.country_iso_code__c != null  && usr.country_iso_code__c == 'KW' && usr.country_iso_code__c == tran.Country_Code__c && usr.contact.account.Brand__c != null && usr.contact.account.Brand__c == tran.Manufacturer__c ){
                        acc.ownerid = usr.Id;                             
                        acc.Owner_Retailer__c  = String.valueOf(usr.Contact.accountId);
                        break;
                    }
                    if(usr.country_iso_code__c != null && usr.country_iso_code__c == 'LB' && usr.country_iso_code__c == tran.Country_Code__c  && usr.contact.account.Brand__c != null && usr.contact.account.Brand__c == tran.Manufacturer__c ){
                        acc.ownerid = usr.Id; 
                        acc.Owner_Retailer__c  = String.valueOf(usr.Contact.accountId);
                        break;
                    }
                    if(usr.country_iso_code__c != null  && usr.country_iso_code__c == 'KW' && usr.country_iso_code__c == tran.Country_Code__c  && usr.contact.account.Brand__c != null && usr.contact.account.Brand__c == tran.Manufacturer__c ){
                        acc.ownerid = usr.Id; 
                        acc.Owner_Retailer__c  = String.valueOf(usr.Contact.accountId);
                        break;
                    }
                    if(usr.country_iso_code__c != null && usr.country_iso_code__c == 'LB' && usr.country_iso_code__c == tran.Country_Code__c  && usr.contact.account.Brand__c != null && usr.contact.account.Brand__c == tran.Manufacturer__c ){
                        acc.ownerid = usr.Id;
                        acc.Owner_Retailer__c  = String.valueOf(usr.Contact.accountId);
                        break;
                    }
                    
                }
                
                accsToCreate.add(acc);
            }
            
        }
        
        if(accsToCreate != null && accsToCreate.size() > 0 ){
            insert accsToCreate;  
            for(Account acc : accsToCreate){
                tranIdToAccountMap.put(acc.CustomerID__c, acc);
            }
        }
        //no search
        for(Transitional_Record__c tran : transRecords){
            if(tranIdToAccountMap.containsKey(tran.Id)){
                Account acc = tranIdToAccountMap.get(tran.Id);
                tran.New_Created_Account__c = acc.Id;
                tran.Status__c = 'Flagged For Review';
            }
            if(tran.Matched_Existing_Account__c != null ){
                tran.status__c = 'Matched to an Existing Account';
            }
            
        }
        
        
        return transRecords;
    }
    
    
    
    public List<Transitional_Record__c> processValidEmailCustomerTrans(List<Transitional_Record__c> transRecords){
        List<Dispensable_Value__mdt> nameStrip = new List<Dispensable_Value__mdt>();
        Transitional_Data_Cleanser transDC = new Transitional_Data_Cleanser();  
        List<Dispensable_Value__mdt> fullEmailStrip = new List<Dispensable_Value__mdt>();
        List<Dispensable_Value__mdt> partialEmailStrip = New List<Dispensable_Value__mdt>();
        Boolean areThereSpamEmailMetadataSetting = false;
        
        if(spamValues != null && spamValues.size() >0 ){
            
            
            for(Dispensable_Value__mdt disp : spamValues){
                if(disp.Category__c != null &&  disp.Category__c  == 'Email' && disp.Is_Full_Text__c == true){
                    fullEmailStrip.add(disp);
                    areThereSpamEmailMetadataSetting = true;
                }
                if(disp.Category__c != null &&  disp.Category__c  == 'Email' && disp.Is_Full_Text__c == false){
                    partialEmailStrip.add(disp);
                    areThereSpamEmailMetadataSetting = true;
                }
                
            }
        }
        nameStrip = transDC.orderByLengthSingleCategory('Name', spamValues);
        
        Set<Id> emailMatches = new Set<Id>();
        Set<Id> nameMatchesNoAction = new Set<Id>();
        Set<Id> nameMatchesUpdateEmail = new Set<Id>();
        Set<Id> flaggedForReview = new Set<Id>();
        Map<Id, Account> accountToUpdateEmailMap = new Map<Id, Account>();
        for(Transitional_Record__c tranRec : transRecords){
            if(tranRec.Email_Address_1__c != null && tranRec.Email_Address_1__c == tranRec.Current_Asset_Account_Email__c ){
                emailMatches.add(tranRec.id);
            }else{
                string strippedAccountName = transDC.stripSpacesAndSpam(tranRec.Current_Asset_Account__r.name,nameStrip );
                if(!accountToUpdateEmailMap.containsKey(tranRec.Current_Asset_Account__c) && (strippedAccountName == tranRec.Stripped_Company_Name__c || strippedAccountName == tranRec.Stripped_Individual_Name__c)){
                    if(tranRec.Email_Address_1__c == null || tranRec.Email_Address_1__c == '' || tranRec.Dummy_email__c == true){
                        nameMatchesNoAction.add(tranRec.Id);
                    }else{
                        nameMatchesUpdateEmail.add(tranRec.Id);
                        if(tranRec.Current_Asset_Account__r.RecordtypeId == goldenCorporateRecordType || tranRec.Current_Asset_Account__r.RecordtypeId == corporateRecordType){
                            if(tranRec.Current_Asset_Account__c != null ){
                                      Account accToUpdate = new Account();
                            accToUpdate.id = tranRec.Current_Asset_Account__c;
                            accToUpdate.Retailer_Email__c = tranrec.Email_Address_1__c;
                            accountToUpdateEmailMap.put(tranRec.Current_Asset_Account__c, accToUpdate); 
                            }
                     
                        }else{
                            Account accToUpdate = checkIndividualAndReturnUpdatedAccount(tranRec,  partialEmailStrip, fullEmailStrip );
                            if(accToUpdate != null && accToUpdate.id != null && tranRec.Current_Asset_Account__c != null ){
                                accountToUpdateEmailMap.put(tranRec.Current_Asset_Account__c, accToUpdate);
                            }
                            
                        }
                        
                        
                        
                    }                    
                }else{
                    flaggedForReview.add(tranRec.Id);
                }
                
            }
        }
        if(accountToUpdateEmailMap != null && accountToUpdateEmailMap.size() > 0){
            update accountToUpdateEmailMap.values();
            
        }
        /*
* Set<Id> emailMatches = new Set<Id>(); 'Email Matches'
Set<Id> nameMatchesNoAction = new Set<Id>(); 'Name Matched No Action'
Set<Id> nameMatchesUpdateEmail = new Set<Id>(); 'Name Match Email Updated'
*/
        for(Transitional_Record__c tranRec : transRecords){
            if(emailMatches.contains(tranRec.Id)){
                tranRec.Status__c = 'Email Matches';
            }
            if(nameMatchesNoAction.contains(tranRec.Id)){
                tranRec.Status__c = 'Name Matched No Action';
            }
            if(nameMatchesUpdateEmail.contains(tranRec.Id)){
                tranRec.Status__c = 'Name Matched Email Updated';
            }
            if(flaggedForReview.contains(tranRec.Id)){
                tranRec.Status__c = 'Flagged For Review';
            }
        }
        return transRecords;
    }
    
    public Account checkIndividualAndReturnUpdatedAccount(Transitional_Record__c tranRec, List<Dispensable_Value__mdt> partialEmailStrip, List<Dispensable_Value__mdt> fullEmailStrip ){
        
        Account toBeUpdated;
        
        Transitional_Data_Cleanser transDC = new Transitional_Data_Cleanser();  
        string email1 = tranRec.Current_Asset_Account__r.PersonEmail;
        string email2 = tranRec.Current_Asset_Account__r.Email2__pc;
        string email3 = tranRec.Current_Asset_Account__r.Email3__pc;
        if(email1 == null || email1 == '' ||  (email1 != null && email1 != ''  && transDC.isEmailSpam(email1, partialEmailStrip,fullEmailStrip )) ){
            toBeUpdated = new Account();
            toBeUpdated.id = tranRec.Current_Asset_Account__c;
            toBeUpdated.PersonEmail =  tranRec.Email_Address_1__c;
        }else{
            if(email2 == null || email2 == '' ||  (email2 != null && email2 != ''  && transDC.isEmailSpam(email2, partialEmailStrip,fullEmailStrip ))){
                toBeUpdated = new Account();
                toBeUpdated.id = tranRec.Current_Asset_Account__c;
                toBeUpdated.PersonEmail =  tranRec.Email_Address_1__c;
                toBeUpdated.Email2__pc =  email1;
            }else{
                toBeUpdated = new Account();
                toBeUpdated.id = tranRec.Current_Asset_Account__c;
                toBeUpdated.PersonEmail =  tranRec.Email_Address_1__c;
                toBeUpdated.Email2__pc =  email1;
                toBeUpdated.Email3__pc =  email2;
            }
        }
        return toBeUpdated;
    }
    
}