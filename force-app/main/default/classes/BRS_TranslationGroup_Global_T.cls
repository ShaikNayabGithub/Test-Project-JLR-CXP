@isTest
public class BRS_TranslationGroup_Global_T {
	static testmethod void AddPicklistValueTranslation_AddsPicklistValueTranslationOne_GivenPicklistOneAndPicklistValueOneAndTranslationOne()
    {
    	String picklistName = 'picklist1';
    	String picklistValue = 'picklistValue1';
    	String translation = 'translation1';
    	
    	BRS_TranslationGroup_Global translationGroup = new BRS_TranslationGroup_Global('en_GB');
    	
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	
    	translationGroup.AddPicklistValueTranslation(picklistName, picklistValue, translation, request);
    	
    	System.AssertEquals(translation, translationGroup.Translations.globalPicklists[0].picklistValues[0].translation);
    }
    
    static testmethod void AddPicklistValueTranslation_AddsRequestOne_GivenPicklistOneAndPicklistValueOneAndTranslationOne()
    {
    	String picklistName = 'picklist1';
    	String picklistValue = 'picklistValue1';
    	String translation = 'translation1';
    	
    	BRS_TranslationGroup_Global translationGroup = new BRS_TranslationGroup_Global('en_GB');
    	
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	
    	translationGroup.AddPicklistValueTranslation(picklistName, picklistValue, translation, request);
    	
    	System.AssertEquals(request, translationGroup.Requests.get(request.Id));
    }
    
    static testmethod void AddPicklistValueTranslation_AddsPicklistValueTranslationTwoToPicklistOne_GivenPicklistOneExistsAndPassedPicklistOneAndPicklistValueOneAndTranslationOne()
    {
    	String picklistName = 'picklist1';
    	String picklistValue1 = 'picklistValue1';
    	String translation1 = 'translation1';
    	String picklistValue2 = 'picklistValue2';
    	String translation2 = 'translation2';
    	
    	BRS_TranslationGroup_Global translationGroup = new BRS_TranslationGroup_Global('en_GB');
    	
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	
    	translationGroup.AddPicklistValueTranslation(picklistName, picklistValue1, translation1, request);
    	translationGroup.AddPicklistValueTranslation(picklistName, picklistValue2, translation2, request);
    	
    	System.AssertEquals(translation2, translationGroup.Translations.globalPicklists[0].picklistValues[1].translation);
    }
}