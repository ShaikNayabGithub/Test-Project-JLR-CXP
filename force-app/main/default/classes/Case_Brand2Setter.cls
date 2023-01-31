public class Case_Brand2Setter {
    private static final Schema.DescribeFieldResult CASE_ASSET_FIELD = Schema.Case.AssetId.getDescribe();


    public void SetBrand(List<Case> cases)
    {
        Set<String> assetIds = SObjectUtilities.GetFieldValues(cases, CASE_ASSET_FIELD.getName());
        List<Asset> assets = [SELECT Id, Brand__r.Name,registration_Number__c FROM Asset WHERE Id IN: assetIds];
        Map<Id, Asset> assetsById = new Map<Id, Asset>(assets);

        for(Case caseRecord : cases) {
            if(String.isEmpty(caseRecord.AssetId)) continue;

            Asset caseAsset = assetsById.get(caseRecord.AssetId);
            if(caseAsset == null) continue;

            caseRecord.Brand2__c = caseAsset.Brand__r.Name;
            caseRecord.Licence_Plate_text__c=caseAsset.registration_Number__c;
        }
    }

    public void SetBrand(List<Case> cases, Map<Id, Case> oldCaseMap)
    {
        List<Case> casesWithUpdatedAsset = new List<Case>();

        for(Case caseRecord : cases) {
            Case oldCase = oldCaseMap.get(caseRecord.Id);
            if(caseRecord.AssetId != oldCase.AssetId) {
                casesWithUpdatedAsset.add(caseRecord);
            }
        }

        this.SetBrand(casesWithUpdatedAsset);
    }
}