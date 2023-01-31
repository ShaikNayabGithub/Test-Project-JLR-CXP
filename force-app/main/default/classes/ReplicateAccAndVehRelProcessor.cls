/*
* S.No.		Name		Date(DD/MM/YYYY)	Change
* 1.0		Ashwin		23/06/2021			CXPD-1358: Removed MENA Integration Consent Processing
* 
*/
//VVO MENA integration
public class ReplicateAccAndVehRelProcessor {
    public static FINAl String ORGANISATION='Organisation';
    public static Final String YES='Yes';
    Public static final string JAGUAR='Jaguar';
    public static final String LANDROVER='Land Rover';
    String accType;
    String firstName;
    String lastName;
    String country;
    String preferredLanguage;
    String companyName;
    string test;
    boolean jaguarAllConsent;
    boolean landroverAllConsent;
    integer jaguarCount=0;
    integer LandRoverCount=0;
    List<Account> listAccounts;
    List<Contact> listContacts;
    String accountId;
    String contactId;
    Contact contact;
    Account retailer;
    List<User> listUsers;
    String phone;
    
    String contactFirstName;
    String contactLastName;
    String contactCountry;
    String contactCountryCode;
    String contactPhone;
    String contactEmail;
    String contactpreferredLanguage;
    
    
    private static final String corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    private static final String individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    private static final String goldenCorporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    private static final String goldenIndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    private static final String retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    private static final String contactRetailerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
    
