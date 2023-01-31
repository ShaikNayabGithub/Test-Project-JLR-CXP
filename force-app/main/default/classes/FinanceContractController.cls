public class FinanceContractController { 
    
    public static set<String> availableCountries = new set<String>{'IN', 'KR'};
    public static set<String> availableRegions = new set<String>{'MENA', 'Korea'};
        
    @AuraEnabled
    public static FinanceContractWrapper getcurrentRecordData(String recordId){
        FinanceContractWrapper finWrap = new FinanceContractWrapper();
        try{
            List<Opportunity> oppList = [select id,Name,AccountId,Account.Name,Asset__c,Asset__r.vin__c,isWon,StageName from Opportunity where id =: recordId];
            user userIns = [select id,name,Market__c,Country_ISO_Code__c from user where isActive = true and Market__c != null and id =: userinfo.getUserId() and Market__c != null and Country_ISO_Code__c != null];
            if(oppList == null  
               || oppList.isEmpty()){
                   finWrap.message = 'Invalid Opportunity';
                   finWrap.isValidStage = false;
                   return finWrap;
               }
            
            if(userIns != null 
               && userIns.Market__c != null
               && userIns.Country_ISO_Code__c != null
               && !availableRegions.contains(userIns.Market__c) 
               && !availableCountries.contains(userIns.Country_ISO_Code__c)){
                   finWrap.message = 'Finance Contract is not available for you region, Please contact System Administrator';
                   finWrap.isValidStage = false;
                   return finWrap;
               }
            
            if(oppList != null 
               && !oppList.isEmpty() 
               && oppList.get(0).AccountId == null){
                   system.debug('--->  '+oppList.get(0).AccountId);
                   finWrap.message = 'Account is not available in the Opportunity';
                   finWrap.isValidStage = false;
                   return finWrap;
               }
            Opportunity oppIns = oppList.get(0);
            
            if(oppIns != null){
                if(checkOpportunityStage(oppIns.StageName,userIns.Market__c)){
                    if(userIns.Market__c == 'IN'){
                        finWrap.message = 'Opportunity must have reached Negotiate/re-opened/order stage to be able to create a finance contract';
                         
                    }else if(userIns.Market__c == 'MENA'){
                        finWrap.message = 'Opportunity must have reached negotiate stage to be able to create a finance contract';
                    }//Added to KR Market as well CXPD-2222
                     else if(userIns.Market__c == 'Korea'){
                        finWrap.message = System.Label.Finance_Opps_Validation;
                    }
                    finWrap.isValidStage = false;
                    return finWrap;
                } 
                
                if(checkExistingOppLineItem(oppIns.Id)){
                    finWrap.message = 'Please add a vehicle to this opportunity before creating a finance contract';
                    finWrap.isValidStage = false;
                    //return finWrap;
                } 
                
                if(checkExistingContract(oppIns.Id)){
                    finWrap.message = 'One or more Live Contract is already available in this Opportunity';
                    finWrap.isValidStage = false;
                    return finWrap;
                }
                Contract contIns = new Contract();
                Id recTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId();
                finWrap.userRegion = userIns.Market__c;
                finWrap.countryCode = userIns.Country_ISO_Code__c;
                
                List<OpportunityLineItem> lineItemList = [select id,UnitPrice,Asset__c,Asset__r.vin__c from OpportunityLineItem where opportunityid =:oppIns.Id and Asset__c != null AND Asset__r.vin__c != null AND Product2.recordtypeid =: recTypeId];
                if(lineItemList != null && !lineItemList.isEmpty()){
                    OpportunityLineItem oppLine = lineItemList.get(0);
                    finWrap.vin = oppLine.Asset__r.vin__c;
                    contIns.Invoice_Price__c = oppLine.UnitPrice;
                }
                
                
                finWrap.iswon = oppIns.iswon;
                finWrap.currUserName = userIns.Name;
                
                Account accIns = [select id,Salutation,firstname,isPersonAccount,Key_Contact__c,recordType.Name,lastname,PersonMobilePhone,PersonEmail,Phone,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry 
                                  from account where id =: oppIns.accountId];
                
                Account newAccIns = new Account();
                newAccIns.BillingStreet = accIns.BillingStreet;
                newAccIns.BillingCity = accIns.BillingCity;
                newAccIns.BillingState = accIns.BillingState;
                newAccIns.BillingPostalCode = accIns.BillingPostalCode;
                newAccIns.BillingCountry = accIns.BillingCountry;
                
                finWrap.isPerson = accIns.isPersonAccount;
                finWrap.accType = accIns.RecordType.Name;
                if(accIns.isPersonAccount){
                    finWrap.salutation = contIns.Salutation__c = accIns.salutation;
                    finWrap.firstName = contIns.FCH_First_Name__c = contIns.First_Name__c = accIns.firstname;
                    finWrap.lastName = contIns.FCH_Last_name__c = contIns.Last_Name__c = accIns.lastName;
                    finWrap.email = contIns.FCH_Email__c = contIns.Email__c = accIns.PersonEmail;
                    finWrap.Phone = contIns.FCH_Phone__c = contIns.Phone__c = accIns.Phone;
                    finWrap.mobile = contIns.FCH_Mobile__c = contIns.Mobile__c = accIns.PersonMobilePhone;
                }else{
                    List<contact> contactList = [select id,Salutation,FirstName,lastName,email,Phone,MobilePhone from contact where accountId =: accIns.Id];
                    if(contactList != null && !contactList.isempty()){
                        Contact conIns;
                        if(contactList.size() == 1){
                            conIns = contactList.get(0);
                        }else if(contactList.size() > 1){
                            for(Contact contRec : contactList){
                                if(accIns.Key_Contact__c != null && accIns.Key_Contact__c == contRec.Id){
                                    conIns = contRec;
                                }
                            }
                        }
                        if(conIns != null){
                            finWrap.contactId = conIns.Id;
                            finWrap.Salutation = contIns.Salutation__c = conIns.Salutation;
                            finWrap.firstName = contIns.FCH_First_Name__c = contIns.First_Name__c = conIns.FirstName;
                            finWrap.lastName = contIns.FCH_Last_name__c = contIns.Last_Name__c = conIns.lastName;
                            finWrap.email = contIns.FCH_Email__c = contIns.Email__c = conIns.email;
                            finWrap.Phone = contIns.FCH_Phone__c = contIns.Phone__c = conIns.Phone;
                            finWrap.mobile = contIns.FCH_Mobile__c = contIns.Mobile__c = conIns.MobilePhone;
                        }
                    }
                }
                
                
                finWrap.acc = newAccIns;
                finWrap.oppName = oppIns.Name;
                finWrap.accName = oppIns.Account.Name; 
                finWrap.accId = oppIns.AccountId;
                finWrap.fchId = oppIns.AccountId;
                contIns.Opportunity__c = oppIns.Id;
                contIns.Contract_Status__c = 'Initial Contract';
                finWrap.cont = contIns; 
                finWrap.isFCHChanged = false;
                finWrap.isValidStage = true;
            }   
        }catch(Exception e){
            finWrap.message = e.getMessage()+'--- '+e.getStackTraceString();
            finWrap.isValidStage = false;
        }
        system.debug('accountId --> '+finWrap.isValidStage);
        return finWrap;
    }
    
    @AuraEnabled
    public static FinanceContractWrapper handleAccountChange(String recordId,String accId){
        FinanceContractWrapper finWrap = new FinanceContractWrapper();
        Contract contIns = new Contract();
        Account accIns = [select id,Name,firstname,isPersonAccount,recordType.Name,lastname,PersonMobilePhone,PersonEmail,Phone,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry 
                          from account where id =: accId];
        
        finWrap.accName = accIns.Name;
        finWrap.fchId = accIns.Id;
        finWrap.accType = accIns.RecordType.Name;
        finWrap.isFchPerson = accIns.isPersonAccount;
        if(accIns.isPersonAccount){
            contIns.FCH_First_Name__c = accIns.firstname;
            contIns.FCH_Last_name__c = accIns.lastName;
            contIns.FCH_Email__c = accIns.PersonEmail;
            contIns.FCH_Phone__c = accIns.Phone;
            contIns.FCH_Mobile__c = accIns.PersonMobilePhone;
        }else{
            List<contact> contactList = [select id,FirstName,lastName,email,Phone,MobilePhone,Gender__c,language__c from contact where accountId =: accIns.Id];
            if(contactList != null && !contactList.isempty()){
                Contact conIns = contactList.get(0);
                finWrap.fchContactId = conIns.Id;
                contIns.FCH_First_Name__c = conIns.FirstName;
                contIns.FCH_Last_name__c = conIns.lastName;
                contIns.FCH_Email__c = conIns.email;
                contIns.FCH_Phone__c = conIns.Phone;
                contIns.FCH_Mobile__c = conIns.MobilePhone;
                finWrap.language = conIns.language__c;
                finWrap.gender = conIns.Gender__c;
            }
        }
        finWrap.isFCHChanged = true;
        finWrap.cont = contIns; 
        return finWrap;
    }
    
    @AuraEnabled
    public static FinanceContractWrapper.dmlwrap saveContract(String recordId,String jsonStr){
        Savepoint sp = Database.setSavepoint();
        system.debug('jsonStr --> '+jsonStr);
        FinanceContractWrapper.dmlWrap dmlWrapIns = new FinanceContractWrapper.dmlWrap();
        try{
            if(jsonStr == null){
                dmlWrapIns.hasErr = true;
                dmlWrapIns.message = 'Invalid Data';
                return dmlWrapIns;
            }
            FinanceContractWrapper finContIns = (FinanceContractWrapper)json.deserialize(jsonStr, FinanceContractWrapper.class);
            
          Id recTypeId;
          system.debug('@@@contract RecordTypeInfosByName Finance check' + Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Finance'));
          if(Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Finance') !=null){
          recTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
                   }
            Id contactRecTypeId;
             if(Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Retailer Contact') !=null){
             contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();    
             }
                 
            Contract contractIns = finContIns.cont;
            if(finContIns != null){
                
                contractIns.Opportunity__c = recordId;
                contractIns.RecordTypeId = recTypeId;
                contractIns.Contract_Status__c = 'Initial Contract';
                contractIns.Mileage_UOM__c = 'Kilometers';
                
                Opportunity oppIns = [select id,Purchase_Type__c from opportunity where id =: recordId];
                if(oppIns != null && oppIns.Purchase_Type__c != null){
                    if(oppIns.Purchase_Type__c == 'New Vehicle'){
                        contractIns.Vehicle_Type__c = 'New';
                    }else if(oppIns.Purchase_Type__c == 'Used Vehicle'){
                        contractIns.Vehicle_Type__c = 'Used';
                    }
                }        
                
                List<OpportunityLineItem> lineItemList = [select id,Brand__c,Model__c,product2id,product2.Model_Alternative__c from OpportunityLineItem where opportunityid =:recordId AND (Brand__c != null OR Model__c != null)];
                if(lineItemList != null && !lineItemList.isEmpty()){
                    if(lineItemList.get(0).Brand__c != null){
                        contractIns.Brand__c = lineItemList.get(0).Brand__c;
                    }
                    if(lineItemList.get(0).Model__c != null){
                        contractIns.Model__c = lineItemList.get(0).Model__c;
                    }
                    if(lineItemList.get(0).product2id != null && lineItemList.get(0).product2.Model_Alternative__c != null){
                        contractIns.Model_Alternative__c = lineItemList.get(0).product2.Model_Alternative__c;
                    }
                }
                
                if(finContIns.accId != null){
                    contractIns.AccountId = finContIns.accId; 
                }
                if(finContIns.fchId != null){
                    contractIns.FCH_Finance_contract_holder_Account__c = finContIns.fchId; 
                }
                if(finContIns.vin != null){
                    List<Asset> assetList = [select id,VIN__c,Handover_Date__c from Asset where VIN__c =: finContIns.vin];
                    if(assetList != null && !assetList.isEmpty()){
                        contractIns.Asset__c =  assetList.get(0).Id;
                        contractIns.Handover_Date__c = assetList.get(0).Handover_Date__c;
                    }
                }
                if(finContIns.accId != null){
                    Account accountIns = new Account();
                    accountIns.Id = finContIns.accId;
                    if(finContIns.acc != null){
                        if(finContIns.acc.BillingStreet != null) contractIns.BillingStreet = accountIns.BillingStreet = finContIns.acc.BillingStreet;
                        if(finContIns.acc.BillingCity != null) contractIns.BillingCity = accountIns.BillingCity = finContIns.acc.BillingCity;
                        if(finContIns.acc.BillingState != null) contractIns.BillingState = accountIns.BillingState = finContIns.acc.BillingState;
                        if(finContIns.acc.BillingPostalCode != null) contractIns.BillingPostalCode =  accountIns.BillingPostalCode = finContIns.acc.BillingPostalCode;
                        if(finContIns.acc.BillingCountry != null) contractIns.BillingCountry = accountIns.BillingCountry = finContIns.acc.BillingCountry;
                    }
                    if(finContIns.isPerson){
                        accountIns.Salutation = finContIns.Salutation;
                        accountIns.firstName = finContIns.firstName;
                        accountIns.lastName = finContIns.lastName;
                        accountIns.PersonMobilePhone = finContIns.mobile;
                        accountIns.PersonEmail = finContIns.email;
                        accountIns.phone = finContIns.phone;
                        update accountIns;
                    }else if(finContIns.contactId != null){
                        Contact contactIns = new Contact();
                        contactIns.Salutation = finContIns.Salutation;
                        contactIns.Id = finContIns.contactId;
                        contactIns.firstName = finContIns.firstName;
                        contactIns.lastName = finContIns.lastName;
                        contactIns.MobilePhone = finContIns.mobile;
                        contactIns.email = finContIns.email;
                        contactIns.phone = finContIns.phone;
                        update contactIns;
                    }
                    
                    if(finContIns.isFCHChanged != null && finContIns.isFCHChanged && finContIns.cont != null && !finContIns.isFchPerson){
                        Contact contactIns = new Contact();
                        contactIns.firstName = finContIns.cont.FCH_First_Name__c;
                        contactIns.lastName = finContIns.cont.FCH_Last_name__c;
                        contactIns.MobilePhone = finContIns.cont.FCH_Mobile__c;
                        contactIns.email = finContIns.cont.FCH_Email__c;
                        contactIns.phone = finContIns.cont.FCH_Phone__c;
                        contactIns.Gender__c = finContIns.gender;
                        contactIns.Language__c = finContIns.language;
                        if(finContIns.fchContactId != null){
                            contactIns.Id = finContIns.fchContactId;       
                            update contactIns;
                        }else if(finContIns.fchId != null){
                            contactIns.RecordTypeId = contactRecTypeId;
                            contactIns.AccountId = finContIns.fchId;
                            
                            Database.DMLOptions dml = new Database.DMLOptions();
                            dml.DuplicateRuleHeader.AllowSave = true; 
                            Database.SaveResult sr = Database.insert(contactIns, dml); 
                            if (sr.isSuccess()) {   
                            }else{
                                String finDmlError; 
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                    finDmlError = err.getMessage();
                                }
                                if(finDmlError != null){
                                    dmlWrapIns.hasErr = true;
                                    dmlWrapIns.message = finDmlError;
                                    return dmlWrapIns;
                                }
                            }
                        }
                    }
                }
                
                insert contractIns;
                Contract contrIns = [select id,contractnumber from Contract where id =: contractIns.Id];
                dmlWrapIns.contNumber = contrIns.contractnumber;
                dmlWrapIns.hasErr = false;
                dmlWrapIns.recId = contractIns.Id; 
                dmlWrapIns.message = 'Finance contract has been created!';
            }else{
                dmlWrapIns.hasErr = true;
                dmlWrapIns.message = 'Invalid Data';
            }
        }catch(DMLException dmx){
            Database.rollback(sp);
            dmlWrapIns.hasErr = true;
            dmlWrapIns.message = dmx.getDmlMessage(0)+' '+dmx.getLineNumber();
            
        }catch(Exception ex){
            Database.rollback(sp);
            dmlWrapIns.hasErr = true;
            dmlWrapIns.message = ex.getMessage()+' '+ex.getStackTraceString();
        }
        return dmlWrapIns;
    }
    
    public static Boolean checkOpportunityStage(String stageValue,String market){
        system.debug('stageValue --> '+stageValue);
        List<Opportunity_Stage_Data__mdt> stageList = [select id,Stage_Value__c,Region_or_Market__c
                                                       from Opportunity_Stage_Data__mdt 
                                                       where Stage_Value__c =:stageValue and Region_or_Market__c =:market];
        if(stageList != null && !stageList.isEmpty()){
            return false;
        }else{
            return true;
        }
    }
    
    public static Boolean checkExistingOppLineItem(id oppId){
        List<opportunitylineitem> opportunitylineitemList = [select id,opportunityid from opportunitylineitem where opportunityid =: oppId];
        if(opportunitylineitemList != null && !opportunitylineitemList.isEmpty()){
            return false;
        }else{
            return true;
        }
    }
    
    public static Boolean checkExistingContract(id oppId){
        set<String> contractStatusSet = new set<String>();
        for(Finance_Contract_Validation_Status__mdt finCont : [select id,Status_Value__c from Finance_Contract_Validation_Status__mdt where Status_Value__c != null]){
            contractStatusSet.add(finCont.Status_Value__c);
        }
        if(contractStatusSet != null && !contractStatusSet.isEmpty()){
            List<Contract> contractList = [select id from contract where Opportunity__c =: oppId AND Contract_Status__c IN: contractStatusSet];
            if(contractList != null && !contractList.isEmpty()){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    
    @AuraEnabled public static List<FinanceContractWrapper.pickWrap> getPicklistValuesData(String ObjectApi_name,String Field_name){ 
        
        List<FinanceContractWrapper.pickWrap> pickWrapList =new List<FinanceContractWrapper.pickWrap>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pick_list_values) { 
            if(a.isActive()){
                FinanceContractWrapper.pickWrap pickWrapIns = new FinanceContractWrapper.pickWrap();
                pickWrapIns.label = a.getLabel();
                pickWrapIns.value = a.getValue();
                pickWrapList.add(pickWrapIns);
            }
        }
        if(pickWrapList != null && !pickWrapList.isEmpty()){
            return pickWrapList;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<FinanceContractWrapper.pickWrap> getContractPicklistValues(String market,String fieldName){
        List<FinanceContractWrapper.pickWrap> pickWrapList =new List<FinanceContractWrapper.pickWrap>();
        for(Contract_Field_Data__c conf : [select id,name,Market__c from Contract_Field_Data__c where Market__c =:market and Contract_Field__c =: fieldName]){
            FinanceContractWrapper.pickWrap pickWrapIns = new FinanceContractWrapper.pickWrap();
            pickWrapIns.label = conf.name;
            pickWrapIns.value = conf.Id;
            pickWrapList.add(pickWrapIns);
        }
        if(pickWrapList != null && !pickWrapList.isEmpty()){
            return pickWrapList;
        }
        return null;
        
    }
}