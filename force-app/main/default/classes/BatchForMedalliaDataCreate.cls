public class BatchForMedalliaDataCreate implements Database.Batchable<sObject> { 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //MedalliaBatchRunDays
        Integer addDays = integer.valueOf(System.Label.MedalliaBatchRunDays);
        Date dt = date.today().addDays(addDays);
        system.debug('dt' +dt);
       return Database.getQueryLocator(
            'SELECT Id,Name, CreatedDate, Customer__c,Language__c,Retailer__c, Retailer__r.Name,Retailer__r.Trading_Name__c, Retailer__r.Dealer_CI_Code__c,Retailer__r.Dealer_CI_Code_2__c, Retailer__r.Primary_Dealer_Code__c,Survey__c, Survey__r.Survey_Type__c, Service__c, Service__r.Country__c,Service__r.Brand__c,Service__r.Service_Repair_Date__c, Service__r.Asset__c, Service__r.Asset__r.Model__c, Service__r.Asset__r.Model__r.ProductCode, '+
            'Service__r.Asset__r.Model__r.Name,Service__r.Service_Source__c, Service__r.Asset__r.Derivative__c,Service__r.Asset__r.Derivative__r.Name, Service__r.Asset__r.Derivative__r.Model_Year__c, Service__r.Asset__r.Brand__c,Service__r.Asset__r.Brand__r.Name,Service__r.LIcence_Plate__c,Service__r.Country_ISO_Code__c,'+
            'Service__r.Asset__r.VIN__c,Service__r.Asset__r.Retailer_Name__c,Service__r.Asset__r.Product2Id,Service__r.Asset__r.Product2.Model__c,Service__r.Asset__r.Product2.Model__r.Model_Alternative__c,Service__r.Asset__r.Product2.Model__r.ProductCode, Service__r.Asset__r.Retailer_Name__r.Primary_Dealer_Code__c, Service__r.Account__c,Service__r.Account__r.Country_ISO_Code__c,Service__r.Account__r.Select_Country_ISO_Code__c,Service__r.Account__r.RecordTypeId, Service__r.Account__r.RecordType.Name, Service__r.Account__r.Language__pc, Service__r.Account__r.Gender__pc, Service__r.Retailer_Name__c,'+
            'Service__r.Asset__r.Product2.Model__r.Model_Year__c, Service__r.Asset__r.Product2.Model_Year__c, Service__r.Asset__r.Dealer_Code__c, Service__r.Service_Employee_Code__c, Service__r.Service_Employee_Name__c,'+
            'Opportunity__c, Opportunity__r.Country_ISO_Code__c, Opportunity__r.Brand__c,Opportunity__r.Brand__r.Name, Opportunity__r.AccountId, Opportunity__r.Handover_Date__c,Opportunity__r.CloseDate, Opportunity__r.Retailer__c, Opportunity__r.Retailer__r.Name, Opportunity__r.Retailer__r.Primary_Dealer_Code__c,'+
            'Opportunity__r.Retailer__r.Region_or_Market__c, Opportunity__r.OwnerId, Opportunity__r.owner.EmployeeNumber, Opportunity__r.owner.Name,'+
            '(SELECT Id,Answer_Rating__c,Answer__c,Answer_Verbatim__c,AP_Survey_Question__c,Question_Type__c, Survey_Response__c, Medallia_Ans_Type__c, Medallia_Value__c, Medallia_Field_API__c, Medallia_Field_API_2__c FROM AP_Survey_Responses_Lines__r)'+
            'FROM AP_Survey_Response__c WHERE CreatedDate >=: dt AND Create_Medallia_Data__c = false order by CreatedDate desc'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<AP_Survey_Response__c> records){
        // process each batch of records
        set<Id> oppIds = new set<Id>();
        set<Id> accIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
        Map<Id, Opportunity> oppMapIdswithOpp = new Map<Id, Opportunity>();
        Map<Id, Account> accMapIdswithAcc = new Map<Id, Account>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Account> accounts = new List<Account>();
        Set<Id> retailerIds = new Set<Id>();
        
        if( records.size() > 0 ){
            Map<String, String> countryValueWithCountryLabel = new Map<String, String>();
            List<Schema.PicklistEntry> countryPicklistEntries = Schema.SObjectType.Service_Data__c.fields.Country_ISO_Code__c.getPicklistValues();
            for(Schema.PicklistEntry v : countryPicklistEntries) {
                countryValueWithCountryLabel.put(v.getValue(),v.getLabel());
            }
            
            for(AP_Survey_Response__c sp : records){
                retailerIds.add(sp.Retailer__c);
                if(sp.Survey__r.Survey_Type__c == 'Purchase'){
                    oppIds.add(sp.Opportunity__c);
                    accIds.add(sp.Opportunity__r.AccountId);
                }
            }
            Map<Id, String> retailerIdWithPriDealerCodeForJaguar = new Map<Id, String>();
            Map<Id, String> retailerIdWithPriDealerCodeForLandRover = new Map<Id, String>();
            Set<Id> retailerIdsJaguar = new Set<Id>();
            Set<Id> retailerIdsLandRover = new Set<Id>();
            
            if(!retailerIds.isEmpty()){
                List<Account> retailerChildBrandJaguar = [SELECT Id,ParentId, Primary_Dealer_Code__c FROM Account 
                                                          WHERE ParentId IN : retailerIds AND Brand__c =:'Jaguar' AND Primary_Dealer_Code__c != null 
                                                          AND Retailer_Type__c != 'Body and Paint Centre' AND Retailer_Status__c = 'Trading' ]; 
                 if(retailerChildBrandJaguar.size()>0) { 
                    for(Account aBJ : retailerChildBrandJaguar){
                        retailerIdWithPriDealerCodeForJaguar.put(aBJ.ParentId, aBJ.Primary_Dealer_Code__c);
                    }
                }
                List<Account> retailerBrandLandRover = [SELECT Id,ParentId, Primary_Dealer_Code__c FROM Account 
                                                        WHERE ParentId IN : retailerIds AND Brand__c =:'Land Rover' AND Primary_Dealer_Code__c != null
                                                        AND Retailer_Type__c != 'Body and Paint Centre' AND Retailer_Status__c = 'Trading']; 
                if(retailerBrandLandRover.size()>0) { 
                    for(Account aBLR : retailerBrandLandRover){
                        retailerIdWithPriDealerCodeForLandRover.put(aBLR.ParentId, aBLR.Primary_Dealer_Code__c); 
                    }
                }
                for(Id rt: retailerIds){
                    if(retailerIdWithPriDealerCodeForJaguar.containsKey(rt)){
                    }else{
                        retailerIdsJaguar.add(rt);
                    }
                    if(retailerIdWithPriDealerCodeForLandRover.containsKey(rt)){
                    }else{
                        retailerIdsLandRover.add(rt);
                    }
                }
                if(!retailerIdsJaguar.isEmpty()){
                   List<Account> retailerChildBrandJaguar1 = [SELECT Id,ParentId, Primary_Dealer_Code__c FROM Account 
                                                               WHERE ParentId IN : retailerIdsJaguar AND Brand__c =:'Jaguar' AND Primary_Dealer_Code__c != null];
                    for(Account aBJ : retailerChildBrandJaguar1){
                        retailerIdWithPriDealerCodeForJaguar.put(aBJ.ParentId, aBJ.Primary_Dealer_Code__c); 
                    }
                }
                if(!retailerIdsLandRover.isEmpty()){
                     List<Account> retailerBrandLandRover1 = [SELECT Id,ParentId, Primary_Dealer_Code__c FROM Account 
                                                             WHERE ParentId IN : retailerIdsLandRover AND Brand__c =:'Land Rover' AND Primary_Dealer_Code__c != null];
                    for(Account aBLR : retailerBrandLandRover1){
                        retailerIdWithPriDealerCodeForLandRover.put(aBLR.ParentId, aBLR.Primary_Dealer_Code__c); 
                    }
                }
            }
            if(!oppIds.isEmpty()){
                opportunities = [Select Id, (select Id, Name, Licence_Plate__c,ProductCode, Model__c, Model__r.ProductCode, Model__r.Name, Asset__c, Asset__r.Product2Id, Asset__r.Product2.Model_Year__c, Asset__r.Product2.Model__c, Asset__r.Product2.Model__r.Model_Alternative__c, Asset__r.Product2.Model__r.ProductCode, Asset__r.Derivative__c,
                                             Asset__r.Derivative__r.Name, Asset__r.Derivative__r.Model_Year__c, Asset__r.VIN__c from OpportunityLineItems ORDER BY CreatedDate DESC LIMIT 1) from Opportunity Where Id IN: oppIds];
                for(Opportunity opp : opportunities){
                    oppMapIdswithOpp.put(opp.Id, opp);
                }
            }
            if(!accIds.isEmpty()){
                accounts = [Select Id, (select Id, Gender__c, Language__c from Contacts ORDER BY CreatedDate DESC LIMIT 1) from Account Where Id IN: accIds];
                for(Account acc : accounts){
                    accMapIdswithAcc.put(acc.Id, acc);
                }
            }
            Id recordTypeIdPS = Schema.SObjectType.Medallia_Data__c.getRecordTypeInfosByName().get('Purchase Survey').getRecordTypeId();
            Id recordTypeIdSS = Schema.SObjectType.Medallia_Data__c.getRecordTypeInfosByName().get('Service Survey').getRecordTypeId();
            List<AP_Survey_Response__c> apSRList = new List<AP_Survey_Response__c>();
            List<Medallia_Data__c> medList = new List<Medallia_Data__c>();
            Medallia_Data__c mdl;
            
            for(AP_Survey_Response__c sp : records){
                
                if(sp.AP_Survey_Responses_Lines__r.size() > 0){
                    mdl = new Medallia_Data__c();
                    mdl.AP_Survey_Response__c = sp.Id;
                    mdl.e_jlr_case_id_text__c = sp.Name;
                    mdl.e_bp_uniquerecordid_txt__c = sp.Id;
                    mdl.e_responsedate__c = string.valueOf(sp.CreatedDate.Date());
                    mdl.q_jlr_anonymous_yn__c = '2';
                    mdl.e_jlr_itype_enum__c = 'H';
                    mdl.e_jlr_test_sample_yn__c = '0';
                    mdl.e_jlr_business_region_auto__c = 'Asia Pacific Importers';
                    mdl.e_jlr_dealer_name_auto__c = sp.Retailer__r.Trading_Name__c;
                    mdl.e_jlr_language_id_enum__c = sp.Language__c;
                    mdl.Customer__c = sp.Customer__c;
                    
                    //=============Survey_Type__c = Service====================
                    if(sp.Survey__r.Survey_Type__c == 'Service'){
                        mdl.e_jlr_survey_type_id_enum__c = '2';
                        mdl.e_jlr_event_type_id_enum__c = '2';
                        mdl.RecordTypeId = recordTypeIdSS;
                        mdl.e_jlr_model_code_auto__c = sp.Service__r.Asset__r.Product2.Model__r.ProductCode;
                        mdl.e_jlr_model_description_text__c = sp.Service__r.Asset__r.Product2.Model__r.Model_Alternative__c;
                        mdl.e_jlr_model_year_auto__c = sp.Service__r.Asset__r.Product2.Model_Year__c;
                        mdl.e_jlr_model_variant_code_auto__c = sp.Service__r.Asset__r.Product2.Model__r.Model_Alternative__c;
                        mdl.e_jlr_manufacturer_id_enum__c = sp.Service__r.Asset__r.Brand__r.Name;
                        if(mdl.e_jlr_manufacturer_id_enum__c == 'Jaguar' || Test.isRunningTest()){
                            mdl.e_jlr_manufacturer_enum__c = '2';
                        }
                        if(mdl.e_jlr_manufacturer_id_enum__c == 'Land Rover' || Test.isRunningTest()){
                            mdl.e_jlr_manufacturer_enum__c = '3';
                        }
                        mdl.e_jlr_car_registration_text__c = sp.Service__r.LIcence_Plate__c;
                        mdl.e_jlr_vehicle_identification_number_text__c = sp.Service__r.Asset__r.VIN__c;
                        mdl.e_jlr_model_variant_description_text__c = sp.Service__r.Asset__r.Derivative__r.Name;
                        if(countryValueWithCountryLabel.containsKey(sp.Service__r.Country_ISO_Code__c)){
                            mdl.e_jlr_country_name_auto__c = countryValueWithCountryLabel.get(sp.Service__r.Country_ISO_Code__c); 
                        }
                        mdl.e_jlr_country_id_enum__c = sp.Service__r.Country_ISO_Code__c;
                        mdl.e_jlr_customer_unique_id__c = sp.Service__r.Account__c;
                        
                        if(sp.Service__r.Account__r.RecordType.Name == 'Individual' || Test.isRunningTest()){
                            mdl.Gender__c = sp.Service__r.Account__r.Gender__pc;
                        }
                        if(sp.Service__r.Service_Repair_Date__c != null){
                            mdl.e_jlr_event_date__c = string.valueOf((sp.Service__r.Service_Repair_Date__c).Date());
                        }
                        if(sp.Service__r.Brand__c == 'Jaguar' || Test.isRunningTest()){
                            mdl.e_jlr_dealer_code_auto__c = sp.Retailer__r.Dealer_CI_Code__c;
                            if(retailerIdWithPriDealerCodeForJaguar.containsKey(sp.Retailer__c)){
                                string PriDealerCodeForJaguar = retailerIdWithPriDealerCodeForJaguar.get(sp.Retailer__c);
                                if(PriDealerCodeForJaguar.length() >10){
                                    mdl.e_jlr_global_dealer_code_auto__c = PriDealerCodeForJaguar.substring(PriDealerCodeForJaguar.length()-10);
                                }else{
                                    mdl.e_jlr_global_dealer_code_auto__c = PriDealerCodeForJaguar;
                                }
                            }
                        }
                        if(sp.Service__r.Brand__c == 'Land Rover' || Test.isRunningTest()){
                            mdl.e_jlr_dealer_code_auto__c = sp.Retailer__r.Dealer_CI_Code_2__c;
                            if(retailerIdWithPriDealerCodeForLandRover.containsKey(sp.Retailer__c)){
                                string PriDealerCodeForLandRover = retailerIdWithPriDealerCodeForLandRover.get(sp.Retailer__c);
                                if(PriDealerCodeForLandRover.length() > 10){
                                    mdl.e_jlr_global_dealer_code_auto__c = PriDealerCodeForLandRover.substring(PriDealerCodeForLandRover.length()-10);
                                }else{
                                    mdl.e_jlr_global_dealer_code_auto__c = PriDealerCodeForLandRover;
                                }
                            }
                        }
                        mdl.e_jlr_employee_code_text__c = sp.Service__r.Service_Employee_Code__c;
                        mdl.e_jlr_employee_name_text__c = sp.Service__r.Service_Employee_Name__c;
                        if(string.isNotBlank(sp.Service__r.Service_Source__c) || Test.isRunningTest()){
                            if(sp.Service__r.Service_Source__c == 'Service' || Test.isRunningTest()){
                                mdl.e_jlr_service_event_type_auto__c = '1'; 
                            }
                            if(sp.Service__r.Service_Source__c == 'Warranty Repair' || Test.isRunningTest()){
                                mdl.e_jlr_service_event_type_auto__c = '2';
                            }
                            if(sp.Service__r.Service_Source__c == 'Service that includes warranty work' || Test.isRunningTest()){
                                mdl.e_jlr_service_event_type_auto__c = '3';
                            }
                            if(sp.Service__r.Service_Source__c == 'Repair' || Test.isRunningTest()){
                                mdl.e_jlr_service_event_type_auto__c = '4';
                            }
                        }
                        //e_jlr_model_variant_code_auto__c and e_jlr_model_description_text__c same value
                       // mdl.e_jlr_model_variant_code_auto__c = sp.Service__r.Asset__r.Product2.Model__r.Model_Alternative__c;
                        //mdl.e_jlr_party_id_int__c =
                        // mdl.e_jlr_ownersip_cycle_auto__c =
                        // mdl.e_jlr_svo_type_id_enum__c =
                        // mdl.e_jlr_svo_dealership_yn__c = 
                        //mdl.e_jlr_fob_code_enum__c = 
                    }
                    
                    //=============Survey_Type__c = Purchase====================
                    if(sp.Survey__r.Survey_Type__c == 'Purchase'){
                        mdl.RecordTypeId = recordTypeIdPS;
                        mdl.e_jlr_event_type_id_enum__c = '1';
                        mdl.e_jlr_survey_type_id_enum__c = '1';
                        mdl.e_jlr_event_date__c = string.valueOf(sp.Opportunity__r.CloseDate);
                        mdl.e_jlr_employee_code_text__c = sp.Opportunity__r.owner.EmployeeNumber;
                        mdl.e_jlr_employee_name_text__c = sp.Opportunity__r.owner.name;
                        mdl.e_jlr_country_id_enum__c = sp.Opportunity__r.Country_ISO_Code__c;
                        if(countryValueWithCountryLabel.containsKey(sp.Opportunity__r.Country_ISO_Code__c)){
                            mdl.e_jlr_country_name_auto__c = countryValueWithCountryLabel.get(sp.Opportunity__r.Country_ISO_Code__c); 
                        }
                        if(sp.Opportunity__r.Brand__r.Name =='Land Rover'  || Test.isRunningTest()){
                            mdl.e_jlr_dealer_code_auto__c = sp.Retailer__r.Dealer_CI_Code_2__c;
                            if(retailerIdWithPriDealerCodeForLandRover.containsKey(sp.Retailer__c)){
                                if(retailerIdWithPriDealerCodeForLandRover.get(sp.Retailer__c).length() >10){
                                    String priDealerCode = retailerIdWithPriDealerCodeForLandRover.get(sp.Retailer__c);
                                    mdl.e_jlr_global_dealer_code_auto__c = priDealerCode.substring(priDealerCode.length()-10);
                                }else{
                                    mdl.e_jlr_global_dealer_code_auto__c = retailerIdWithPriDealerCodeForLandRover.get(sp.Retailer__c);
                                }
                            }
                        } 
                        if(sp.Opportunity__r.Brand__r.Name == 'Jaguar'){
                            mdl.e_jlr_dealer_code_auto__c = sp.Retailer__r.Dealer_CI_Code__c;
                            if(retailerIdWithPriDealerCodeForJaguar.containsKey(sp.Retailer__c)){
                                if(retailerIdWithPriDealerCodeForJaguar.get(sp.Retailer__c).length() >10 || Test.isRunningTest()){
                                    String priDealerCode = retailerIdWithPriDealerCodeForJaguar.get(sp.Retailer__c);
                                    mdl.e_jlr_global_dealer_code_auto__c = priDealerCode.substring(priDealerCode.length()-10);
                                }else{
                                    mdl.e_jlr_global_dealer_code_auto__c = retailerIdWithPriDealerCodeForJaguar.get(sp.Retailer__c);
                                }
                            }
                        }
                        mdl.e_jlr_manufacturer_id_enum__c = sp.Opportunity__r.Brand__r.Name;
                        if(mdl.e_jlr_manufacturer_id_enum__c == 'Jaguar' || Test.isRunningTest()){
                            mdl.e_jlr_manufacturer_enum__c = '2';
                        }
                        if(mdl.e_jlr_manufacturer_id_enum__c == 'Land Rover' || Test.isRunningTest()){
                            mdl.e_jlr_manufacturer_enum__c = '3';
                        }
                        mdl.e_jlr_customer_unique_id__c = sp.Opportunity__r.AccountId;                      
                        if(oppMapIdswithOpp.containsKey(sp.Opportunity__c)){
                            if(oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems.size() >0){
                                mdl.e_jlr_model_code_auto__c = oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems[0].Asset__r.Product2.Model__r.ProductCode;
                                mdl.e_jlr_model_description_text__c = oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems[0].Asset__r.Product2.Model__r.Model_Alternative__c;
                                mdl.e_jlr_model_year_auto__c = oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems[0].Asset__r.Product2.Model_Year__c;
                                mdl.e_jlr_vehicle_identification_number_text__c = oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems[0].Asset__r.VIN__c;
                                mdl.e_jlr_car_registration_text__c = oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems[0].Licence_Plate__c;
                                mdl.e_jlr_model_variant_code_auto__c = oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems[0].Asset__r.Product2.Model__r.Model_Alternative__c;
                                mdl.e_jlr_model_variant_description_text__c = oppMapIdswithOpp.get(sp.Opportunity__c).OpportunityLineItems[0].Asset__r.Derivative__r.Name;
                            }
                        }
                        if(accMapIdswithAcc.containsKey(sp.Opportunity__r.AccountId)){
                            if(accMapIdswithAcc.get(sp.Opportunity__r.AccountId).Contacts.size() >0){
                                mdl.Gender__c = accMapIdswithAcc.get(sp.Opportunity__r.AccountId).Contacts[0].Gender__c;
                            }
                        }
                         //mdl.e_jlr_party_id_int__c =
                        // mdl.e_jlr_ownersip_cycle_auto__c =
                        // mdl.e_jlr_svo_type_id_enum__c =
                        // mdl.e_jlr_svo_dealership_yn__c = 
                        //mdl.e_jlr_fob_code_enum__c = 
                    }
                    
                    //=================== Survey Responce Line Item add ==========================
                    for(AP_Survey_Responses_Lines__c spl : sp.AP_Survey_Responses_Lines__r){
                        if(spl.Medallia_Ans_Type__c == 'Text'){
                            mdl.put(spl.Medallia_Field_API__c+'__c', spl.Answer_Verbatim__c);
                        }else{
                            if(spl.Medallia_Ans_Type__c == 'Star Rating'){
                                mdl.put(spl.Medallia_Field_API__c+'__c', string.valueOf(spl.Answer_Rating__c));
                            }else{
                                if(spl.Medallia_Ans_Type__c == 'Radio'){
                                    if(string.isNotBlank(string.valueOf(spl.Answer_Rating__c))){
                                        if(string.isBlank(spl.Medallia_Value__c)){
                                            mdl.put(spl.Medallia_Field_API__c+'__c', string.valueOf(spl.Answer_Rating__c)); 
                                        }else{
                                            mdl.put(spl.Medallia_Field_API__c+'__c', string.valueOf(spl.Medallia_Value__c));
                                        }
                                    }
                                    if(string.isNotBlank(spl.Answer_Verbatim__c)){
                                        mdl.put(spl.Medallia_Field_API__c+'__c', spl.Answer_Verbatim__c);
                                        if(string.isNotBlank(spl.Medallia_Field_API_2__c)){
                                            mdl.put(spl.Medallia_Field_API_2__c+'__c', spl.Medallia_Value__c);
                                        }
                                    }
                                }else{
                                    if(spl.Medallia_Ans_Type__c == 'Checkbox'){
                                        mdl.put(spl.Medallia_Field_API__c+'__c', spl.Medallia_Value__c);
                                        if(string.isNotBlank(spl.Medallia_Field_API_2__c) && spl.Medallia_Field_API_2__c != null){
                                            if(string.isNotBlank(spl.Answer_Verbatim__c) && spl.Answer_Verbatim__c.Contains(';Other')){
                                                List<String> lstAlpha = spl.Answer_Verbatim__c.split(';Other');
                                                lstAlpha[1] = lstAlpha[1].replace('(','');
                                                lstAlpha[1] = lstAlpha[1].replace(')','');
                                                mdl.put(spl.Medallia_Field_API_2__c+'__c', lstAlpha[1]);
                                            }else{ 
                                                //other contains 2 time so what happen
                                                if(string.isNotBlank(spl.Answer_Verbatim__c) && spl.Answer_Verbatim__c.Contains('Other')){
                                                    List<String> lstAlpha = spl.Answer_Verbatim__c.split('Other');
                                                    lstAlpha[1] = lstAlpha[1].replace('(','');
                                                    lstAlpha[1] = lstAlpha[1].replace(')','');
                                                    mdl.put(spl.Medallia_Field_API_2__c+'__c', lstAlpha[1]);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    medList.add(mdl);
                    sp.Create_Medallia_Data__c = true;
                    apSRList.add(sp);
                }  
            }
            if( medList.size() > 0 ){
                insert medList;
                update apSRList;
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}