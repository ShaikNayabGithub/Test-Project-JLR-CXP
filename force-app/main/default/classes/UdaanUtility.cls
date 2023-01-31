public class UdaanUtility { 
    
    //This method is created by SaasFocus on date 4 may 2017
    //This method is used to find duplicate lead on before insert and check a check box if duplicate lead already exist
    public static void IndiaUdaan_checkDuplicateLead(List < Lead > triggerNew) {
        Set < String > setOfCombination = new Set < String > ();
        Map < Id, Lead > mapIdToLead = new Map < Id, Lead > ();
        set < string > setCombinationInDatabase = new set < string > ();
        List < Lead > lstWebsiteLeads = new List < Lead > (); 
        if (triggerNew != null && triggerNew.size() > 0) {
            For(Lead objLead : triggerNew)
            {
                if(string.isNotEmpty(objLead.WebSiteLeadId__c))
                {
                    lstWebsiteLeads.add(objLead);
                    if(lstWebsiteLeads.size()>0)
                    {
                        setCombinationInDatabase = IndiaUdaan_queryLeadsInDatabase(lstWebsiteLeads);
                        if (!setCombinationInDatabase.isEmpty()) {
                            IndiaUdaan_tickCheckbox(setCombinationInDatabase,lstWebsiteLeads);
                        }
                    }
                    
                }
            }
        } 
    }
    
    
    public static set < string > IndiaUdaan_queryLeadsInDatabase(List < Lead > triggerNew) {
        
        set < string > setCombination = new set < string > ();
        if(triggerNew.size()>0)
        {
            set < string >  setPrefferedRetailer = new set < string > ();
            set < string >  setBrand = new set < string > ();
            set < string >  setPimaryModelOfInterest = new set < string > ();
            set < string >  setEmail = new set < string > ();
            set < string >  setMobile = new set < string > ();
            set < string >  setLastName = new set < string > ();
            for(Lead objLead : triggerNew)
            {
                if ( string.isNotEmpty(objLead.Preferred_Retailer__c) )
                    setPrefferedRetailer.add(objLead.Preferred_Retailer__c);
                if ( string.isNotEmpty(objLead.Brand__c) )
                    setBrand.add(objLead.Brand__c);
                if ( string.isNotEmpty(objLead.Primary_Model_Interest__c) )
                    setPimaryModelOfInterest.add(objLead.Primary_Model_Interest__c);
                if ( string.isNotEmpty(objLead.Email))
                    setEmail.add(objLead.Email);
                if ( string.isNotEmpty(objLead.MobilePhone) )
                    setMobile.add(objLead.MobilePhone);
                if ( string.isNotEmpty(objLead.LastName) )
                    setLastName.add(objLead.LastName);
            }
            if(!setPrefferedRetailer.isEmpty() && !setBrand.isEmpty() && !setPimaryModelOfInterest.isEmpty() && (!setEmail.isEmpty() ||!setMobile.isEmpty() ||  !setLastName.isEmpty()))
            {
                for (Lead leadObj: [Select Id, Preferred_Retailer__c,Brand__c, Primary_Model_Interest__c, LastName, Email, MobilePhone
                                    from Lead where Preferred_Retailer__c in : setPrefferedRetailer
                                    and Brand__c in : setBrand
                                    and Primary_Model_Interest__c in : setPimaryModelOfInterest
                                    and (Email in : setEmail
                                         or LastName in :setLastName
                                         or MobilePhone in : setMobile
                                        )
                                    
                                   ]) {
                                       setCombination.add(leadObj.Preferred_Retailer__c+'-'+leadObj.Brand__c+'-'+leadObj.Primary_Model_Interest__c+'-'+leadObj.Email);
                                       setCombination.add(leadObj.Preferred_Retailer__c+'-'+leadObj.Brand__c+'-'+leadObj.Primary_Model_Interest__c+'-'+leadObj.MobilePhone);
                                       setCombination.add(leadObj.Preferred_Retailer__c+'-'+leadObj.Brand__c+'-'+leadObj.Primary_Model_Interest__c+'-'+leadObj.LastName);
                                   }
            }
            
            
        }
        system.debug('setcombination---'+setCombination);
        return setCombination;
    }
    
    public static void IndiaUdaan_tickCheckbox(set < string > setCombinationInDatabase,List< Lead > lstLead) {
        
        String combination_Rtlr_Brand_PrimaryMdl_Email = '';
        String combination_Rtlr_Brand_PrimaryMdl_Mobile = '';
        String combination_Rtlr_Brand_PrimaryMdl_LstNm = '';
        for (Lead objLead: lstLead) {
            if (string.isNotEmpty(objLead.WebSiteLeadId__c)) {
                combination_Rtlr_Brand_PrimaryMdl_Email = '';
                combination_Rtlr_Brand_PrimaryMdl_Mobile = '';
                combination_Rtlr_Brand_PrimaryMdl_LstNm = '';
                combination_Rtlr_Brand_PrimaryMdl_Email = objLead.Preferred_Retailer__c+'-'+objLead.Brand__c+'-'+objLead.Primary_Model_Interest__c;
                combination_Rtlr_Brand_PrimaryMdl_Mobile = objLead.Email != null ? combination_Rtlr_Brand_PrimaryMdl_Email + '-' + objLead.Email : combination_Rtlr_Brand_PrimaryMdl_Email + '-';
                combination_Rtlr_Brand_PrimaryMdl_LstNm += objLead.MobilePhone != null ? combination_Rtlr_Brand_PrimaryMdl_Email + '-' + objLead.MobilePhone : combination_Rtlr_Brand_PrimaryMdl_Email + '-';
                combination_Rtlr_Brand_PrimaryMdl_Email += objLead.LastName != null ? '-' + objLead.LastName : '-';
                
                if ((combination_Rtlr_Brand_PrimaryMdl_Email != '' && setCombinationInDatabase.contains(combination_Rtlr_Brand_PrimaryMdl_Email)) || (combination_Rtlr_Brand_PrimaryMdl_Mobile != '' && setCombinationInDatabase.contains(combination_Rtlr_Brand_PrimaryMdl_Mobile)) || (combination_Rtlr_Brand_PrimaryMdl_LstNm != '' && setCombinationInDatabase.contains(combination_Rtlr_Brand_PrimaryMdl_LstNm))) {
                    objLead.JLR_India_Udaan_Duplicate__c = true;
                    setCombinationInDatabase.add(combination_Rtlr_Brand_PrimaryMdl_Email);
                    setCombinationInDatabase.add(combination_Rtlr_Brand_PrimaryMdl_Mobile);
                    setCombinationInDatabase.add(combination_Rtlr_Brand_PrimaryMdl_LstNm);
                }
                
                
            }
            system.debug('setCombinationInDatabase---'+setCombinationInDatabase);
        }
    }
    
    public static void IndiaUdaan_createTask(List < Lead > triggerNew) {
        Set < Id > setDealer = new Set < Id > ();
        Set < Id > leadIDs = new Set < Id > (); // Added by NTT as part of Code optimisation - 14/06/2021
        List < Task > lstTaskToInsert = new List < Task > ();
        task objTask;
        Task_Reference__c objTR = new Task_Reference__c();
        Map < Id, Id > mapDealerManager = new Map < Id, Id > ();
        Map < Id, Lead > mapIdToLead = new Map < Id, Lead > ();
        for (Lead l: triggerNew) {
            if(string.isNotEmpty(l.WebSiteLeadId__c) ) {
                if( string.isNotEmpty(l.Preferred_Retailer__c))
                {
                    setDealer.add(l.Preferred_Retailer__c);
                }
                leadIDs.add(l.Id); // Added by NTT as part of Code optimisation - 14/06/2021
            }
        }
        if(!leadIDs.isEmpty()){ // Added by NTT as part of Code optimisation - 14/06/2021
            for (Lead objLead: [Select Id, Owner.type, Owner.UserRole.Name, Owner.Name, Brand__r.Name, Primary_Model_Interest__r.Name, Preferred_Retailer__r.Name, Preferred_Retailer__c from Lead where Id IN : leadIDs ]) {
                mapIdToLead.put(objLead.id, objLead);
            }
        }
        if (setDealer.size() > 0) {
            for (Dealer_Manager__c objDM: [Select id, Dealer__c, Manager__c from Dealer_Manager__c where Dealer__c in : setDealer]) {
                mapDealerManager.put(objDM.Dealer__c, objDM.Manager__c);
                system.debug(mapDealerManager + 'mapDealerManager');
            }
        }
        for (lead objLead: triggerNew) {
            if(string.isNotEmpty(objLead.WebSiteLeadId__c))
            {
                if (objLead.JLR_India_Udaan_Duplicate__c) {
                    if (objLead.RecordtypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Test Drive Request').getRecordTypeId()) {
                        objTR = Task_Reference__c.getvalues('Duplicate and Test Drive');
                    } else {
                        objTR = Task_Reference__c.getvalues('Duplicate Lead');
                    }
                } else {
                    if (objLead.RecordtypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Test Drive Request').getRecordTypeId()) {
                        objTR = Task_Reference__c.getvalues('Test Drive Request');
                    } else
                        if (objLead.RecordtypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Generic').getRecordTypeId()) {
                            if (objLead.JLR_India_Udaan_Lead_Type__c == 'Quotation')
                                objTR = Task_Reference__c.getvalues('Quotation');
                            else
                                objTR = Task_Reference__c.getvalues('Generic Follow-Up');
                        } 
                    
                }
                if(objTR!=null)
                {
                    objTask = new task(
                        priority = 'High',
                        subject = objTR.subject__c,
                        description = objTR.Description__c,
                        whoid = objLead.id,
                        activityDate = System.Today()
                    );
                    if (mapIdToLead.containsKey(objLead.id) && mapIdToLead.get(objLead.id).owner.type == 'Queue' && mapDealerManager.containskey(objLead.Preferred_Retailer__c))
                        objTask.OwnerId = mapDealerManager.get(objLead.Preferred_Retailer__c);
                    else if (mapIdToLead.containsKey(objLead.id) && mapIdToLead.get(objLead.id).Owner.type == 'User')
                        objTask.OwnerId = objLead.ownerId;
                    lstTaskToInsert.add(objTask);
                } 
            }
        }
        if (lstTaskToInsert.size() > 0)
            insert lstTaskToInsert;
    } 
}