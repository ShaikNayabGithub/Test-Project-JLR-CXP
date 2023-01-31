public with sharing class OppTradeInVinResult {

    @AuraEnabled public string vehicleId {get; set;}
    @AuraEnabled public string modelId {get; set;}
    @AuraEnabled public string makeId {get; set;}
    @AuraEnabled public string modelYear {get; set;}

    public OppTradeInVinResult(string vehicle, string model, string make, string year) {
        vehicleId = vehicle;
        modelId = model;
        makeId = make;
        modelYear = year;
    }

    public OppTradeInVinResult() {

    }
}