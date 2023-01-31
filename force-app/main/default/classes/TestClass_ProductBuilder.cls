@isTest
public class TestClass_ProductBuilder {
	public static Boolean insertImmediately = true;

	public static Product2 BuildModel(Vehicle_Specification__c make) {
		Product2 model = new Product2();

		model.Name = 'test model';
		model.Make__c = make.Id;
        model.Model_Colours__c = '[{"Value":"Seoul Pearl Silver","Key":"1DJ","LanguageCode":"EN"},{"Value":"Fuji White","Key":"1AA","LanguageCode":"EN"}]';
		
		if(insertImmediately) {
			insert model;
		}
		
		return model;
	}

	public static Product2 BuildAccessoryOption(String nameAndCode) {
		Product2 option  = new Product2();
		Id optionRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Accessories').getRecordTypeId();
		option.Name = nameAndCode;
		option.IsActive = true;
		option.ProductCode = nameAndCode;
		option.RecordTypeId = optionRecordTypeId;
		if(insertImmediately) {
			insert option;
		}
		return option;

	}
}