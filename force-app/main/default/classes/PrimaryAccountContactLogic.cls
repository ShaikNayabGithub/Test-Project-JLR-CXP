/*
* Corporate & primary account logic
* 1- existing link to primary acc exists and primary con exists
* 		find, link and in post update prim
* 		
* 2- existing link to primary acc exists and no matching primary con exists
* 		search, create, link
* 
* 3- existing primary acc exists with contact but no link
* 		search link con and acc, 
* 
* NB existing primary acc with no matching contact cannot occur as wouldn't detect the primary acc as matching
* 
* 
* 
*/

public class PrimaryAccountContactLogic {
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static Id goldenIndividualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static Id goldenCorporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();    
    public static Id retailerContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Retailer_Contact').getRecordTypeId();
    public static Id jlrContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    Public static Map<string, User> ownerMap;
    
    
    public void preCreateSecondaryContact(boolean matchDotNames, List<Contact> newContacts, Set<Id> accountIds){
        System.debug('preCreateSecondaryContact');
        //get related primary account ids
        if(ownerMap == null){
            System.debug('');
            ownerMap = new Map<string, user>();
            List<User> users = [SELECT Id, Name, UserRole.DeveloperName, Country_ISO_Code__c, Market__c FROM User WHERE (UserRole.DeveloperName LIKE '%DUMMY%') AND IsActive = true AND Country_ISO_Code__c != null AND UserType = 'Standard'];
            for(User dummy : users){
                if(!ownerMap.containsKey(dummy.Country_ISO_Code__c)){
                    ownerMap.put(dummy.Country_ISO_Code__c, dummy);
                }
            }
            
        }
        PrimaryAccountContactGateway gateway = new PrimaryAccountContactGateway();
        List<Account> accs = gateway.getSecondaryAccountDetails(accountIds);
        Map<Id,Account> accountsWithNoPrimaryMap = new  Map<Id,Account>();
        List<Contact> contactsWithNoPrimaryAccount = new List<Contact>();
        List<Contact> contactsWithExistingPrimaryAccount = new List<Contact>();
        Map<id,id> secondaryAccountIdPrimaryAccountIdMap = new Map<Id,Id>();
        Map<Id, List<Contact>> primaryAccountIdSecondaryContactsMap = new Map<Id,List<Contact>>();
        for(Contact c : newContacts){
            for(Account ac :accs ){
                if(c.AccountId == ac.id && ac.Primary_Account__c == null && ac.RecordtypeId == corporateRecordType){
                    contactsWithNoPrimaryAccount.add(c);
                    if(accountsWithNoPrimaryMap == null || !accountsWithNoPrimaryMap.containsKey(ac.id) ){
                        accountsWithNoPrimaryMap.put(ac.id,ac); 
                    }
                    
                }
                
                if(c.AccountId == ac.id && ac.Primary_Account__c != null){
                    
                    contactsWithExistingPrimaryAccount.add(c);
                    secondaryAccountIdPrimaryAccountIdMap.put(c.AccountId,ac.Primary_Account__c);
                    if(primaryAccountIdSecondaryContactsMap.containsKey(ac.Primary_Account__c)){
                        List<Contact> contacts = primaryAccountIdSecondaryContactsMap.get(ac.Primary_Account__c);
                        contacts.add(c);
                        primaryAccountIdSecondaryContactsMap.put(ac.Primary_Account__c, contacts);
                    } else {
                        primaryAccountIdSecondaryContactsMap.put(ac.Primary_Account__c, new List<Contact>{ c });
                    }
                    
                }
            }
            
        }
        
        if(!contactsWithExistingPrimaryAccount.isEmpty()){
            preCreateSecondaryContactExistingPrimaryAccount(matchDotNames, contactsWithExistingPrimaryAccount,  primaryAccountIdSecondaryContactsMap, secondaryAccountIdPrimaryAccountIdMap, false);
            
        }
        
        if(!contactsWithNoPrimaryAccount.isEmpty()){
            preCreateSecondaryContactNoPrimaryAccount(matchDotNames, contactsWithNoPrimaryAccount, accountsWithNoPrimaryMap, false  );
            
        }
        
        
        
    }
    
