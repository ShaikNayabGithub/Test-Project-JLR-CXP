global class Batch_MenaFinanceContractInsert implements Schedulable, Database.Batchable<sObject> {
    
    // CXPD-1728 - Set Record Type to Finance
    private Id financeContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Finance').getRecordTypeId();
    
    private Boolean endDateUpdatable = checkFieldUpdatable('EndDate');
    
    private Boolean checkFieldUpdatable(String fieldName) {
        Boolean flag = false;
        Map < String, Schema.SObjectField> contractFieldsMap = Schema.SObjectType.Contract.fields.getMap();
        if(contractFieldsMap != null && contractFieldsMap.get(fieldName) != null) {
            flag = contractFieldsMap.get(fieldName).getDescribe().isUpdateable();
        }
        return flag;
    }    
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_MenaFinanceContractInsert(), 200);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String Qsting = ' SELECT Id, APR__c, Brand__c, CI_Code__c, Customer_Deposit__c, Error_Message__c, Fees_Back_monetary_amt__c, Fees_Front_monetary_amt__c, ';
        Qsting +=' Financed_Amount__c, Financial_Service_Partner__c, FS_Product_Name__c, FS_Promo_Subvention__c, FS_Subvention_Cost__c, GFV_Balloon_RV__c, VIN__c,';
        Qsting +=' Invoice_Price__c, Jaguar_Land_Rover_Model__c, Market__c, Month__c, Monthly_Payment__c, New_Used__c, Nominal_Rate__c, Region__c, Status__c, Term_Tenor__c';
        Qsting +='  FROM Finance_Contract_Import__c WHERE Status__c =\'Unprocessed\'';
        return Database.getQueryLocator(Qsting);
    }
    
    global void execute(Database.BatchableContext BC, List<Finance_Contract_Import__c> FinanceConImpLst) {
        Set<String> VinSet = new Set<String>();
        Map<String,Id> assetVinOppIdMap = New Map<String,Id>();
        Map<String,Asset> assetInfoMap = new Map<String,Asset>();
        Map<String, Finance_Contract_Import__c> uniqueFinConMap = new Map<String, Finance_Contract_Import__c>();
        
        Map<String, String> picklistMap = new Map<String, String>();
        for(Picklist_Name_Source_Target_Map__mdt pickList : [SELECT MasterLabel, Actual_Value__c FROM Picklist_Name_Source_Target_Map__mdt]){
            picklistMap.put(pickList.MasterLabel, pickList.Actual_Value__c);
        }
        System.debug(picklistMap.keyset());
        // Map<String,aop_NationalityToISOCode__c> countryNameCodeMap = aop_NationalityToISOCode__c.getAll();
        
        //CXPD-1655
        for(Finance_Contract_Import__c finContract: FinanceConImpLst){
            if(!uniqueFinConMap.containsKey(finContract.VIN__c)){
                uniqueFinConMap.put(finContract.VIN__c, finContract);
                finContract.Status__c = 'Success';
            } else {
                finContract.Status__c = 'Failed';
                finContract.Error_Message__c = 'Duplicate Value';
            }
        }
        List<Finance_Contract_Import__c> uniqueFinConList = new List<Finance_Contract_Import__c>(uniqueFinConMap.values());
        
        for(Finance_Contract_Import__c FCI: uniqueFinConList) {
            VinSet.add(FCI.VIN__c);
            FCI.Status__c = 'Success';
        }
        
        for(Asset objAsset :[SELECT Id, Brand__c, Model__c, VIN__c, CurrencyIsoCode, Model_Alternative__c, AccountId, Country_ISO_Code__c, Account.ownerId, 
                             (SELECT Id FROM Contracts__r WHERE Contract_Status__c = 'Live Contract' limit 1) 
                             FROM Asset 
                             WHERE VIN__c IN :VinSet]) {
                                 assetInfoMap.put(objAsset.Vin__c, objAsset); 
                             }
        
        for(opportunityLineItem oli:[SELECT Id, opportunityId, Asset__c,  Asset__r.Vin__c, currencyIsoCode FROM opportunityLineItem WHERE Asset__r.Vin__c IN: VinSet ]) {
            assetVinOppIdMap.put(oli.Asset__r.Vin__c, oli.opportunityId);
        }
        
        //CXPD-1638
        List<MENA_Countries_Currency_Code__mdt> currencyCodeLst = [SELECT Label, Country_ISO_Code__c, Currency_ISO_Code__c FROM MENA_Countries_Currency_Code__mdt];
        Map<String, String> labelCurrencyMap = new Map<String, String>();
        Map<String, String> countryCodeCurrencyMap = new Map<String, String>();
        for(MENA_Countries_Currency_Code__mdt currencyCode: currencyCodeLst) {
            labelCurrencyMap.put(currencyCode.Label, currencyCode.Currency_ISO_Code__c);
            countryCodeCurrencyMap.put(currencyCode.Country_ISO_Code__c, currencyCode.Currency_ISO_Code__c);
        }
        
        // Create Contract List which needs to created.
        List<Contract> contractLstForInsert = New List<Contract>();
        
        for(Finance_Contract_Import__c objContract: uniqueFinConList) {
            System.debug(objContract.FS_Product_Name__c);
            if(!assetInfoMap.isEmpty() && assetInfoMap.containsKey(objContract.Vin__c)) {
                if(assetInfoMap.get(objContract.Vin__c).Contracts__r.size() > 0) {
                    objContract.Error_Message__c = 'Already Active Contract Exists.';
                    objContract.Status__c = 'Failed';
                } 
                else {
                    Asset objAsset = assetInfoMap.get(objContract.Vin__c);
                    Contract newContract = New Contract();
                    
                    if(objContract.Month__c != null && String.isNotBlank(objContract.Month__c) && objContract.Month__c.length() == 6) {
                        newContract.StartDate = Date.newInstance(Integer.valueOf(objContract.Month__c.subString(0,4)), Integer.valueOf(objContract.Month__c.subString(4,6)), 1);
                    }
                    if(objContract.Term_Tenor__c != 0) {
                        newContract.ContractTerm = Integer.valueOf(objContract.Term_Tenor__c);
                    }
                    // CXPD-1728 - Set Finance Record Type and Populate End Date
                    if(endDateUpdatable && newContract.StartDate != null && newContract.ContractTerm != null && newContract.ContractTerm > 0) {
                        newContract.EndDate = newContract.StartDate.addMonths(newContract.ContractTerm).addDays(-1);
                    }  
                    newContract.RecordTypeId = financeContractRecordTypeId;
                    
                    // CXPD-1638
                    if(labelCurrencyMap.containsKey(objContract.Market__c) ) {
                        newContract.CurrencyIsoCode = labelCurrencyMap.get(objContract.Market__c);
                    } 
                    else if(countryCodeCurrencyMap.containsKey(objContract.Market__c)){
                        newContract.CurrencyIsoCode = countryCodeCurrencyMap.get(objContract.Market__c);
                    }
                    
                    newContract.Brand__c = objAsset.Brand__c;
                    newContract.Model__c = objAsset.Model__c;
                    newContract.Model_Alternative__c = objAsset.Model_Alternative__c;
                    /*if(countryNameCodeMap.containsKey(objContract.Market__c))
newContract.Country_ISO_Code__c = countryNameCodeMap.get(objContract.Market__c).aop_ISO_Code__c;
*/
                    
                    if(objContract.FS_Product_Name__c != null && String.isNotBlank(objContract.FS_Product_Name__c) ) {
                        if(picklistMap.containsKey(objContract.FS_Product_Name__c))
                            newContract.Product_Type__c = picklistMap.get(objContract.FS_Product_Name__c);
                        else
                            newContract.Product_Type__c = objContract.FS_Product_Name__c;
                    }
                    
                    if(!assetVinOppIdMap.isEmpty() && assetVinOppIdMap.containsKey(objContract.Vin__c))
                        newContract.Opportunity__c = assetVinOppIdMap.get(objContract.Vin__c);
                    
                    newContract.OwnerId = objAsset.Account.OwnerId;
                    newContract.Country_ISO_Code__c = objAsset.Country_ISO_Code__c;
                    newContract.Contract_Status__c = 'Live Contract';
                    newContract.AccountId = objAsset.AccountId;
                    newContract.APR__c = objContract.APR__c;
                    newContract.Market__c = objContract.Region__c;
                    newContract.Finance_Partner__c = objContract.Financial_Service_Partner__c;
                    newContract.Finance_Partner_Dealer_Code__c = objContract.CI_Code__c;
                    newContract.Vehicle_Type__c = objContract.New_Used__c;
                    newContract.JLR_Subvention__c = objContract.FS_Promo_Subvention__c;
                    newContract.Amount_Financed__c = objContract.Financed_Amount__c;
                    newContract.Asset__c = objAsset.Id;
                    newContract.GMFV_Balloon__c = objContract.GFV_Balloon_RV__c;
                    newContract.Invoice_Price__c = objContract.Invoice_Price__c;
                    newContract.Deposit__c = objContract.Customer_Deposit__c;
                    // newContract.CurrencyIsoCode = objAsset.CurrencyIsoCode;
                    newContract.Subvention_Value__c = objContract.FS_Subvention_Cost__c;
                    newContract.Amount_Paid__c = objContract.Fees_Front_monetary_amt__c;
                    newContract.Amount_Paid_at_the_End_of_Term__c = objContract.Fees_Back_monetary_amt__c;
                    newContract.Instalment_Amount__c = objContract.Monthly_Payment__c;
                    newContract.Interest_Rate_Annual__c = objContract.Nominal_Rate__c;
                    
                    contractLstForInsert.add(newContract);
                }
            } else {
                objContract.Error_Message__c = 'Vin details not found.';
                objContract.Status__C = 'Failed';
            }
        }
        
        if(!contractLstForInsert.isEmpty()) {
            //Database.SaveResult[] saveResultList = database.insert(contractLstForInsert, false);
            insert contractLstForInsert;
                        
            // Iterate through saveResultList based on isSuccess capture the failed records
            /*for (Integer i=0; i<saveResultList.size(); i++) {
if (!saveResultList[i].isSuccess()) {
// Operation was successful, so get the ID of the record that was processed
System.debug('Error. Account ID: ' + contractLstForInsert[i].Asset__c);
}
}*/
        }
        update FinanceConImpLst;
    }
    
    global void finish(Database.BatchableContext BC) { }
}