    public String process(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        
        String vin;  
        String email;    
        Asset asset;
        Account account;
        Account accountFromMessage;
        Contact contactFromMessage;
        String param;
        String result;
        user user;
        Account retailer;
        String dealerCode;
        String countrycode;
        String brand;
        List<string> InvalidEmailAddLst= New List<string>();
        List<Dispensable_Value__mdt	> invalidEmailSettingLst = [select Id, MasterLabel, Is_Full_Text__c from Dispensable_Value__mdt where Category__c='Email'];
        for(Dispensable_Value__mdt emails: invalidEmailSettingLst)
        {
            InvalidEmailAddLst.add(emails.MasterLabel);
        }
        
        List<account> listRetailers;
        if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns == null || replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0] == null ||replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct == null ){
            return 'Error:  Incomplete Message check Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct ';
        }
        vin=getVin(replicateVehicleAndVehicleOwnership);
        brand=getBrand(replicateVehicleAndVehicleOwnership);
        email=getEmail(replicateVehicleAndVehicleOwnership); 
        accType = getAccountType(replicateVehicleAndVehicleOwnership); 
        if(accType == ORGANISATION
           && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn != null 
           && !replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.isempty()
           && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.size() > 1){
               contactFirstName = replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.FstNm;
               contactLastName = replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.LstNm;
               contactCountry = getContactCountry(replicateVehicleAndVehicleOwnership);
               contactCountryCode = getISOCodeFromCountry(contactCountry);
               contactPhone=getContactPhone(replicateVehicleAndVehicleOwnership);
               contactEmail = getContactEmail(replicateVehicleAndVehicleOwnership); 
               contactpreferredLanguage = getPreferredLanguage(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.prefLang);
           }
        system.debug('contactFirstName --> '+contactFirstName);
        system.debug('contactLastName --> '+contactLastName);
        system.debug('contactCountry --> '+contactCountry);
        system.debug('contactCountryCode --> '+contactCountryCode);
        system.debug('contactpreferredLanguage --> '+contactpreferredLanguage);
        
        firstName=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.FstNm;
        lastName=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.LstNm;
        // CXPD-1497 -- Preferred Language for MENA FRS-136 Integration
        preferredLanguage = getPreferredLanguage(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.prefLang);
        
        country=getCountry(replicateVehicleAndVehicleOwnership);
        
        countryCode=getISOCodeFromCountry(country);
        phone=getPhone(replicateVehicleAndVehicleOwnership);
        accountId = getAccountId(replicateVehicleAndVehicleOwnership);
        contactId = getContactId(replicateVehicleAndVehicleOwnership);
        companyName=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.OrgNm1;
        System.debug('countryCode '+countryCode);
        System.debug('country '+country);
        System.debug('accountId '+accountId);
        System.debug('phone '+phone);
        System.debug('email '+email);
        asset=getAssetFromVin(vin);
        
        if(countryCode != null) {
            listAccounts=getAccountFromParam(accountId,countryCode,email,phone,accType,firstName,lastName,companyName);  
            System.debug('listAccounts '+listAccounts);
            
            if(accType == ORGANISATION ){
                listContacts=getContactFromParam(contactId,contactcountryCode,contactemail,contactphone,accType,contactfirstName,contactlastName,companyName);  
                System.debug('listContacts '+listContacts);
            }
            
        } else {
            system.debug('Cannot find matching Country Isocode for country');
            return 'Cannot find matching Country Isocode for country '+country;
        }
        
        
        if(asset!=null && asset.account.name.contains('Migrated') &&  (countryCode=='KW' || countryCode=='LB') || (asset==null &&  (countryCode=='KW' || countryCode=='LB' ))){
            
            listRetailers=[select id from account where country_iso_code__c=:countrycode and brand__c=:brand and Record_Sub_Type__c ='Dual Brand' and retailer_type__C='Importer'];
            if(!listRetailers.isEmpty())
                retailer=listRetailers[0];
        }
        else
            if((asset!=null && asset.account.name.contains('Migrated') &&  countryCode!='KW' && countryCode!='LB') ||  (asset==null && !String.isBlank(countryCode) && countryCode!='KW' && countryCode!='LB')){
                
                listRetailers=[select id from account where country_iso_code__c=:countrycode and Record_Sub_Type__c ='Dual Brand' and retailer_type__C='Importer'];                
                if(!listRetailers.isEmpty())
                    retailer=listRetailers[0];
            }
        else
            if(asset!=null &&  asset.Account.RecordType.DeveloperName == 'Retailer') {
                dealerCode=asset.account.id;     
            }
        
        
        
        if(retailer==null && !String.isEmpty(dealercode))            
        {     
            //listRetailers=[select id,Record_Sub_Type__c,Dealer_CI_Code_2__c,Dealer_CI_Code__c from account where  Record_Sub_Type__c ='Dual Brand' and (Dealer_CI_Code_2__c =:dealerCode or Dealer_CI_Code__c =:dealerCode ) limit 1];
            listRetailers=[select id,Record_Sub_Type__c,Dealer_CI_Code_2__c,Dealer_CI_Code__c from account where id=:asset.account.id limit 1];
            if(!listRetailers.isEmpty())
                retailer=listRetailers[0];    
        }
        
        if(retailer!=null){    
            listUsers = [select name,id,userrole.name,userroleid,accountid from user where userroleid != null  and isActive = TRUE and accountid =:retailer.id and (userrole.name like '%User%') and( name like 'dummyimp%' or name like 'dummy%')];
            
            if(!listUsers.isEmpty())
                user=listUsers[0];
        }         
        
        if(retailer!=null && user==null){    
            listUsers = [select id,userrole.name,userroleid,accountid from user where userroleid != null and usertype ='PowerPartner' and isActive = TRUE and accountid =: retailer.id and (userrole.name like '%User%')];
            
            if(!listUsers.isEmpty())
                user=listUsers[0];
        }  
        
        
        if(listAccounts!=null && listAccounts.size()==1){
            account=listAccounts[0];
        }else{
            if(listAccounts.size()>1){
                List<Account> accountsMatchedById = new List<Account>();
                for(Account acc : listAccounts){
                    string  accountNoLeadingZero;
                    if(accountId != null && accountId.startsWith('0')){
                        ///CXPD-738
                        accountNoLeadingZero =accountId.substring(1, accountId.length() );
                        
                    }
                    
                    if(accountId != null && acc.MENA_Reference2__c != null && (acc.MENA_Reference2__c.Trim() == accountId.Trim() || (accountNoLeadingZero != null && acc.MENA_Reference2__c.Trim() == accountNoLeadingZero.Trim() ))){
                        accountsMatchedById.add(acc);
                        system.debug('FOUND');
                    }
                }
                
                if(accountsMatchedById != null && accountsMatchedById.size() == 1 ){
                    account = accountsMatchedById[0];
                }else{
                    system.debug('More than 1 matching account record found in CXP');
                    return 'More than 1 matching account record found in CXP';  
                }                                         
            }
        }
        system.debug('Past');
        
        if(accType == ORGANISATION){    
            if(listContacts!=null && listContacts.size()==1){
                contact=listContacts[0];
            }else if(listContacts != null && listContacts.size()>1){
                List<contact> contactsMatchedById = new List<contact>();
                for(contact con : listContacts){
                    string  contactNoLeadingZero;
                    if(contactId != null && contactId.startsWith('0')){
                        contactNoLeadingZero =contactId.substring(1, contactId.length() );
                    }
                    if(contactId != null && con.MENA_Reference2__c != null && (con.MENA_Reference2__c.Trim() == contactId.Trim() || (contactNoLeadingZero != null && con.MENA_Reference2__c.Trim() == contactNoLeadingZero.Trim() ))){
                        contactsMatchedById.add(con);
                        system.debug('Contact FOUND');
                    }
                }
                if(contactsMatchedById != null && contactsMatchedById.size() == 1 ){
                    contact = contactsMatchedById[0];
                }else{
                    return 'More than 1 matching Contact record found in CXP';  
                } 
            }
        }
        
        
        //search for exising should search via accountid AND email/phone etc          
        //when pulling back more than one record, if one has correct id matching submitted vista value use that account and discount others without throwing error
        accountFromMessage=createAccount(email,phone,replicateVehicleAndVehicleOwnership);
        
        
        
        if((accountFromMessage!=null && account==null) || !isSameAccount(accType,firstname,lastname,account,companyName) )
        {
            
            
            if(user!=null){
                accountFromMessage.ownerid=user.id;  
                insert accountFromMessage;
            }else{
                if(asset!=null && asset.Account.RecordType.DeveloperName != 'Retailer'){
                    result='Asset related to non retailer recordtype';  
                }else{
                    result='No user exists at the retailer to assign the account ownership to';   
                }
                
            }             
            
            
            
            
        }    
        system.debug('accType ---> '+accType);      
        if(accType == ORGANISATION && contact==null){    
            String accountId;
            if(accountFromMessage != null){
                accountId = accountFromMessage.Id;
            }else if(account != null){
                accountId = account.Id;
            }
            system.debug('accountId --> '+accountId);
            system.debug('accountId --> '+accountFromMessage);
            system.debug('accountId --> '+account);
            contactFromMessage=createContact(contactEmail,contactphone,replicateVehicleAndVehicleOwnership,accountId,contactId);
        }
        
        String insertAccountId;
        system.debug('accountFromMessage --> '+accountFromMessage);
        system.debug('account --> '+account);
        if(accountFromMessage != null && accountFromMessage.Id != null){
            insertAccountId = accountFromMessage.Id;
        }else if(account != null && account.Id != null){
            insertAccountId = account.Id;
        }           
        system.debug('insertAccountId --> '+insertAccountId);
        if(contactFromMessage != null 
           && user != null 
           && user.Id != null 
           && insertAccountId != null
           && contactFromMessage.lastname != null
           && contactFromMessage.email != null){
               
               contactFromMessage.accountId = insertAccountId;
               contactFromMessage.ownerid=user.id;
               insert contactFromMessage;
           }
        
        if(accountFromMessage!=null && accountFromMessage.id!=null && asset!=null){
            
            asset.accountId=accountFromMessage.id; 
            
            /*if(acctype!=ORGANISATION) //1.0
updateConsent(accountFromMessage,replicateVehicleAndVehicleOwnership);*/
            
            update asset;
            result ='Success'; 
            
        }
        else
            if(account!=null && asset!=null){
                boolean isValid=true;
                asset.accountId=account.id;
                update asset;
                
                if(email!=null && string.isNotBlank(email))
                {
                    if(InvalidEmailAddLst.contains(email))
                    {
                        isValid=false;
                    }else
                    {
                        for(string InvEmail: InvalidEmailAddLst)
                        {
                            if(email.contains(InvEmail))
                            {
                                isValid=false;
                                break;
                            }
                        }
                    }
                    if(isValid)
                    {
                        if(account.isPersonAccount)
                        {
                            If(account.PersonEmail !=email) 
                            {
                                system.debug('Account @@@'+Account.Email2__pc);
                                system.debug('Account @@@'+Account.Email3__pc);
                                system.debug('Account @@@'+Account.Historical_Contact_Details__c);
                                if(Account.Email2__pc==null || string.isBlank(Account.Email2__pc) || Account.Email2__pc=='')
                                {
                                    Account.Email2__pc=Account.PersonEmail;
                                    system.debug('Account @@@'+Account.Email2__pc);
                                }
                                else if(Account.Email3__pc==null || string.isBlank(Account.Email3__pc) || Account.Email3__pc=='')
                                {
                                    Account.Email3__pc=Account.PersonEmail;
                                    system.debug('Account @@@'+Account.Email3__pc);
                                }
                                else{
                                    Account.Historical_Contact_Details__c=Account.Historical_Contact_Details__c !=null ? Account.Historical_Contact_Details__c+'\n Email:'+Account.PersonEmail : 'Email:'+Account.PersonEmail;
                                    Account.Historical_Contact_Details__c+='\n Removed On:'+system.today().format();
                                    system.debug('Account @@@'+Account.Historical_Contact_Details__c);
                                    
                                }
                                Account.PersonEmail=email;
                                
                                system.debug('Account @@@'+Account);
                            } 
                        }else{
                            If(account != null && account.Retailer_Email__c !=email) 
                            {
                                Account.Historical_Contact_Details__c=Account.Historical_Contact_Details__c !=null ? Account.Historical_Contact_Details__c+'\n Email:'+Account.Retailer_Email__c : 'Email:'+Account.Retailer_Email__c;
                                Account.Retailer_Email__c=email;
                            } 
                        }
                        if(accType == ORGANISATION && contact !=null && asset!=null){
                            If(contact.Email !=email) 
                            {
                                if(contact.Email2__c==null || string.isBlank(contact.Email2__c) || contact.Email2__c=='')
                                {
                                    contact.Email2__c=contact.Email;
                                    system.debug('contact @@@'+contact.Email2__c);
                                }
                                else if(contact.Email3__c==null || string.isBlank(contact.Email3__c) || contact.Email3__c=='')
                                {
                                    contact.Email3__c=contact.Email;
                                    system.debug('contact @@@'+contact.Email3__c);
                                }
                                contact.Email=email;
                            } 
                        }
                    }
                }
                
                // CXPD-1497 -- Update preferred langauge of Account if blank or mismatch --- Only applicable for Individual Account
                if(account.isPersonAccount && String.isNotBlank(preferredLanguage)) {
                    if(String.isBlank(account.Language__pc) || account.Language__pc != preferredLanguage) {
                        account.Language__pc = preferredLanguage;
                    }
                }
                if(accType == ORGANISATION && contact !=null){
                    update contact;
                }
                if(acctype != ORGANISATION && account.IsPersonAccount)
                    update account;
                if(acctype ==ORGANISATION){
                    update account;
                }	
                
                /*                
updateConsent(account,replicateVehicleAndVehicleOwnership);*/
                
                result='Success';   
            }    
        else
            if(asset==null){
                result='Vehicle Not Found'; 
                
            } 
        
        system.debug('contact ---> '+contact);
        system.debug('accountFromMessage ---> '+accountFromMessage);
        system.debug('accountId ---> '+account);
        
        if(contact != null){
            String updateaccountId;
            if(accountFromMessage != null){
                updateaccountId = accountFromMessage.Id;
            }else if(account != null){
                updateaccountId = account.Id;
            }
            if(updateaccountId != null){
                contact.accountId = updateaccountId;
            }
            update contact;
        }
        
        return result;
        
    }
    
    /*//1.0
private void updateConsent(account account,ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){

integer jaguarConsent=0;
integer landRoverConsent=0;

if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Prmssns!=null)
{   

for(ReplicateAccAndVehRel.Prmssn permission:replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Prmssns.Prmssn)
{

if(permission.Cnsnt!=YES && permission.Cnsnt.contains(JAGUAR)){
jaguarCount++;

}
else
if(permission.Cnsnt==YES && permission.Cnsnt.contains(JAGUAR))
{
jaguarCount++;
jaguarConsent++; 

}

if(permission.Cnsnt!=YES && permission.Cnsnt.contains(LANDROVER)){      
landRoverCount++;
}
else
if(permission.Cnsnt==YES && permission.Cnsnt.contains(LANDROVER))
{
landRoverCount++;
landRoverConsent++; 

}

}

if(jaguarCount!=0 && jaguarCount==jaguarConsent)
jaguarAllConsent=true;
else
jaguarallconsent=false;    

if(landrovercount!= 0 && landRoverCount==landroverConsent)
landroverallconsent=true;    
else
landroverallconsent=false;

updateconsentFields(account,landroverallconsent,jaguarallconsent);

} 

}
//1.0
private void updateconsentFields(account accup,boolean landRover,boolean jaguar)
{

Account acc = new Account();
acc.id = accup.Id;
if(jaguar==false && acc.RecordTypeId != SObjectUtilities.RecordTypes.get('Account').get('Corporate').Id)
{
acc.Jaguar_Email_Opt_Out__pc=true;  
acc.Jaguar_Phone_Opt_Out__pc=true;    
acc.Jaguar_SMS_Opt_Out__pc=true;
acc.Jaguar_Whitemail_Opt_Out__pc=true;    
}         

if(landrover==false && acc.RecordTypeId != SObjectUtilities.RecordTypes.get('Account').get('Corporate').Id)
{
acc.Land_Rover_Email_Opt_Out__pc=true;    
acc.Land_Rover_Phone_Opt_Out__pc=true;    
acc.Land_Rover_SMS_Opt_Out__pc=true;
acc.Land_Rover_Whitemail_Opt_Out__pc=true;
}        

update acc;
}*/
    @testvisible 
    private boolean isSameAccount(String type,String firstName,String lastName,account account,String companyName){
        
        string  accountNoLeadingZero;
        if(accountId != null && accountId.startsWith('0')){
            ///CXPD-738
            accountNoLeadingZero =accountId.substring(1, accountId.length() );
            
        }
        
        
        
        if((account!=null && account.mena_reference2__c != null && (account.mena_reference2__c.trim()==accountId.trim()||(accountNoLeadingZero != null && account.mena_reference2__c.trim()==accountNoLeadingZero.trim())))
           ||  (account!=null && account.mena_reference2__pc != null && (account.mena_reference2__pc.trim()==accountId.trim()||(accountNoLeadingZero != null && account.mena_reference2__pc.trim()==accountNoLeadingZero.trim()))) )
        {
            return true;
        }
        else
            if(account!=null && account.Country_ISO_code__c!=null && getIsoCodeFromName(country)==account.Country_ISO_Code__c)
        {  
            
            if(type!=ORGANISATION)
            {
                if(account.firstname != null && firstname != null && account.firstname.trim().contains(firstName.trim())  && account.lastName != null  && lastName != null && account.lastName.trim().contains(lastName.trim()))
                    return true;       
            }
            else
                if(account.name.trim()==companyName.trim()){
                    
                    return true;
                }     
            
        }
        
        
        return false;
    }
    
    public String getIsoCodeFromName(String countryName){
        String isoCode;
        for (aop_NationalityToISOCode__c  item : aop_NationalityToISOCode__c.getAll().values()) {
            if(item!=null && item.name==countryName)
                isoCode=item.aop_ISO_Code__c;
        }
        
        return isoCode;
    }
    
    private Contact createContact(String email,String phone,ReplicateAccAndVehRel.AccountVehicle listAccAndVehRel,id accountId,String menaRefId){
        if(listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn != null 
           && !listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn.isEmpty()
           && listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn.size() > 1){
               Contact ContactCreated = new Contact();
               firstName = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.FstNm;
               lastName = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.LstNm;
               String title = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Ttl;
               String city = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.AcctAddrs.AcctAddr[0].Addr.CityTown;
               String country = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.AcctAddrs.AcctAddr[0].Addr.Cntry;
               String postCode = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.AcctAddrs.AcctAddr[0].Addr.PostCdZIP;
               String street = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.AcctAddrs.AcctAddr[0].Addr.Street;
               companyName = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.OrgNm1;
               
               String prefLang = getPreferredLanguage(listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.prefLang);
               ContactCreated.firstName = firstName;
               ContactCreated.lastName = lastName;
               ContactCreated.Email  = email;
               ContactCreated.accountId  = accountId;
               ContactCreated.salutation = title;
               ContactCreated.recordTypeId = contactRetailerRecordTypeId;
               ContactCreated.Language__c  = prefLang;        
               ContactCreated.MailingCity = city;   
               ContactCreated.MailingCountry = country;
               ContactCreated.MailingPostalCode = postCode;
               ContactCreated.MailingStreet = street;
               ContactCreated.country_iso_code__c = getIsoCodeFromName(country);
               ContactCreated.MENA_Reference2__c = menaRefId;
               ContactCreated.phone = phone;
               return ContactCreated;
           }
        return null;
    }
    
    private Account createAccount(String email,String phone,ReplicateAccAndVehRel.AccountVehicle listAccAndVehRel){
        Account accountCreated = new Account();
        firstName = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.FstNm;
        lastName = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.LstNm;
        String title = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Ttl;
        String city = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctAddrs.AcctAddr[0].Addr.CityTown;
        String country = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctAddrs.AcctAddr[0].Addr.Cntry;
        String postCode = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctAddrs.AcctAddr[0].Addr.PostCdZIP;
        String street = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctAddrs.AcctAddr[0].Addr.Street;
        companyName = listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.OrgNm1;
        
        if(accType != ORGANISATION) {    
            // Set Preferred language CXPD-1497 -- Only applicable for Individual Account 
            String prefLang = getPreferredLanguage(listAccAndVehRel.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.prefLang);
            
            accountCreated.firstName = firstName;
            accountCreated.lastName = lastName;
            accountCreated.personEmail = email;
            accountCreated.salutation = title;
            accountCreated.recordTypeId = individualRecordTypeId;
            accountCreated.Language__pc	= prefLang;
        }
        else {
            accountCreated.recordTypeId = corporateRecordTypeId;
            accountCreated.Name = companyName;
            accountCreated.Retailer_Email__c = email;
            
        }    
        
        accountCreated.BillingCity = city;   
        accountCreated.BillingCountry = country;
        accountCreated.BillingPostalCode = postCode;
        accountCreated.BillingStreet = street;
        accountCreated.country_iso_code__c = getIsoCodeFromName(country);
        accountCreated.MENA_Reference2__c = accountId;
        accountCreated.phone = phone;
        
        return accountCreated;
        
    }
    
    private Asset getAssetFromVin(String vin){
        
        List<asset> listasset= [SELECT VIN__c, New_or_Used__c, Registration_Number__c,account.Dealer_CI_Code__c ,account.name,account.Dealer_CI_Code_2__c, Account.Id,apo__c, Account.RecordTypeId,Account.RecordType.DeveloperName,Account.Pseudo_Account_Owner__r.accountid,Account.owner.accountid,Mileage__c,name FROM Asset 
                                WHERE VIN__c =: vin AND New_or_Used__c!='Used'];
        
        if(listAsset.size()==1)
            return listAsset[0];   
        else
            return null;  
        
    }
    
    private String getAccountId(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        
        String accountId;
        
        if(replicateVehicleAndVehicleOwnership != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0] != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctId!=null){
                accountId=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctId;
            }
        
        
        
        return accountId;
        
    }
    
    private String getContactId(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        String contactId;
        if(replicateVehicleAndVehicleOwnership!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0] != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctRels != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctRels.AcctRel != null
               && !replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctRels.AcctRel.isEmpty()){
                   contactId = replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctRels.AcctRel[0].ChildAcctId;
               }
        return contactId;
    }
    
    private String getAccountType(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        
        if(replicateVehicleAndVehicleOwnership!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctType!=null)
            acctype=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctType;
        return acctype;
    }
    
    private List<Contact> getContactFromParam(String contactId,String countryCode,String email,String phone, String acctype,String firstName,String lastName, String companyName){
        List<Contact> contactList = new List<Contact>();
        string contactSearch;
        if(contactId != null && contactId.startsWith('0')){
            contactSearch ='%'+contactId.substring(1, contactId.length() );
        }else{
            contactSearch =  contactId;
        }
        
        String qString = 'SELECT Name, FirstName, LastName, CreatedDate, RecordTypeId,'+
            'MENA_Reference2__c,Country_ISO_Code__c,'+
            'Email,Email2__c,Email3__c,'+
            'HomePhone,MobilePhone,OtherPhone,Phone FROM Contact WHERE (Country_ISO_Code__c =:countryCode AND';
        
        
        if(accountId != null && accountId != '') { 
            qString += ' MENA_Reference2__c Like :contactSearch)';
            
            if(email != null && email != '') {
                qString += ' OR (';
                qString += 'FirstName =: firstName AND LastName =:lastName';
                qString += ' AND (Email =: email OR Email2__c =: email OR Email3__c =: email))';
            }
            
            if(phone != null && phone != '') {
                qString += ' OR (FirstName =: firstName AND LastName =:lastName AND (HomePhone =: phone OR MobilePhone =: phone OR OtherPhone =: phone OR Phone =: phone))';
            }
            
        } else {
            if(email != null && email != '') {
                qString += ' (';
                qString += ' FirstName =: firstName AND LastName =:lastName';
                qString += ' AND (Email =: email OR Email2__c =: email OR Email3__c =: email))';
                
                if(phone != null && phone != '') {
                    qString += ' OR (FirstName=: firstName AND LastName=:lastName AND (HomePhone =: phone OR MobilePhone =: phone OR OtherPhone =: phone OR Phone =: phone)';
                } 
            } else if(phone != null && phone != ''){
                qString += ' (FirstName =: firstName AND LastName =:lastName AND (HomePhone =: phone OR MobilePhone =: phone OR OtherPhone =: phone OR Phone =: phone)';
            }
            
            if(email != null && email != '') {
                qString += ' )';
            }
            
            
        }
        
        if( (accountId!=null && accountId != '') || (email != null && email != '') || (phone != null && phone != '')) {
            system.debug('-->  '+qString);
            contactList = database.query(qString);
        }
        
        List<Contact> returnableList;
        Contact latestMatched;
        if(contactList !=  null && contactList.size() > 1){
            returnableList = new List<Contact>();
            string accountIdNoLeadingZero;
            if(accountId != null && accountId.startsWith('0')){
                accountIdNoLeadingZero =accountId.substring(1, accountId.length() );
                
            }
            for(Contact con : contactList){
                if(con.FirstName != null 
                   && con.LastName != null 
                   && (con.email != null || con.phone != null || con.MENA_Reference2__c != null)){
                       if(latestMatched == null ){
                           latestMatched = con;
                       }else{
                           if(con.createddate > latestMatched.CreatedDate){
                               latestMatched = con;
                           }
                       }
                   }
            }
        }
        if(latestMatched != null){
            returnableList.add(latestMatched);
        }
        system.debug('returnableList --> '+returnableList);
        if(returnableList !=  null && returnableList.size() == 1){
            return returnableList;
        }else{
            return contactList;
        }
    }
    
    private List<Account> getAccountFromParam(String accountId,String countryCode,
                                              String email,String phone, String acctype,
                                              String firstName,String lastName, String companyName)
    {
        system.debug('getAccountFromParam');
        system.debug('accountId'+accountId);
        system.debug('countryCode'+countryCode);
        system.debug('email'+email);
        system.debug('phone'+phone);
        system.debug('firstName'+firstName);
        system.debug('lastName'+lastName);
        system.debug('companyName'+companyName);
        system.debug('acctype'+acctype);
        
        List<Account> acc = new List<Account>();
        string accountSearch;
        if(accountId != null && accountId.startsWith('0')){
            ///CXPD-738
            accountSearch ='%'+accountId.substring(1, accountId.length() );
            
        }else{
            accountSearch =  accountId;
        }
        
        //CXPD-826 Starts Here -- Suhan Jain
        String qString;
        if(acctype != ORGANISATION){
            qString = 'SELECT Id,Name, FirstName, LastName, CreatedDate, RecordTypeId, isPersonAccount, Historical_Contact_Details__c, Language__pc,'+
                'MENA_Reference2__c, MENA_Reference2__pc, corporate__c, Country_ISO_Code__c, PersonEmail,  Email2__pc, '+
                'Email3__pc, Retailer_Email__c , PersonHomePhone, PersonMobilePhone, PersonOtherPhone, '+
                'Phone, PersonAssistantPhone, Land_Rover_Email_Opt_Out__pc FROM Account WHERE Country_ISO_Code__c =:countryCode AND';
        }else if(acctype == ORGANISATION){
            qString = 'SELECT Id,Name,CreatedDate,IsPersonAccount,RecordTypeId,Retailer_Email__c,Historical_Contact_Details__c,'+
                'MENA_Reference2__c, corporate__c, Country_ISO_Code__c,'+
                'Phone FROM Account WHERE Country_ISO_Code__c =:countryCode AND';
        }
        
        qString += acctype != ORGANISATION ?' RecordTypeId=:individualRecordTypeId AND (':' RecordTypeId=:CorporateRecordTypeId AND (';
        
        if(accountId != null && accountId != '') { 
            qString += ' (MENA_Reference2__c Like :accountSearch or MENA_Reference2__pc Like :accountSearch) ';
            
            if(email != null && email != '') {
                qString += ' OR ( ';
                qString += acctype != ORGANISATION ? 'FirstName=: firstName AND LastName=:lastName ':'Name=:companyName';
                qString += ' AND (Retailer_Email__c =: email OR PersonEmail =: email OR Email2__pc =: email OR Email3__pc =: email))';
            }
            
            if(phone != null && phone != '' && acctype != ORGANISATION) {
                qString += ' OR ( FirstName=: firstName AND LastName=:lastName AND (PersonAssistantPhone =: phone OR PersonHomePhone =: phone OR PersonMobilePhone =: phone OR PersonOtherPhone =: phone OR Phone =: phone))';
            }
            
        } else {
            if(email != null && email != '') {
                qString += ' ( ';
                qString += acctype != ORGANISATION ? 'FirstName=: firstName AND LastName=:lastName ':'Name=:companyName';
                qString += ' AND (Retailer_Email__c =: email OR PersonEmail =: email OR Email2__pc =: email OR Email3__pc =: email))';
                
                if(phone != null && phone != '' && acctype != ORGANISATION) {
                    qString += ' OR ( FirstName=: firstName AND LastName=:lastName AND (PersonAssistantPhone =: phone OR PersonHomePhone =: phone OR PersonMobilePhone =: phone OR PersonOtherPhone =: phone OR Phone =: phone))';
                } 
            } else if(phone != null && phone != '' && acctype !=ORGANISATION){
                qString += ' ( FirstName=: firstName AND LastName=:lastName AND (PersonAssistantPhone =: phone OR PersonHomePhone =: phone OR PersonMobilePhone =: phone OR PersonOtherPhone =: phone OR Phone =: phone))';
            }
            
        }
        
        if( (accountId!=null && accountId != '') || (email != null && email != '') || (phone != null && phone != '')) {
            system.debug('qString --> '+qString);
            acc = database.query(qString+')');
        }
        //CXPD-826 Ends Here -- Suhan Jain
        
        List<Account> returnableList;
        Account latestMatched;
        if(acc !=  null && acc.size() > 1){
            //CXPD-737
            returnableList = new List<Account>();
            string accountIdNoLeadingZero;
            if(accountId != null && accountId.startsWith('0')){
                ///CXPD-738
                accountIdNoLeadingZero =accountId.substring(1, accountId.length() );
                
            }
            for(Account ac : acc){
                if((ac.MENA_Reference2__c != null && ac.MENA_Reference2__c != '' && (( accountId != null && accountId != '' && ac.MENA_Reference2__c == accountId) ||( accountIdNoLeadingZero != null && accountIdNoLeadingZero != '' && ac.MENA_Reference2__c == accountIdNoLeadingZero) ) )
                   || (ac.MENA_Reference2__pc != null && ac.MENA_Reference2__pc != '' && (( accountId != null && accountId != '' && ac.MENA_Reference2__pc == accountId) ||( accountIdNoLeadingZero != null && accountIdNoLeadingZero != '' && ac.MENA_Reference2__pc == accountIdNoLeadingZero) ) )
                  ){
                      if(latestMatched == null ){
                          latestMatched = ac;
                      }else{
                          if(ac.createddate > latestMatched.CreatedDate){
                              latestMatched = ac;
                          }
                      }
                  }
            }
        }
        if(latestMatched != null){
            returnableList.add(latestMatched);
        }
        
        if(returnableList !=  null && returnableList.size() == 1){
            return returnableList;
        }else{
            return acc;
        }
        
        
        
        
    }
    
    public static void SendErrorEmail(String message, Exception ex){
        List<String> recipients = new List<String>();
        String html='';
        String exmessage;
        System_Settings__mdt errorRecipients = [Select Value__c from System_Settings__mdt
                                                Where DeveloperName = 'MENA_Integration_Failure_Alert'];
        
        if(errorRecipients!=null && String.isNotBlank(errorRecipients.Value__c)){
            recipients.addAll((errorRecipients.Value__c).split(','));
        }
        if (recipients.size() == 0) return;
        
        if(ex!=null)
            exmessage=ex.getMessage();
        
        html = '<pre>'+exmessage+'</pre><hr/><pre>'+'</pre><br/><br/>';
        html += '<h3>Original Message</h3><pre>'+json.serialize(message)+'</pre>';
        
        List<Logger.Log> logs = Logger.getLogs();
        
        if(logs.isEmpty())
            logs=new List<Logger.Log>();
        
        if(logs.size() > 0){
            String logHtml = '<h3>Logs</h3><table>';
            
            for(Logger.Log l : logs){
                logHtml += '<tr><td>'+l.timestamp+'</td><td>' + l.level + '</td><td>' + l.message + '</td></tr>';
            }
            
            logHtml += '</table>';
            html += '<br/><br/>' + logHtml;
        }
        
        
        EmailUtility.SendEmail(recipients, 'MENA Integration Exception', 'ReplicateAccAndVehRelProcessor.cls Exception - ' + system.now() + ' - ' + UserInfo.getUserName(),html);
        
    }
    
    PUBLIC String getCountry(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        
        String country;
        
        if(replicateVehicleAndVehicleOwnership!=null){
            SYSTEM.DEBUG('replicateVehicleAndVehicleOwnership'+replicateVehicleAndVehicleOwnership);
            SYSTEM.DEBUG('replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0]'+replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctAddrs.AcctAddr[0].Addr.Cntry);
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctAddrs.AcctAddr[0].Addr.Cntry!=null)
                country=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctAddrs.AcctAddr[0].Addr.Cntry;   
        }
        
        
        return country;
        
    }
    
    PUBLIC String getContactCountry(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        
        String country;
        
        if(replicateVehicleAndVehicleOwnership!=null){
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn != null 
               && !replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.isempty()
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.size() > 1
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.AcctAddrs.AcctAddr[0].Addr.Cntry!=null)
                country=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.AcctAddrs.AcctAddr[0].Addr.Cntry;   
        }
        
        
        return country;
        
    }
    
    private String getEmail(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        
        String email;
        
        if(replicateVehicleAndVehicleOwnership != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn != null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails!=NULL)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email !=NULL){
                for(integer i=0; i<replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email.size(); i++)
                {
                    if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email[i].EmailAddr!=null && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email[i].PrFlg=='true')
                    {
                        email= replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email[i].EmailAddr;
                        break;
                    }
                }
                if(email==null || string.isBlank(email))
                    email=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email[0].EmailAddr;    
            }
        
        return email;
        
        
    }
    
    private String getContactEmail(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership){
        
        String email;
        
        if(replicateVehicleAndVehicleOwnership!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn != null 
               && !replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.isempty()
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.size() > 1)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Emails!=NULL)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Emails!=NULL)
            for(integer i=0; i<replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Emails.Email.size(); i++)
        {
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Emails.Email[i].EmailAddr!=null && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Emails.Email[i].PrFlg=='true')
            {
                email= replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Emails.Email[i].EmailAddr;
                break;
            }
        }
        if(email==null || string.isBlank(email)){
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn != null 
               && !replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.isempty()
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.size() > 1
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1] != null
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct != null
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.emails != null
               && !replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.emails.Email.isempty()
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.emails.Email[0] != null
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.emails.Email[0].EmailAddr != null){
                   email=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Emails.Email[0].EmailAddr;    
               }
        }
        
        return email;
        
        
    }
    
    private String getPhone(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership) {
        String phone;
        if(replicateVehicleAndVehicleOwnership!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0]!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Tels!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Tels.Tel!=null)
            if(!replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Tels.Tel.isEmpty())
            phone=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Tels.Tel[0].PhNum;    
        
        return phone;
    }
    
    private String getContactPhone(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership) {
        String phone;
        if(replicateVehicleAndVehicleOwnership!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn != null 
               && !replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.isempty()
               && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn.size() > 1){
                   if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Tels!=null)
                       phone=replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[1].Acct.Tels.Tel[0].PhNum;
               }
        
        return phone;
    }
    
    private String getVin(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership) {
        String vin;
        if(replicateVehicleAndVehicleOwnership!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl!=null)
            vin=String.valueOf(replicateVehicleAndVehicleOwnership.Vhcl.vin);
        
        return vin;
    }
    
    private String getBrand(ReplicateAccAndVehRel.AccountVehicle replicateVehicleAndVehicleOwnership) {
        String brand;
        if(replicateVehicleAndVehicleOwnership!=null)
            if(replicateVehicleAndVehicleOwnership.Vhcl!=null)
            brand=String.valueOf(replicateVehicleAndVehicleOwnership.Vhcl.Brand);
        
        return brand;
    }
    
    private String getISOCodeFromCountry(String country) {
        String isoCode;
        for (aop_NationalityToISOCode__c  item : aop_NationalityToISOCode__c.getAll().values()) {
            if(item.name  ==country)
                isoCode=item.aop_ISO_Code__c;
        }
        return isoCode;
    }
    
    // CXPD-1497 -- Preferred Language for MENA FRS-136 Integration
    public String getPreferredLanguage(String language) {
        if(String.isNotBlank(language)) {
            aop_TridentLanguageMapping__c languageMap = aop_TridentLanguageMapping__c.getValues(language);
            if(languageMap != null && languageMap.aop_Request_Language__c  != null) {
                language = languageMap.aop_Request_Language__c;                    
            }
        }
        return language;
    }
    
}