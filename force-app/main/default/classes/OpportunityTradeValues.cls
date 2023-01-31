public with sharing class OpportunityTradeValues {

    @AuraEnabled public String Id {get; set;}
    @AuraEnabled public Integer Mileage {get; set;}
    @AuraEnabled public Decimal Value {get; set;}
    @AuraEnabled public String Service {get; set;}
    @AuraEnabled public String Make {get; set;}
    @AuraEnabled public String Model {get; set;}
    @AuraEnabled public String Vin {get; set;}
    @AuraEnabled public String ModelYear {get; set;}
    @AuraEnabled public Boolean JlrTrade {get; set;}
    @AuraEnabled public Boolean TradeIn {get; set;}

    public OpportunityTradeValues(string tID, Integer tMileage, Decimal tValue, string tService, string tmakeId, string tmodelId, string tregNum, string tmodelYear,Boolean tradeIn, Boolean tjlrTrade) {
        this.Id = tID;
        this.Mileage = tMileage;
        this.Value = tValue;
        this.Service = tService;
        this.Make = tMakeId;
        this.Model = tModelId;
        this.Vin = tregNum;
        this.ModelYear = tmodelYear;
        this.JlrTrade = tjlrTrade;
        this.TradeIn = tradeIn;
    }

    public OpportunityTradeValues() {

    }
}