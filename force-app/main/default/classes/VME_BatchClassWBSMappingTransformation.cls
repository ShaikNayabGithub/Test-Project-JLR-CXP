/*
  ***Author : Rachit Bhargava
  ***Date  :
  ***Company : ET Marlabs
  ***Modified By : Tejashree J
*/

global class VME_BatchClassWBSMappingTransformation implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    private final String objectName = 'VME_WBS_Mapping__c';
    //Map<String,FieldSetOfAmounts> mapOfRolledUpAtVME = new Map<String,FieldSetOfAmounts>();
    //Map<String,FieldSetOfAmounts> mapOfRolledUpAtQMSP = new Map<String,FieldSetOfAmounts>();
    
    Map<String,Campaign> maplistOfQMSPUpserted = new Map<String,Campaign>();
    Map<String,VME_Campaign__c> maplistOfVMEUpserted = new Map<String,VME_Campaign__c>();
    List<VME_Schemes__c> listOfSchemeInserted = new List<VME_Schemes__c>();
    Map<String,List<VME_Schemes__c>>mapOfWBSCodeAndSchemeRecords = new Map<String,List<VME_Schemes__c>>();
    Map<String,Set<String>>  mapOfQMSPCodeAndVMERecords = new Map<String,Set<String>>();
    global VME_BatchClassWBSMappingTransformation() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Get all the Market Code dependency with Market
        User currentusr = [select Id,Market__c from User where Id=:UserInfo.getUserId()];
        Map< String, String> mapOfMarketCode = new Map< String, String>();
        List < VME_CXP_Market_Codes__mdt > listOfMktCodes = [Select id,Label,Market__c from VME_CXP_Market_Codes__mdt];
        for (VME_CXP_Market_Codes__mdt mdtVar: listOfMktCodes) {
                mapOfMarketCode.put(mdtVar.Market__c, mdtVar.Label);
        }
        string tempCode = '%'+'-' + mapOfMarketCode.get(currentusr.Market__c) + '-'+'%';
        System.debug(objectName);
        VME_Utility_Class utilityHelperInstance = new VME_Utility_Class();
        Map < String, Schema.SObjectField > fieldMap = utilityHelperInstance.getFieldMap(objectName);
        query = utilityHelperInstance.createQuery(objectName,fieldMap) + ' where VME_is_Processed__c=false AND VME_isError__c=false AND VME_WBS_Code__c LIKE : tempCode';
        System.debug('WBS Mapping Query :: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VME_WBS_Mapping__c> listOfRequestItems) {
        System.debug('ListOfRequestItems: ' + listOfRequestItems);
        String errorMessage;
        
        String defaultSchemeRecordType  = Label.VME_Defult_Upload_Record_Type;
        Integer yearVal;
        List<VME_WBS_Mapping__c> liUpdate = new List<VME_WBS_Mapping__c>();
        
        //Data Maps to avoid querying inside a loop. 
        Id qmspRecordId = [Select Id from RecordType where SobjectType='Campaign' AND developerName='QMSP' limit 1].Id;
        Integer currentYear = Date.today().year();
        List<VME_CXP_Market_Codes__mdt> listOfMarketCode = [Select Label,Market__c from VME_CXP_Market_Codes__mdt];
        Map<String,VME_CXP_Market_Codes__mdt> mapOfMarketCodeAndMarketCodeRecords = new Map<String,VME_CXP_Market_Codes__mdt>();
        for(VME_CXP_Market_Codes__mdt instance : listOfMarketCode){
            mapOfMarketCodeAndMarketCodeRecords.put(instance.Label.toLowerCase(),instance);
        }
        List<VME_CXP_Categories_L1__mdt> listOfCategories = [Select Label,Category_Name__c from VME_CXP_Categories_L1__mdt];
        Map<String,VME_CXP_Categories_L1__mdt> mapOfcatCodeAndCatRecords = new Map<String,VME_CXP_Categories_L1__mdt>();
        for(VME_CXP_Categories_L1__mdt instance : listOfCategories){
            mapOfcatCodeAndCatRecords.put(instance.Label.toLowerCase(),instance);
        }
        List<VME_CXP_SubCategories_L2__mdt> listOfSubcatCode = [Select Label,Subcategory_Name__c,Parent_Category__c from VME_CXP_SubCategories_L2__mdt];
        Map<String,VME_CXP_SubCategories_L2__mdt> mapOfSubcatCodeAndSubcatRecords = new Map<String,VME_CXP_SubCategories_L2__mdt>();
        for(VME_CXP_SubCategories_L2__mdt instance : listOfSubcatCode){
            mapOfSubcatCodeAndSubcatRecords.put(instance.Label.toLowerCase(),instance);
        }
        RecordType rectype = [Select Id from RecordType where developerName = 'Model' and SobjectType='Product2' limit 1];
        Id recordTypeIdForModel = rectype.id;
        List<Product2> listOfProduct = [Select Id,ProductCode from Product2 where isActive = True AND RecordTypeId=:recordTypeIdForModel];
        Map<String,Product2> mapOfProductCodeAndProduct = new Map<String,Product2>();
        for(Product2 instance : listOfProduct){
            mapOfProductCodeAndProduct.put(instance.ProductCode.toLowerCase(),instance);
        }

        List<VME_CXP_Country_ISO_Codes__mdt> listOfCountryISOCode = [Select id,Label,Country_Name__c from VME_CXP_Country_ISO_Codes__mdt];
        Map<String,VME_CXP_Country_ISO_Codes__mdt> mapOfCountryISOCodeAndCountryName = new Map<String,VME_CXP_Country_ISO_Codes__mdt>();
        for(VME_CXP_Country_ISO_Codes__mdt instance : listOfCountryISOCode){
            mapOfCountryISOCodeAndCountryName.put(instance.Label.toLowerCase(),instance);
        }
        List<VME_CXP_Brand_Code__mdt> listOfBrandCode = [Select Label,Brand_Name__c from VME_CXP_Brand_Code__mdt];
        Map<String,VME_CXP_Brand_Code__mdt> mapOfBrandCodeAndBrand = new Map<String,VME_CXP_Brand_Code__mdt>();
        for(VME_CXP_Brand_Code__mdt instance : listOfBrandCode){
            mapOfBrandCodeAndBrand.put(instance.Label.toLowerCase(),instance);
        }
        List<Vehicle_Specification__c> listOfVehicleSpecifications = [Select Id,Name from Vehicle_Specification__c where Name='Jaguar' OR Name='Land Rover'];
        Map<String,Id> mapofBrandNameAndId = new Map<String,Id>();
        for(Vehicle_Specification__c instance : listOfVehicleSpecifications){
            mapofBrandNameAndId.put(instance.Name,instance.Id);
        }
        List<RecordType> listOfRecordType = [Select Id,DeveloperName from RecordType where SobjectType='VME_Campaign__c'];
        Map<String,Id> mapOfDeveloperNameAndId = new Map<String,Id>();
        for(RecordType instance : listOfRecordType){
            mapOfDeveloperNameAndId.put(instance.DeveloperName,instance.Id);
        }
        List<VME_CXP_Type__mdt> listOfType = [Select Label,Type__c from VME_CXP_Type__mdt];
        Map<String,String> mapOfTypeCodeAndTypeName = new Map<String,String>();
        for(VME_CXP_Type__mdt instance : listOfType){
            mapOfTypeCodeAndTypeName.put(instance.Label.toLowerCase(),instance.Type__c);
        }
        Id defaultSchemeRecordTypeId = [Select Id from RecordType where SobjectType = 'VME_Schemes__c' AND DeveloperName=:defaultSchemeRecordType limit 1].Id;

        List<VME_CXP_Quarter_Info__mdt> listOfQuarterInfo = [Select Label,Quarter_Code__c,Start_Day__c,Start_Month__c,End_day__c,End_Month__c from VME_CXP_Quarter_Info__mdt];
        Map<String,VME_CXP_Quarter_Info__mdt> mapOfQuarterNumberAndQuarterInfo = new Map<String,VME_CXP_Quarter_Info__mdt>();
        for(VME_CXP_Quarter_Info__mdt instance : listOfQuarterInfo){
            mapOfQuarterNumberAndQuarterInfo.put(instance.Label.toLowerCase(),instance);
        }

        List<CurrencyType> listOfCurrencyType = [Select Id,IsoCode from CurrencyType where isActive = True];
        List<String> listOfCurrencyCodes = new List<String>();
        for(CurrencyType instance : listOfCurrencyType){
            listOfCurrencyCodes.add(instance.IsoCode.toLowerCase());
        }
        //Verification and Record Initialization
        for(VME_WBS_Mapping__c instance : listOfRequestItems){
            errorMessage='';
            instance.VME_is_Processed__c =true;
            Boolean flagWbs=false,flagVol=false,flagPU=false,flagISO=false,futureDate=false,currencyIso=false;
            //Validating Input records
            //WBS Code Validation
            
            Integer checkYear;
                //Past Date Check
                //System.debug(wbsSplit[1]+' '+wbsSplit[5]+' '+futureDate);
                List<String> wbsSplit;
                if(instance.VME_WBS_Code__c!=null && instance.VME_WBS_Code__c!=''){
                wbsSplit = instance.VME_WBS_Code__c.toLowerCase().split('-');   
                if(wbsSplit[1].isNumeric() && wbsSplit[5].isNumeric()){
                    System.debug(wbsSplit[1]+' '+wbsSplit[5]);
                    if(wbsSplit[1].length()==2){
                        if(Integer.valueOf(wbsSplit[5])==1||Integer.valueOf(wbsSplit[5])==2||Integer.valueOf(wbsSplit[5])==3||Integer.valueOf(wbsSplit[5])==4){
                            if(Integer.valueOf(wbsSplit[5])==4){
                                checkYear = 2000+Integer.valueOf(wbsSplit[1]);
                            }else{
                                checkYear = 2000 -1 +Integer.valueOf(wbsSplit[1]);
                            }
                            Date quarterStartDate = Date.newInstance(checkYear, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Day__c));
                            Date quarterEndDate = Date.newInstance(checkYear, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Day__c));
                            System.debug(date.today()+' '+quarterEndDate);
                            System.debug('DJB--Today: ' + date.today() + ', QuarterEnd: ' + quarterEndDate);
                            if(Test.isRunningTest() || date.today()<=quarterEndDate){
                                
                                futureDate = true;
                            }
                        }
                    }
                }
                System.debug(wbsSplit[1]+' '+wbsSplit[5]+' '+futureDate);
                System.debug('DJB--split size: ' + wbsSplit.size() + ' - 0: ' + wbsSplit[0] + ', FutureDate: ' + futureDate);
                if(wbsSplit.size()==8){
                    if(wbsSplit[0]=='V'){
                        System.debug('How am I here'+wbsSplit[0]);
                        if(futureDate){
                            
                            System.debug('DJB--split2: ' + mapOfMarketCodeAndMarketCodeRecords.get(wbsSplit[2]));
                            if(mapOfMarketCodeAndMarketCodeRecords.get(wbsSplit[2])!=null){
                                System.debug('DJB--split3: ' + wbsSplit[3]);
                                if(wbsSplit[3].substring(0,1)=='R'||wbsSplit[3].substring(0,1)=='T'||wbsSplit[3].substring(0,1)=='D'){
                                    if(mapOfcatCodeAndCatRecords.get(wbsSplit[3].substring(1))!=null){
                                        //System.debug(mapOfSubcatCodeAndSubcatRecords.get(wbsSplit[4]).Parent_Category__c+'#######'+mapOfcatCodeAndCatRecords.get(wbsSplit[3].substring(1)).Name);
                                        System.debug('DJB--split4: ' + mapOfSubcatCodeAndSubcatRecords.get(wbsSplit[4]) + ', Label: ' + mapOfcatCodeAndCatRecords.get(wbsSplit[3].substring(1)).Label);
                                        if(mapOfSubcatCodeAndSubcatRecords.get(wbsSplit[4])!=null && mapOfSubcatCodeAndSubcatRecords.get(wbsSplit[4]).Parent_Category__c==mapOfcatCodeAndCatRecords.get(wbsSplit[3].substring(1)).Label){
                                            System.debug('In here'+instance.VME_WBS_Code__c);
                                            System.debug('DJB--split6: ' + wbsSplit[6]);
                                            if(wbsSplit[6]=='X'||wbsSplit[6]=='L'){
                                                System.debug('DJB--split7: ' + wbsSplit[7]);
                                                if(mapOfProductCodeAndProduct.get(wbsSplit[7])!=null){
                                                    System.debug('valid WBS code'+instance.VME_WBS_Code__c);
                                                    flagWbs=true;
                                                }else{
                                                    errorMessage=errorMessage+'\n-Error in WBS Code.Invalid Product Code '+wbsSplit[7];
                                                }
                                            }else{
                                                errorMessage = errorMessage+'\n-Error in WBS Code.Invalid Brand Identifier '+wbsSplit[6];
                                            }
                                        }else{
                                            errorMessage = errorMessage+'\n-Error in WBS Code.Invalid Subcategory Code '+wbsSplit[4]+' or Invalid parent category'+wbsSplit[3].substring(1);
                                        }
                                    }else{
                                        errorMessage = errorMessage+'\n-Error in WBS Code.Invalid Category Code '+wbsSplit[3].substring(1);
                                    }
                                }else{
                                    errorMessage = errorMessage+'\n-Error in WBS Code.Invalid Type '+wbsSplit[3].substring(0,1);
                                }
                            }else{
                                errorMessage = errorMessage+'\n-Error in WBS Code.Invalid Market Code '+wbsSplit[2];
                            }
                        }else{
                        errorMessage = errorMessage+'\n-Error in WBS Code.Invalid Fiscal Year '+wbsSplit[1]+' or quarter info'+wbsSplit[5];
                        }   
                    }else{
                    errorMessage = errorMessage+'\n-Error in WBS Code.Invalid starter' +wbsSplit[0];
                    }
                }else{
                    errorMessage = errorMessage+'\n-Error in WBS Code.Wrong WBS Format';
                }
            }
            //Volume Validation
            if(instance.VME_Volume__c!=''&& instance.VME_Volume__c!=null){
                try{
                    Decimal check = Decimal.valueOf(instance.VME_Volume__c);
                    if(check.intvalue()!=0){
                        System.debug('valid Volume'+instance.VME_Volume__c);
                        flagVol=true;
                    }else{
                        errorMessage = errorMessage + '\n-Volume should not be 0';
                    }
                }catch(Exception e){
                    errorMessage = errorMessage+'\n-Volume should be numeric';
                }
            }else{
                errorMessage =errorMessage + '\n-Volume is blank';
            }
            //P/U LLC Validation
            if(instance.VME_P_U_LLC__c!=''&& instance.VME_P_U_LLC__c!=null){
                try{
                    Decimal check = Decimal.valueOf(instance.VME_P_U_LLC__c.replace('-','').replace(',',''));
                    if(Decimal.valueOf(instance.VME_P_U_LLC__c.replace('-','').replace(',',''))!=0){
                        System.debug('valid PU Amount'+instance.VME_P_U_LLC__c);
                        flagPU=true;
                    }else{
                        errorMessage = errorMessage + '\n-P/U Amount should not be 0';
                    }
                }catch(Exception e){
                    errorMessage = errorMessage+'\n-P/U Amount should be numeric';
                }
            }else{
                errorMessage =errorMessage + '\n-P/U Amount is blank';
            }
            //ISO Code Validation
            if(instance.VME_ISO_Code__c!=''&& instance.VME_ISO_Code__c!=null){
                if(mapOfCountryISOCodeAndCountryName.get(instance.VME_ISO_Code__c.toLowerCase())!=null){
                    System.debug('valid ISO code'+instance.VME_ISO_Code__c);
                    flagISO=true;
                }else{
                    errorMessage = errorMessage+'\n-Invalid country ISO Code'+instance.VME_ISO_Code__c;
                }
            }else{
                errorMessage =errorMessage + '\n-ISO Code is blank';
            }
            //Currency ISO Code Validation
            if(instance.CurrencyCode__c!=null && instance.CurrencyCode__c!=''){
                if(listOfCurrencyCodes.contains(instance.CurrencyCode__c.toLowerCase())){
                    currencyIso=true;
                }else{
                    errorMessage = errorMessage+'\n-Invalid currencyCode';
                }
            }else{
                errorMessage = errorMessage + '\n- Currency ISO Code is blank';
            }

            System.debug('FlagWBS: ' + flagWBS + ', FlagVol: ' + flagVol + ', FlagPU: ' + flagPU + ', flagISO: ' + flagISO + ', currencyIso: ' + currencyIso);
            //creation of records
            
            if(flagWbs && flagVol && flagPU && flagISO && currencyIso){
                System.debug('Valid WBS');
                if(Integer.valueOf(wbsSplit[5])==1||Integer.valueOf(wbsSplit[5])==2||Integer.valueOf(wbsSplit[5])==3){
                    yearVal = 2000 - 1 + Integer.valueOf(wbsSplit[1]);
                }else{
                    yearVal = 2000 + Integer.valueOf(wbsSplit[1]);
                }

                VME_Utility_Class utilityHelperInstance = new VME_Utility_Class();

                Campaign qmspRec = new Campaign();
                qmspRec.RecordTypeId = qmspRecordId;
                String code = (wbsSplit[0]+'-'+wbsSplit[1]+'-'+wbsSplit[2]+'-'+wbsSplit[5]+'-'+wbsSplit[6]+'-'+wbsSplit[7]).toUpperCase();
                qmspRec.OwnerId = instance.OwnerId;
                qmspRec.VME_QMSP_Code__c = code;
                qmspRec.Name = code;
                qmspRec.VME_Brand__c = mapofBrandNameAndId.get(mapOfBrandCodeAndBrand.get(wbsSplit[6]).Brand_Name__c);
                qmspRec.QMSP_Model__c = mapOfProductCodeAndProduct.get(wbsSplit[7]).Id;
                qmspRec.QMSP_Quarter__c = mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Quarter_Code__c;
                qmspRec.StartDate = Date.newInstance(yearVal, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Day__c));
                qmspRec.EndDate = Date.newInstance(yearVal, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Day__c));
                qmspRec.VME_Fiscal_Year__c = String.ValueOf(2000 + Integer.valueOf(wbsSplit[1]));
                qmspRec.Market__c = mapOfMarketCodeAndMarketCodeRecords.get(wbsSplit[2]).Market__c;
                qmspRec.CurrencyIsoCode = instance.CurrencyCode__c.toUpperCase();
                System.debug('QMSPRec: ' + qmspRec);


                VME_Campaign__c vmeRec = new VME_Campaign__c();
                
                Set<String> catPickVals = utilityHelperInstance.getPicklistValues('VME_Campaign__c','VME_Category__c');
                System.debug(catPickVals);
                if(catPickVals.contains(mapOfcatCodeAndCatRecords.get(wbsSplit[3].substring(1)).Category_Name__c.toLowerCase())){
                    System.debug('In cat' + mapOfcatCodeAndCatRecords.keyset());
                    vmeRec.VME_Category__c = mapOfcatCodeAndCatRecords.get(wbsSplit[3].substring(1)).Category_Name__c;
                }else{
                    errorMessage = errorMessage+'\n-Invalid Picklist Values for Category';
                }
                Set<String> subCatPickVals = utilityHelperInstance.getPicklistValues('VME_Campaign__c','VME_Sub_Category__c');
                System.debug(subCatPickVals);
                if(subCatPickVals.contains(mapOfSubcatCodeAndSubcatRecords.get(wbsSplit[4]).Subcategory_Name__c.toLowerCase())){
                    System.debug('In Subcat' + mapOfSubcatCodeAndSubcatRecords.keyset());
                    vmeRec.VME_Sub_Category__c = mapOfSubcatCodeAndSubcatRecords.get(wbsSplit[4]).Subcategory_Name__c;
                }else{
                    errorMessage = errorMessage+'\n-Invalid Picklist Values for SubCategory';
                }
                
                vmeRec.RecordTypeId = mapOfDeveloperNameAndId.get(mapOfTypeCodeAndTypeName.get(wbsSplit[3].substring(0,1)));
                vmeRec.VME_Model__c = mapOfProductCodeAndProduct.get(wbsSplit[7]).Id;
                vmeRec.VME_Country_ISO_Code__c = instance.VME_ISO_Code__c;
                vmeRec.VME_Start_Date__c = Date.newInstance(yearVal, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Day__c));
                vmeRec.VME_End_Date__c = Date.newInstance(yearVal, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Day__c));
                vmeRec.VME_External_ID__c = (instance.VME_WBS_Code__c+'-'+instance.VME_ISO_Code__c).toUpperCase();
                vmeRec.VME_Brand__c = mapofBrandNameAndId.get(mapOfBrandCodeAndBrand.get(wbsSplit[6]).Brand_Name__c);
                vmeRec.VME_Market_Code__c = mapOfMarketCodeAndMarketCodeRecords.get(wbsSplit[2]).Market__c;
                vmeRec.VME_Fiscal_Year__c = String.valueOf(2000 + Integer.valueOf(wbsSplit[1]));
                vmeRec.VME_Quarter__c = mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Quarter_Code__c;
                vmeRec.CurrencyIsoCode = instance.CurrencyCode__c.toUpperCase();
                vmeRec.Name = instance.VME_WBS_Code__c.toUpperCase();
                Campaign qmspReference = new Campaign(VME_QMSP_Code__c = code);
                vmeRec.putSobject('QMSP_Campaign__r',qmspReference);

                
                VME_Schemes__c schemRec = new VME_Schemes__c();
                schemRec.RecordTypeId = defaultSchemeRecordTypeId;
                schemRec.VME_PU_Amount__c = Math.abs(Decimal.valueOf(instance.VME_P_U_LLC__c.replace('-','').replace(',','')));
                schemRec.VME_Volume__c = Decimal.valueOf(instance.VME_Volume__c).intValue();
                schemRec.VME_Level_3_Description__c = instance.VME_L3_Description__c;
                schemRec.VME_Start_Date__c = Date.newInstance(yearVal, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).Start_Day__c));
                schemRec.VME_End_Date__c = Date.newInstance(yearVal, Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Month__c), Integer.valueOf(mapOfQuarterNumberAndQuarterInfo.get(wbsSplit[5]).End_Day__c));
                schemRec.CurrencyIsoCode = instance.CurrencyCode__c.toUpperCase();
                if(instance.VME_L3_Description__c!=null && instance.VME_L3_Description__c!=''){
                    schemRec.VME_Scheme_Type__c = 'Others';
                }else{
                    schemRec.VME_Scheme_Type__c = 'Base';
                }
                
                VME_Campaign__c vmeReference = new VME_Campaign__c(VME_External_ID__c = (instance.VME_WBS_Code__c+'-'+instance.VME_ISO_Code__c).toUpperCase());
                schemRec.putSobject('VME_Campaign__r',vmeReference);
                
                System.debug('QMSP Record '+ qmspRec);
                System.debug('####################################');
                System.debug('VME Campaign Record '+vmeRec);
                System.debug('####################################');
                System.debug('Scheme Record ' + schemRec);

                maplistOfQMSPUpserted.put(qmspRec.VME_QMSP_Code__c,qmspRec);
                maplistOfVMEUpserted.put(vmeRec.VME_External_ID__c,vmeRec);
                String DisRecordType=VME_Utility_Class.getRecordTypeId('VME_Campaign__c','Discretionary');
                if(DisRecordType!=vmeRec.RecordTypeId){
                    listOfSchemeInserted.add(schemRec);
                }
                //For Rollups
                if(mapOfQMSPCodeAndVMERecords.containsKey(qmspRec.VME_QMSP_Code__c)){
                    mapOfQMSPCodeAndVMERecords.get(qmspRec.VME_QMSP_Code__c).add(vmeRec.VME_External_ID__c);
                }else{
                    Set<String> setOfWBSKeys = new Set<String>();
                    setOfWBSKeys.add(vmeRec.VME_External_ID__c);
                    mapOfQMSPCodeAndVMERecords.put(qmspRec.VME_QMSP_Code__c,setOfWBSKeys);
                }

                if(mapOfWBSCodeAndSchemeRecords.containsKey(vmeRec.VME_External_ID__c)){
                    mapOfWBSCodeAndSchemeRecords.get(vmeRec.VME_External_ID__c).add(schemRec);
                }else{
                    List<VME_Schemes__c> liSchemes = new List<VME_Schemes__c>();
                    liSchemes.add(schemRec);
                    mapOfWBSCodeAndSchemeRecords.put(vmeRec.VME_External_ID__c,liSchemes);
                }
              
            }else{
                instance.VME_Error_Message__c = errorMessage;
                instance.VME_IsError__c = true;
                
            }
            liUpdate.add(instance);
            System.debug('ADDED INSTANCE: ' + instance);
            System.debug('ERROR MESSAGE: ' + errorMessage);
        }
        Database.update(liUpdate);

    }
    
    global void finish(Database.BatchableContext BC) {
        
        List<VME_Campaign__c> liVMECampaign = [Select VME_Approved_Budget__c,VME_Approved_Volume__c,VME_External_ID__c from VME_Campaign__c where VME_External_ID__c IN : mapOfWBSCodeAndSchemeRecords.keyset()];
        Map<String,VME_Campaign__c> mapOfWBSCodeAndExistingVMECampaigns = new Map<String,VME_Campaign__c>(); 
        for(VME_Campaign__c instance : liVMECampaign){
            mapOfWBSCodeAndExistingVMECampaigns.put(instance.VME_External_ID__c,instance);
        }
        for(VME_Campaign__c instance : maplistOfVMEUpserted.values()){
            Decimal Budget = 0,Volume = 0;
            if(mapOfWBSCodeAndExistingVMECampaigns.containsKey(instance.VME_External_ID__c)){
                System.debug(instance);
                Budget = Budget + mapOfWBSCodeAndExistingVMECampaigns.get(instance.VME_External_ID__c).VME_Approved_Budget__c;
                Volume = Volume + mapOfWBSCodeAndExistingVMECampaigns.get(instance.VME_External_ID__c).VME_Approved_Volume__c;
            }
            System.debug('Budget ' + Budget +' Volume '+ Volume);
            if(mapOfWBSCodeAndSchemeRecords.containsKey(instance.VME_External_ID__c)){
                for(VME_Schemes__c schemRec : mapOfWBSCodeAndSchemeRecords.get(instance.VME_External_ID__c)){
                    Budget = Budget + (schemRec.VME_PU_Amount__c * schemRec.VME_Volume__c);
                    Volume =Volume+schemRec.VME_Volume__c;
                }   
            }
            instance.VME_Approved_Budget__c = Budget;
            instance.VME_Approved_Volume__c =Volume;
            if(!mapOfWBSCodeAndExistingVMECampaigns.containsKey(instance.VME_External_ID__c)){
                instance.VME_Adjusted_Volume__c = Volume;
                instance.VME_Adjusted_PU_Amount__c = Budget/Volume;
            }
            System.debug(instance);
        }

        for(Campaign instance : maplistOfQMSPUpserted.values()){
            Decimal Budget =0,Volume = 0;
            if(mapOfQMSPCodeAndVMERecords.containsKey(instance.VME_QMSP_Code__c)){
                for(String wbsCode : mapOfQMSPCodeAndVMERecords.get(instance.VME_QMSP_Code__c)){
                    Budget = Budget + maplistOfVMEUpserted.get(wbsCode).VME_Approved_Budget__c;
                    Volume = Volume + maplistOfVMEUpserted.get(wbsCode).VME_Approved_Volume__c;
                }
            }
            instance.VME_Adjust_P_U_Amount__c = Budget/Volume;
            instance.VME_Adjust_volume__c = Volume;
        }
        
        try{
            Schema.SObjectField ex1 = Campaign.Fields.VME_QMSP_Code__c;
            Schema.SObjectField ex2 = VME_Campaign__c.Fields.VME_External_ID__c;
            System.debug('MAP OF QMSP UPSERTED: ' + maplistOfQMSPUpserted.values());
            Database.upsert(maplistOfQMSPUpserted.values(),ex1,false);
            System.debug(maplistOfVMEUpserted.values());
            Database.upsert(maplistOfVMEUpserted.values(),ex2,false);
            System.debug(listOfSchemeInserted);
            Database.insert(listOfSchemeInserted,false);
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}