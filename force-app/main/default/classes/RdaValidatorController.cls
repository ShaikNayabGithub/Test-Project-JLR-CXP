public without sharing class RdaValidatorController {
    
    public static Id onSellRDARecordtype = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    public static Id newRetailerRDARecordtype = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    public static Id tradeInRDARecordtype = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Trade_In').getRecordTypeId();
    public static Id doRecordtype = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Dealer_Owned').getRecordTypeId();
    public static string onSellRDA = 'On_Sell';
    public static string newRetailerRDA = 'New_Retail';
    public static string tradeInRDA = 'Trade_In';
    
    @AuraEnabled(Cacheable = true)
    public static RdaValidatorWrapper validateRDA(String oppId) {
        
        String RDA_TYPE = 'Not able to find RDA Type';
        Integer j = 0;
        Opportunity opp; 
        Boolean checkExistingRDA = false;
        Boolean tradeIn;
        Boolean checkAccountType = true;
        Boolean rdaAlreadyExists = false;
        OpportunityLineItem oppLineItem; 
        List<ValidationResult> results = new  List<ValidationResult>();
        List<RDA__c> existingRDA;
        List<RDA__c> existingAssetRDA = new List<RDA__c>();
        List<RDA__c> existingOppRDA = new List<RDA__c>();//SELECT Id, Recordtypeid FROM RDAs__r WHERE Submitted_Status__c != 'Cancelled'
        List<OpportunityLineItem> oppLineItems;
        List<Defined_values_for_RDA_type__mdt > cutomMetadaTypes; 
        //retrieve op
        List<Opportunity> oppRetrieved = [SELECT Id, StageName, Sale_Type__c, Account.RecordtypeId, Account.isPersonAccount, AccountId, (SELECT Id, asset__c,asset__r.Traded_In__c,asset__r.Sale_Type_Code__c,asset__r.Common_Sale_Type__c,asset__r.Vista_Status__c   FROM OpportunityLineItems WHERE asset__c != null) FROM Opportunity WHERE Id =:oppID];
        if(oppRetrieved != null && oppRetrieved.size() == 1 ){
            opp = oppRetrieved[0];
            //SET TYPE
            if( opp.Sale_Type__c == null){
                system.debug('Wrong opp');
                ValidationResult   resultf = new ValidationResult(False,'Opportunity needs to have sale type e.g New, APO etc', j);   
                j++;
                results.add(resultf);
            }else{
                
                switch on opp.Sale_Type__c {
                    when 'Approved_Pre_Owned' {
                        RDA_TYPE = tradeInRDA;
                        checkAccountType = false;
                        // System.debug('when block tradeInRDA');
                    }
                    when 'Demonstrator' {
                        RDA_TYPE = onSellRDA;
                        checkExistingRDA = true;
                        System.debug('when block -onSellRDA');
                    }
                    when 'New' {
                        RDA_TYPE = newRetailerRDA;
                        System.debug('when block -newRetailerRDA');
                    }
                    when 'Pre_Owned' {
                        RDA_TYPE = tradeInRDA;
                        checkAccountType = false;
                        System.debug('when block -tradeInRDA');
                    }
                    when else {
                        RDA_TYPE = 'Unknown';
                        ValidationResult   resultf = new ValidationResult(False,'Opportunity at Unrecognised Sale Type', j);   
                        j++;
                        results.add(resultf);
                    }
                }
            }
            
            //END SET TYPE
            //
            
            system.debug('Opportunity Retrieved '+opp);
            oppLineItems = oppRetrieved[0].OpportunityLineItems;
            system.debug('OpportunityLineItems Retrieved '+oppLineItems);
            if(oppLineItems != null && oppLineItems.size() == 1){
                system.debug(' opp line item');
                oppLineItem = oppLineItems[0];
                //note joe include opp name
                ValidationResult   resultp = new ValidationResult(True,'Asset associatated to opportunity', j);
                j++;
                results.add(resultp);
            }else{
                system.debug('no opp line item');
                ValidationResult   resultf = new ValidationResult(False,'No asset associatated to opportunity', j);  
                j++;
                results.add(resultf);
                
                RdaValidatorWrapper finalResult = new RdaValidatorWrapper(RDA_TYPE.replace('_', ' '), results, rdaAlreadyExists);
                return finalResult;
            }
            
        }else{
            system.debug('no opp');
            ValidationResult   resultf = new ValidationResult(False,'Code Error: No Opportunity Retrieved contact system administrator', j);   
            j++;
            results.add(resultf);
            
            RdaValidatorWrapper finalResult = new RdaValidatorWrapper(RDA_TYPE.replace('_', ' '), results,rdaAlreadyExists);
            return finalResult;
        }
        
        // //CHECKING RDA EXIST start
        //for demo dealer owned or OUV 1 
        //opp id = this one but asset doesn't of an exoisting rda fail
        ////if opp id and asset = this one annnnd recordtype = dorecordtype pass for demo if there 1 
        existingRDA = [SELECT Id, RecordTypeId,Submitted_Status__c, asset__c ,Opportunity__c  FROM Rda__c WHERE (asset__c  =: oppLineItem.asset__c OR Opportunity__c =:opp.Id)  AND Submitted_Status__c != 'Cancelled' AND Submitted_Status__c != 'Failed'];
        //Check if any opps exist
        // existingAssetRDA
        // existingOppRDA
        integer numberDORda = 0; 
        integer numberNonDORda = 0;
        boolean oppHasRDA = false;
        boolean demoOppHasOnSell = false;
        if(existingRDA != null && existingRDA.size() > 0){
          
            for(RDA__c rda :existingRDA){
                if(rda.Opportunity__c == opp.Id ){
                    oppHasRDA = true;
                    existingOppRDA.add(rda);
                }
                if(rda.Asset__c == oppLineItem.asset__c && rda.Opportunity__c != opp.Id ){
                    existingAssetRDA.add(rda);
                    if(rda.RecordTypeId == onSellRDARecordtype && opp.Sale_Type__c == 'Demonstrator')
                    {
                        demoOppHasOnSell = true;
                    }
                    if(rda.RecordTypeId == doRecordtype){
                        numberDORda++;
                    }
                    else {
                        numberNonDORda++;
                    }
                }                
            }
            if(demoOppHasOnSell)
            {
                ValidationResult resultb = new ValidationResult(False, 'This asset already has an on-sell RDA, cannot on-sell, please change Sale Type to process Trade in RDA', j);
                j++;
                results.add(resultb);
            }
            if(oppHasRDA){
                ValidationResult   resultf = new ValidationResult(False,'Opportunity is already related to a RDA.', j);   
                j++;
                rdaAlreadyExists = true;
                results.add(resultf);    
            }   
            
        }
        
        if(checkExistingRDA){
            if(numberDORda == 1 && numberNonDORda == 0){
                ValidationResult   resultt = new ValidationResult(True,'Asset has an existing RDA', j);   
                j++;
                results.add(resultt); 
            }
            else if(numberDORda == 0 && !oppHasRDA){ // No DO & No RDA linked
                ValidationResult   resultf = new ValidationResult(False,'Asset does not have an existing Demo/DLV RDA - Vehicle not applicable for On-Sell.', j);   
                j++;
                results.add(resultf); 
            }
            else {
                ValidationResult   resultt = new ValidationResult(False,'Asset has more than one RDA linked to it.', j);   
                j++;
                results.add(resultt); 
            }            
        }else{
            if(  RDA_TYPE == newRetailerRDA){
                if(existingAssetRDA != null && existingAssetRDA.size() > 0 ){
                    string messagtt = 'Asset has an existing RDA.';//+existingAssetRDA;
                    ValidationResult   resultf = new ValidationResult(False,messagtt,j);//'Asset has an existing RDA!', j);   
                    j++;
                    results.add(resultf); 
                }else{
                    ValidationResult   resultt = new ValidationResult(True,'Asset does not have an existing RDA', j);   
                    j++;
                    results.add(resultt); 
                }  
            }
            
        }
        //CHECKING RDA EXIST finsih
        system.debug('time to check details of opp');
        
        if( opp.StageName !='Handover & RDA'){
            system.debug('Wrong opp');
            ValidationResult   resultf = new ValidationResult(False,'Opportunity needs to be at Handover & RDA stage, please close opportunity as won', j);   
            j++;
            results.add(resultf);
        }else{
            system.debug('correct stage opp');
            ValidationResult   resultp = new ValidationResult(True,'Opportunity at correct  Handover & RDA stage', j);   
            j++;
            results.add(resultp);
        }
        
        system.debug('Check opp line asset stage opp');
        //check other opportunities
        if(oppLineItem.asset__c != null){
            system.debug('Check hass asset opp');
            List<OpportunityLineItem> otherOpps = [SELECT id from OpportunityLineItem where asset__c = :oppLineItem.asset__c AND OpportunityId != :opp.id AND Opportunity.IsClosed = false ];
            if(otherOpps != null && otherOpps.size() > 0){
                
                ValidationResult   resultf = new ValidationResult(False,'Another open Opportunity has this asset associated to it, check asset for related open opportunities', j);   
                j++;
                results.add(resultf); 
            }
            
        }
        //
        system.debug('Check asset deets');
        if(oppLineItem.asset__r.Sale_Type_Code__c == null ||oppLineItem.asset__r.Common_Sale_Type__c == null||oppLineItem.asset__r.Vista_Status__c == null){
            if(oppLineItem.asset__r.Sale_Type_Code__c == null){
                ValidationResult   resultf = new ValidationResult(False,'Asset is missing Sale Type Code', j);   
                j++;
                results.add(resultf); 
            }      
            if(oppLineItem.asset__r.Common_Sale_Type__c == null){
                ValidationResult   resultf = new ValidationResult(False,'Asset is missing Common Sale Type', j);   
                j++;
                results.add(resultf); 
            }      
            
            if(oppLineItem.asset__r.Vista_Status__c == null){
                ValidationResult   resultf = new ValidationResult(False,'Asset is missing Vista status', j);   
                j++;
                results.add(resultf); 
            }      
            
            
            RdaValidatorWrapper finalResult = new RdaValidatorWrapper(RDA_TYPE.replace('_', ' '), results, rdaAlreadyExists);
            return finalResult;
        }
        //CHECK 2nd handover
        system.debug('CHECK 2nd handover');
        if(RDA_TYPE == onSellRDA && (oppLineItem.asset__r.Common_Sale_Type__c == 'Demonstrator' ||oppLineItem.asset__r.Common_Sale_Type__c == 'Courtesy / Loan Car' )){
            ValidationResult   resultf = new ValidationResult(False,'Vehicle is still Demonstrator or Courtesy Loan Car - Process the second handover in Vista to update vehicle to the correct Common Sale Type', j);   
            j++;
            results.add(resultf);
        }
        
        
        //CHECK ACCOUNT TYPE AND OPP TYPE 
        system.debug('CHECK IF OPP IS PRE-OWNED BEFORE ACCOUNT TYPE CHECK');
        if(checkAccountType)
        {
            
            system.debug('CHECK ACCOUNT TYPE AND OPP TYPE');
            system.Debug('oppLineItem.asset__r.Sale_Type_Code__c '+oppLineItem.asset__r.Sale_Type_Code__c);
            List<Common_Sale_Type_and_Account_Type_Mappin__mdt> cstmps = [SELECT Label, Valid_for_Person_Account__c from Common_Sale_Type_and_Account_Type_Mappin__mdt WHERE Label  =:oppLineItem.asset__r.Common_Sale_Type__c];
            if(cstmps != null && cstmps.size() == 1){
                If(cstmps[0].Valid_for_Person_Account__c != opp.Account.isPersonAccount){
                    string complexMessage2 = 'Common Type of Sale is invalid for customer type.'+'\n';
                    if(opp.Account.isPersonAccount){ complexMessage2 = complexMessage2 + 'Customer Type = Individual'+'\n';  }else{   complexMessage2 = complexMessage2 + 'Customer Type = Corporate'+'\n';  }
                    complexMessage2 = complexMessage2 + 'Common Type of Sale = ' + oppLineItem.asset__r.Common_Sale_Type__c;
                    complexMessage2 = complexMessage2 +'\n'+   'Either change the account type on the Opportunity, or the Sale Type in Vista';
                    ValidationResult   resultf = new ValidationResult(False,complexMessage2, j);   
                    j++;
                    results.add(resultf);
                }
            }
        }
        //
        //CHECK METADATA TABLE Start
        system.debug('CHECK METADATA TABLE Start');
        if(RDA_TYPE != null  ){
            cutomMetadaTypes = [SELECT Id, Sale_Type_Code__c, Common_Sale_Type__c, Common_Status_Point__c, Purchase_Type__c, Type_of_RDA__c, RDA_Exists__c  
                                FROM Defined_values_for_RDA_type__mdt where Type_of_RDA__c =:RDA_TYPE AND
                                (Sale_Type_Code__c = null OR Sale_Type_Code__c = :oppLineItem.asset__r.Sale_Type_Code__c) AND (Common_Sale_Type__c = null OR Common_Sale_Type__c = :oppLineItem.asset__r.Common_Sale_Type__c)AND (Common_Status_Point__c = null OR Common_Status_Point__c = :oppLineItem.asset__r.Vista_Status__c)];
        }
        
        if(cutomMetadaTypes != null && cutomMetadaTypes.size() > 0){
            
            
        }else{
            //string complexMessage = 'No valid RDA setting found, please check Asset has correct sale type code, common sale type and vista status. Sale type code: '+oppLineItem.asset__r.Sale_Type_Code__c+' Sale type: '+oppLineItem.asset__r.Common_Sale_Type__c+' and Vista Status: '+oppLineItem.asset__r.Vista_Status__c;
            string complexMessage = 'Invalid combination of Common Sale Type, Sale Type Code and Vista Status - Please check the following values on your asset are correct: '+'\n'+'Vista Status = '+oppLineItem.asset__r.Vista_Status__c +'\n'+'Common Sale Type = '+oppLineItem.asset__r.Common_Sale_Type__c;
            
            
            ValidationResult   resultf = new ValidationResult(False,complexMessage, j);   
            j++;
            results.add(resultf); 
            RdaValidatorWrapper finalResult = new RdaValidatorWrapper(RDA_TYPE.replace('_', ' '), results, rdaAlreadyExists);
            return finalResult;
        }
        //CHECK METADATA TABLE end
        
        //TRADE IN check Start
        if(   RDA_TYPE == tradeInRDA ){
            if(oppLineItem.asset__r.Traded_In__c){
                ValidationResult   resultt = new ValidationResult(True,'Asset is set as Traded In', j);   
                j++;
                results.add(resultt); 
                
            }else{
                ValidationResult   resultf = new ValidationResult(False,'Asset not set as Traded In', j);   
                j++;
                results.add(resultf); 
            }
        }else{
            if(oppLineItem.asset__r.Traded_In__c){
                ValidationResult   resultf = new ValidationResult(False,'Asset is set as Traded In', j);   
                j++;
                results.add(resultf); 
                
            }else{
                ValidationResult   resultt = new ValidationResult(True,'Asset Not set as Traded In', j);   
                j++;
                results.add(resultt); 
            }
        }
        //TRADE IN check finish
        //DONE
        system.debug('FINAL RESUILT ');
        
        RdaValidatorWrapper finalResult = new RdaValidatorWrapper(RDA_TYPE.replace('_', ' '), results, rdaAlreadyExists);
        system.debug(json.serializePretty(finalResult));
        return finalResult;
    }
    
}