@isTest
public class Case_Brand2Setter_T {
	static testmethod void SetBrandList_DoesNothing_GivenEmptyList()
    {
    	Case_Brand2Setter brand2Setter = new Case_Brand2Setter();

    	List<Case> cases = new List<Case>();

    	brand2Setter.SetBrand(cases);

    	System.assert(true);
    }

    static testmethod void SetBrandListMap_DoesNothing_GivenEmptyList()
    {
    	Case_Brand2Setter brand2Setter = new Case_Brand2Setter();

    	List<Case> cases = new List<Case>();
    	Map<Id, Case> oldCaseMap = new Map<Id, Case>();

    	brand2Setter.SetBrand(cases, oldCaseMap);

    	System.assert(true);
    }

    static testmethod void SetBrandListMap_DoesNotSetBrand2_GivenCaseWithNoAsset()
    {
    	Case_Brand2Setter brand2Setter = new Case_Brand2Setter();

    	Case case1 = TestClass_CaseCreator.Create('Phone');

    	List<Case> cases = new List<Case> { case1 };
    	Map<Id, Case> oldCaseMap = new Map<Id, Case> { case1.Id => case1 };

    	brand2Setter.SetBrand(cases, oldCaseMap);

    	System.assert(String.isEmpty(case1.Brand2__c));
    }

    static testmethod void SetBrandListMap_DoesNotSetBrand2_GivenCaseWithAsset1AndOldCaseWithAsset1()
    {
    	Case_Brand2Setter brand2Setter = new Case_Brand2Setter();

    	Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
    	insert asset1;
    	Case case1 = TestClass_CaseCreator.Create('Phone');
    	case1.AssetId = asset1.Id;
    	Case oldCase1 = new Case(AssetId = asset1.Id);

    	List<Case> cases = new List<Case> { case1 };
    	Map<Id, Case> oldCaseMap = new Map<Id, Case> { case1.Id => oldCase1 };

    	brand2Setter.SetBrand(cases, oldCaseMap);

    	System.assert(String.isEmpty(case1.Brand2__c));
    }

    static testmethod void SetBrandList_SetsBrand2ToJaguar_GivenCaseWithJaguarAsset()
    {
    	Case_Brand2Setter brand2Setter = new Case_Brand2Setter();

    	Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
    	insert asset1;
    	Case case1 = TestClass_CaseCreator.Create('Phone');
    	case1.AssetId = asset1.Id;

    	List<Case> cases = new List<Case> { case1 };

    	brand2Setter.SetBrand(cases);

    	System.assertEquals('Jaguar', case1.Brand2__c);
    }

    static testmethod void SetBrandListMap_SetsBrand2ToJaguar_GivenCaseWithJaguarAssetAndOldCaseWithNoAsset()
    {
    	Case_Brand2Setter brand2Setter = new Case_Brand2Setter();

    	Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
    	insert asset1;
    	Case case1 = TestClass_CaseCreator.Create('Phone');
    	case1.AssetId = asset1.Id;
    	Case oldCase1 = new Case();

    	List<Case> cases = new List<Case> { case1 };
    	Map<Id, Case> oldCaseMap = new Map<Id, Case> { case1.Id => oldCase1 };

    	brand2Setter.SetBrand(cases, oldCaseMap);

    	System.assertEquals('Jaguar', case1.Brand2__c);
    }
}