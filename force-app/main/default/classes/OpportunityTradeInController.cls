public without sharing class OpportunityTradeInController {
    public OpportunityTradeInController() {

    }

    @AuraEnabled(Cacheable = false)
    public static String getMakeFromModel(String ID){
        Vehicle_Specification__c vehicleMakeId = [SELECT make__c FROM Vehicle_Specification__c WHERE id= :ID];
        String makeID;
        if(vehicleMakeId != null)
        {
            makeID = vehicleMakeId.Make__c;
        }
        return makeID;
    }

    @AuraEnabled(Cacheable = false)
    public static OppTradeInVinResult getVehicleFromVin(string ID){
        OppTradeInVinResult result = new OppTradeInVinResult();
        string searchTerm = ID + '%';
        List<Asset> AssetReceived = [SELECT Id, Name, Brand__c, model__r.productCode, model__r.Model_Vehicle_Spec__c, model__r.Model_Vehicle_Spec__r.Make__c,model__r.Model_Vehicle_Spec__r.name, Derivative__c, Derivative__r.Model_Year__c, vin__c, model_Year__c FROM Asset WHERE (Vin__C LIKE :searchTerm OR Registration_number__c LIKE :searchTerm OR Name LIKE :searchTerm) AND Account.Country_iso_code__c = 'AU' LIMIT 5];
        System.debug('Assets Results' + AssetReceived);
        if(AssetReceived != null && AssetReceived.size() == 1)
        {
            System.debug('Assets Results only 1' );

            if(AssetReceived[0].Model__c != null && AssetReceived[0].model__r.Model_Vehicle_Spec__c != null )
            {
                     result.modelId = AssetReceived[0].model__r.Model_Vehicle_Spec__c;
                
            }

            /*
            string searchTermModel = '%' + AssetReceived[0].model__r.productCode + '%';
            if(AssetReceived[0].Model__r.productCode != null)
            {
                    
                List<Vehicle_Specification__c> VehSpecReceived = [SELECT Id FROM Vehicle_Specification__c WHERE Model_Code__c LIKE :searchTermModel LIMIT 1];
                if(VehSpecReceived != null && VehSpecReceived.size() > 0)
                {
                    System.debug('VehSpecReceived '+VehSpecReceived );
                    result.modelId = VehSpecReceived[0].Id;
                }
            }*/
            result.makeId = AssetReceived[0].Brand__c;
            if(AssetReceived[0].Derivative__c != null)
            {
                result.modelYear = AssetReceived[0].Derivative__r.Model_Year__c;
            }
            result.vehicleId = AssetReceived[0].Name;
        }
        return result;
    }

    @AuraEnabled
    public static void updateOpportunityTrade(string ID, Integer Mileage, Decimal Value, string Service, string makeId, string modelId, string regNum, string modelYear, Boolean tradeIn, Boolean jlrTrade)
    {
        Opportunity objectToBeUpdated = new Opportunity();
        objectToBeUpdated.id = ID;
        objectToBeUpdated.Trade_in_Mileage__c = Mileage;
        System.debug('makeId '+ makeId );
        System.debug('modelId '+ modelId );
        objectToBeUpdated.Trade_In_Brand_Lookup__c = makeId;
        objectToBeUpdated.Trade_In_Model_Lookup__c = modelId;
        objectToBeUpdated.Trade_in_Registration_Number__c = regNum;
        objectToBeUpdated.Model_Year__c = modelYear;
        objectToBeUpdated.Revised_Trade_in_Value__c = Value;
        objectToBeUpdated.Service_History__c = Service;
        objectToBeUpdated.JLR_Trade_In__c = jlrTrade;
        objectToBeUpdated.Trade_In__c = tradeIn;
        System.debug('objectToBeUpdated.JLR_Trade_In__c  '+ objectToBeUpdated.JLR_Trade_In__c );
        System.debug('jlrTradeJ '+ jlrTrade );
        update objectToBeUpdated;
    }

    @AuraEnabled(Cacheable = false)
    public static OpportunityTradeValues getPredoneData(string idNum)
    {
        List<Opportunity> currentOpp = [SELECT id, Trade_In_Mileage__c, Trade_In_Brand_Lookup__c, Trade_In_Model_Lookup__c, Trade_in_Registration_Number__c, Model_Year__c, Revised_Trade_in_Value__c, Service_History__c, Trade_In__c, JLR_Trade_In__c FROM Opportunity WHERE Id = :idNum LIMIT 1];
        
        System.debug('Opp Received '+ currentOpp );
        System.debug('Opp ID '+ idNum );
        Integer mileage = null;
        if(currentOpp[0].Trade_in_Mileage__c != null)
        {
            mileage = currentOpp[0].Trade_in_Mileage__c.intValue();
        }
        if(currentOpp != null && currentOpp.size() == 1)
        {
            OpportunityTradeValues result = new OpportunityTradeValues(currentOpp[0].Id,
          mileage, currentOpp[0].Revised_Trade_in_Value__c,
          currentOpp[0].Service_History__c, currentOpp[0].Trade_In_Brand_Lookup__c,
          currentOpp[0].Trade_In_Model_Lookup__c, currentOpp[0].Trade_in_Registration_Number__c,
          currentOpp[0].Model_Year__c, currentOpp[0].Trade_In__c,currentOpp[0].JLR_Trade_In__c);
        return result;
        }
        else {
            return null;
        }
    } 

}