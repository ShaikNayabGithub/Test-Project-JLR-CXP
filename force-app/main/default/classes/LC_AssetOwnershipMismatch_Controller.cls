public class LC_AssetOwnershipMismatch_Controller {

	@AuraEnabled
    public static boolean getMismatchWarningMessage(Id assetId) {
        //get count of related Service Data, Contracts, Roadside Events for this Asset
        Asset asset = [SELECT Id, AccountId, Account.RecordType.Name, (SELECT Id FROM Contracts__r), (SELECT Id FROM Service_Data__r), (SELECT Id FROM EVHC_Data__r) FROM Asset WHERE Id = :assetId];
        if(asset == null || asset.AccountId == null || asset.Account.RecordType.Name != 'Retailer'){ //only display message if Asset is owned by a Retailer
            return false;
        }
        if(asset != null && asset.Contracts__r != null && asset.Contracts__r.size() > 0){
            return true;
        }
        if(asset != null && asset.Service_Data__r != null && asset.Service_Data__r.size() > 0){
            return true;
        }
		if(asset != null && asset.EVHC_Data__r != null && asset.EVHC_Data__r.size() > 0){
            return true;
        }
        List<Event> roadsideEvents = [SELECT Id FROM Event WHERE RecordType.Name = 'Roadside' AND WhatId = :assetId];
        if(roadsideEvents.size() > 0){
            return true;
        }
        return false;
    }

}