    public void preCreateSecondaryContactNoPrimaryAccount(boolean matchDotNames, List<Contact> newContacts,  Map<Id,Account> accounts, boolean updatenewContacts ){
        //
        system.debug('preCreateSecondaryContactNoPrimaryAccount ');
              system.debug('newContacts '+newContacts);
        PrimaryAccountContactGateway gateway = new PrimaryAccountContactGateway();
       Map<Id,Account> newPrimaryAcc = new  Map<Id,Account>();
        List<Contact>    newPrimContacts = new List<Contact>();
        Map<Id,Id> secondaryAccToPrimaryAccMap = new Map<Id,Id>();
        List<Account> potentialAccs = gateway.getPotentialPrimaryAccountDetails(accounts.values());
        Map<String, List<Account>> potentialAccsMap = new Map<String,List<Account>>();
        for(Account acc : potentialAccs){
            if(potentialAccsMap.containsKey(acc.Name)){
                List<Account> accs = potentialAccsMap.get(acc.Name);
                accs.add(acc);
                potentialAccsMap.put(acc.Name, accs);
            } else {
                potentialAccsMap.put(acc.Name, new List<Account>{ acc });
            }
        }
        
        List<Contact> toCreateNewPrimary = new List<Contact>();
        List<Contact> toLinkExistingPrimary = new List<Contact>();
        for(Contact c : newContacts){
            Account origAcc = accounts.get(c.accountId);
            if(potentialAccsMap.containsKey(origAcc.name)){
                List<Account> primAccs = potentialAccsMap.get(origAcc.name);
                Boolean foundExistingContact = false;
                for(Account primAcc : primAccs){
                    
                    if(primAcc.contacts != null){
                        for(Contact primcon : primAcc.contacts){
                            if(!foundExistingContact && doContactsMatch(c,primCon, matchDotNames)){
                                foundExistingContact = true;
                                c.Primary_Contact__c = primCon.Id;
                                c.Primary_Account__c = primCon.AccountId;
                                toLinkExistingPrimary.add(c);
                                
                            }else{
                                break;
                            }
                        }
                        
                    }
                    if(foundExistingContact){
                        break;
                    }
                }
            }
            
            if(toLinkExistingPrimary.size()>0){
                list<Account> tobeupdated = new List<Account>();
                for(Contact con : toLinkExistingPrimary){
                    Account ac = new Account();
                    ac.id = con.AccountId;
                    ac.Primary_Account__c = c.Primary_Account__c;
                    tobeupdated.add(ac);  
                }
                update tobeupdated;
            }
            
            if(c.Primary_Contact__c == null){
                toCreateNewPrimary.add(c);
                if(!newPrimaryAcc.containsKey(c.accountId)){
                     Account acc = accounts.get(c.accountId);
                    system.debug('owner retailer '+acc.Owner_Retailer__c);
                Account primaryAccount = acc.clone(false, false, false, false);
                primaryAccount.Is_Primary__c = true;
                primaryAccount.Owner_Retailer__c = null;
                primaryAccount.Bronze_Record_Id__c = acc.id;
                primaryAccount.RecordTypeId =goldenCorporateRecordType;
                primaryAccount.VITAL_Ref__c = null;
                if( acc.Country_ISO_Code__c != null &&ownerMap!= null && ownerMap.containsKey(acc.Country_ISO_Code__c)){
                    primaryAccount.OwnerId = ownerMap.get(acc.Country_ISO_Code__c).id;
                }
                newPrimaryAcc.put(acc.id, primaryAccount);
                    
                }
               
                
            }
            
        }
        
        if(newPrimaryAcc.size()>0){
            list<Account> secAccUpdate = new List<Account>();
            ////
            Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true; 
                
                List<Database.SaveResult> sr = Database.insert(newPrimaryAcc.Values(), dml); 
                for (Database.SaveResult sr1 : sr) {
                    if (!sr1.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr1.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr1.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            
            
            
            
            
            
            
            
            
            //////
          //  insert newPrimaryAcc.Values();
            Set<Id> unique = new Set<Id>();
            for(Account acc: newPrimaryAcc.Values()){
                if(!unique.contains(acc.Bronze_Record_Id__c)){
                    secondaryAccToPrimaryAccMap.put(acc.Bronze_Record_Id__c,acc.Id);
                    Account sec = new Account();
                    sec.Id = acc.Bronze_Record_Id__c;
                    sec.Primary_Account__c = acc.Id;
                    secAccUpdate.add(sec);
                    unique.add(sec.id);
                }
                
            }
            update secAccUpdate;
        }
        
        
        if(toCreateNewPrimary.size() > 0){
            for(Contact c : toCreateNewPrimary){
                c.Primary_Account__c = secondaryAccToPrimaryAccMap.get(c.AccountId);
                newPrimContacts.add(createNewPrimaryContact(c,  c.Primary_Account__c ));
            }
            insert newPrimContacts;
            system.debug('newPrimContacts '+newPrimContacts);
            for(contact secCon: newContacts){
                if(secCon.Primary_Contact__c == null){
                    Boolean foundExistingContact = false;
                    for(Contact primCon : newPrimContacts){
                        
                        if(!foundExistingContact && doContactsMatch(secCon,primCon, matchDotNames)){
                            foundExistingContact = true;
                            secCon.Primary_Contact__c = primCon.Id;
                            
                        }else{
                            continue;
                        }
                        
                        
                    }
                }
                
            }
        }
        if(updatenewContacts  )
        {
            update newContacts;
                               }
        
        
    }
    public void preCreateSecondaryContactExistingPrimaryAccount(Boolean matchDotNames, List<Contact> secondaryContacts, Map<Id,List<contact>> primaryAccountIdSecondaryContactsMap, Map<id,id> secondaryAccountIdPrimaryAccountIdMap, boolean updateContacts){
        //Check if matches on existing primary contacts
        //if match link secondary and check for contact details to be updated
        //if no match create primary and then link
        System.debug('preCreateSecondaryContactExistingPrimaryAccount');
        Map<Id, List<Contact>> primaryAccountIdPrimaryContactsMap = new Map<Id,List<Contact>>();
        List<Contact> newPrimContacts = new List<Contact>();
        PrimaryAccountContactGateway gateway = new PrimaryAccountContactGateway();
        List<Contact> primaryContacts = gateway.getPrimaryContactDetails(primaryAccountIdSecondaryContactsMap.keyset());
        for(Contact primContact : primaryContacts){
            if(primaryAccountIdPrimaryContactsMap.containsKey(primContact.AccountId)){
                List<Contact> contacts = primaryAccountIdPrimaryContactsMap.get(primContact.AccountId);
                contacts.add(primContact);
                primaryAccountIdPrimaryContactsMap.put(primContact.AccountId, contacts);
            } else {
                primaryAccountIdPrimaryContactsMap.put(primContact.AccountId, new List<Contact>{ primContact });
            }
        }
        //System.debug('primaryAccountIdPrimaryContactsMap '+Json.serializePretty(primaryAccountIdPrimaryContactsMap));
        for(contact secCon: secondaryContacts){
            Id primaryAccID = secondaryAccountIdPrimaryAccountIdMap.get(secCon.AccountId);
            secCon.Primary_Account__c = primaryAccID; 
            Boolean foundExistingContact = false;
            
            List<Contact> primContacts = primaryAccountIdPrimaryContactsMap.get(primaryAccID);
            if(primContacts != null && !primContacts.isEmpty() ){
                
                for(Contact primContact : primContacts){
                    system.debug('primContact '+primContact);
                    system.debug('secCon '+secCon);
                    if(!foundExistingContact){
                        foundExistingContact = doContactsMatch(secCon,primContact, matchDotNames); 
                        if(foundExistingContact){
                         //   System.debug('foundExistingContact no creation');
                            secCon.Primary_Contact__c = primContact.Id; 
                        }
                        
                        //do primary contact information updates in post logic, 
                    }else{
                        break;
                    }
                    
                    
                }
            }
            if(  secCon.Primary_Contact__c == null){
                newPrimContacts.add(createNewPrimaryContact(secCon, primaryAccID));
                
            }
            
            
            
        }
        
        if(!newPrimContacts.isEmpty()){
            insert newPrimContacts;
            
            for(contact secCon: secondaryContacts){
                if(secCon.Primary_Contact__c == null){
                    Boolean foundExistingContact = false;
                    for(Contact primCon : newPrimContacts){
                        
                        if(!foundExistingContact && doContactsMatch(secCon,primCon, matchDotNames)){
                            system.debug('found existing created');
                            foundExistingContact = true;
                            secCon.Primary_Contact__c = primCon.Id;
                            
                        }else{
                            break;
                        }
                        
                        
                    }
                }
                
            }
        }
        
        
        
        if(updateContacts  ){update secondaryContacts;
                            }
        
        
    }
    
    
    public boolean doContactsMatch(Contact secCon, Contact primCon, boolean matchDots){
        Boolean matched = false;
        //Check
        //Rule 1.1 & 1.2
        if(matchDots){
              if( (compareSameFields(secCon,primCon,'FirstName',false,true) && compareSameFields(secCon,primCon,'LastName',false,true)) || secCon.LastName == '.' || primCon.LastName == '.'  ){
            //1.1 compare email
            if(
                compareSameFields(secCon,primCon,'Email',false,true) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                //system.debug('1.1');
                matched = true;
            }else{
                //1.2 compare phones
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'Phone',true,False) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,False) 
                    
                ){
                    system.debug('1.2');
                    matched = true;  
                }
                
                
            }
            
            
        }
        //rule 2.1 & 2.2 moved up due to email
        if(!matched && ((secCon.FirstName != null && primCon.FirstName != null && secCon.FirstName.length() > 2 && primCon.FirstName.length() > 2 && primCon.FirstName.substring(0,3) == secCon.FirstName.substring(0,3) &&  compareSameFields(secCon,primCon,'LastName',false,true)) || secCon.LastName == '.' || primCon.LastName == '.') ){
            //2.1 compare email
            system.debug('2s');
            if(
                compareSameFields(secCon,primCon,'Email', false, false) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                system.debug('2.1');
                matched = true;
            }else{
                //2.4 compare phones
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'Phone',true,False) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,False) 
                    
                ){
                    system.debug('2.2');
                    matched = true;  
                }
                
                
            }
            
            
            
            
            
        }
        
        
        
        //rule 1.3 & 1.4
        if(!matched && ((compareSameFields(secCon,primCon,'Title',false,true) && compareSameFields(secCon,primCon,'LastName',false,true)) || secCon.LastName == '.' || primCon.LastName == '.' ) ){
            //1.3 compare email
            if(
                compareSameFields(secCon,primCon,'Email',false,true) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                system.debug('1.3');
                matched = true;
            }else{
                //1.4 compare phones
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'Phone',true,False) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,False) 
                    
                ){
                    system.debug('1.4');
                    matched = true;  
                }
                
                
            }
        }
        
        //3.1
        if(!matched && ( compareSameFields(secCon,primCon,'LastName',false,true) || secCon.LastName == '.' || primCon.LastName == '.') ){
            //3.2 compare email
            if(
                compareSameFields(secCon,primCon,'Email',false,true) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                system.debug('3.1');
                matched = true;
            }else{
                
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,false) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,false) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,false) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,false) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,false) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,false) ||
                    compareSameFields(secCon,primCon,'Phone',true,false) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,false) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,false) 
                    
                ){
                    system.debug('3.2');
                    matched = true;  
                }
                
                
            }
        }
        }else{
              if( compareSameFields(secCon,primCon,'FirstName',false,true) && compareSameFields(secCon,primCon,'LastName',false,true) ){
            //1.1 compare email
            if(
                compareSameFields(secCon,primCon,'Email',false,true) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                system.debug('1.1');
                matched = true;
            }else{
                //1.2 compare phones
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'Phone',true,False) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,False) 
                    
                ){
                    system.debug('1.2');
                    matched = true;  
                }
                
                
            }
            
            
        }
        //rule 2.1 & 2.2 moved up due to email
        if(!matched && secCon.FirstName != null && primCon.FirstName != null && secCon.FirstName.length() > 2 && primCon.FirstName.length() > 2 && primCon.FirstName.substring(0,3) == secCon.FirstName.substring(0,3) &&  compareSameFields(secCon,primCon,'LastName',false,true) ){
            //2.1 compare email
            system.debug('2s');
            if(
                compareSameFields(secCon,primCon,'Email', false, false) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                system.debug('2.1');
                matched = true;
            }else{
                //2.4 compare phones
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'Phone',true,False) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,False) 
                    
                ){
                    system.debug('2.2');
                    matched = true;  
                }
                
                
            }
            
            
            
            
            
        }
        
        
        
        //rule 1.3 & 1.4
        if(!matched && compareSameFields(secCon,primCon,'Title',false,true) && compareSameFields(secCon,primCon,'LastName',false,true) ){
            //1.3 compare email
            if(
                compareSameFields(secCon,primCon,'Email',false,true) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                system.debug('1.3');
                matched = true;
            }else{
                //1.4 compare phones
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,False) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,False) ||
                    compareSameFields(secCon,primCon,'Phone',true,False) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,False) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,False) 
                    
                ){
                    system.debug('1.4');
                    matched = true;  
                }
                
                
            }
        }
        
        //3.1
        if(!matched &&  compareSameFields(secCon,primCon,'LastName',false,true) ){
            //3.2 compare email
            if(
                compareSameFields(secCon,primCon,'Email',false,true) || 
                compareDifferentFields(secCon,primCon,'Email','Email2__c',false,true) ||
                compareDifferentFields(secCon,primCon,'Email','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email2__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email2__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email2__c','Email3__c',false,true) ||
                compareSameFields(secCon,primCon,'Email3__c',false,true) || 
                compareDifferentFields(secCon,primCon,'Email3__c','Email',false,true) ||
                compareDifferentFields(secCon,primCon,'Email3__c','Email2__c',false,true) 
            ){
                system.debug('3.1');
                matched = true;
            }else{
                
                if(
                    compareSameFields(secCon,primCon,'MobilePhone',true,false) || 
                    compareDifferentFields(secCon,primCon,'MobilePhone','OtherPhone',true,false) ||
                    compareDifferentFields(secCon,primCon,'MobilePhone','Phone',true,false) ||
                    compareSameFields(secCon,primCon,'OtherPhone',true,false) || 
                    compareDifferentFields(secCon,primCon,'OtherPhone','MobilePhone',true,false) ||
                    compareDifferentFields(secCon,primCon,'OtherPhone','Phone',true,false) ||
                    compareSameFields(secCon,primCon,'Phone',true,false) || 
                    compareDifferentFields(secCon,primCon,'Phone','OtherPhone',true,false) ||
                    compareDifferentFields(secCon,primCon,'Phone','MobilePhone',true,false) 
                    
                ){
                    system.debug('3.2');
                    matched = true;  
                }
                
                
            }
        }
        }
       
        
        return matched;
    }
    
    private Contact createNewPrimaryContact(Contact secondaryContact, Id primaryaccId){
        
        
        Contact con = new Contact();
        con.RecordTypeId = jlrContactRecordType;
        con.AccountId = primaryaccId;
        con.FirstName = secondaryContact.FirstName;
        con.LastName = secondaryContact.LastName;
        con.Title = secondaryContact.Title;
        con.Gender__c = secondaryContact.Gender__c;
        //phones  
        con.MobilePhone = secondaryContact.MobilePhone;
        con.Phone = secondaryContact.Phone;
        con.OtherPhone = secondaryContact.OtherPhone;
        con.HomePhone = secondaryContact.HomePhone;
        //emails
        con.Email = secondaryContact.Email;
        con.Email2__c = secondaryContact.Email2__c;
        con.Email3__c = secondaryContact.Email3__c;
        //Owner & bronze
        con.Country_ISO_Code__c = secondaryContact.Country_ISO_Code__c;
        if( secondaryContact.Country_ISO_Code__c != null &&ownerMap!= null && ownerMap.containsKey(secondaryContact.Country_ISO_Code__c)){
            con.OwnerId = ownerMap.get(secondaryContact.Country_ISO_Code__c).id;
        }
        return con;
    }
    
    private boolean compareSameFields(sObject one,sObject two, string apiName, boolean removeNonAlphanumeric, boolean caseInsensitive ){
        boolean match = false;
        if(!removeNonAlphanumeric && !caseInsensitive){
            if(one.get(apiName) != null && two.get(apiName) != null && one.get(apiName)==two.get(apiName)){
                match = true;
            }   
        }else{
            if(removeNonAlphanumeric){
                if(one.get(apiName) != null && two.get(apiName) != null ){
                    string one1 = (string)one.get(apiName);
                    string two2 = (string)two.get(apiName);
                    if(one1.replaceAll('[^0-9]', '') == two2.replaceAll('[^0-9]', '') ){
                        match = true;  
                    }
                    
                }
            }
            if(caseInsensitive){
                if(one.get(apiName) != null && two.get(apiName) != null){
                    string one1 = (string)one.get(apiName);
                    string two2 = (string)two.get(apiName);
                    if(one1.toLowerCase() ==two2.toLowerCase()){
                        match = true; 
                    }
                }
                
            }
        }
        
        
        return match;
        
        
    }
    private boolean compareDifferentFields(sObject one,sObject two, string apiNameOne,string apiNameTwo,boolean removeNonAlphanumeric, boolean caseInsensitive ){
        boolean match = false;
        
        if(!removeNonAlphanumeric && !caseInsensitive ){
            if(one.get(apiNameOne) != null && two.get(apiNameTwo) != null && one.get(apiNameOne)==two.get(apiNameTwo)){
                match = true;
            }
        }else{
            if(removeNonAlphanumeric){
                if(one.get(apiNameOne) != null && two.get(apiNameTwo) != null ){
                    string one1 = (string)one.get(apiNameOne);
                    string two2 = (string)two.get(apiNameTwo);
                    if(one1.replaceAll('[^0-9]', '') == two2.replaceAll('[^0-9]', '') ){
                        match = true;  
                    }
                    
                }
            }
            if(caseInsensitive){
                if(one.get(apiNameOne) != null && two.get(apiNameTwo) != null){
                    string one1 = (string)one.get(apiNameOne);
                    string two2 = (string)two.get(apiNameTwo);
                    if(one1.toLowerCase() ==two2.toLowerCase()){
                        match = true; 
                    }
                }
                
            }  
        }
        
        
        
        return match;
        
        //to remove non alpha String field2 = field1.replaceAll('[^0-9]', '');
        /*  Map<String, Schema.SObjectField> M;
if (TypeObject=='Account') M = Schema.SObjectType.Account.fields.getMap();
Schema.SObjectField field = M.get('Fax');
Schema.DisplayType FldType = field.getDescribe().getType();
*/
        
        
        
        
        
    }
}