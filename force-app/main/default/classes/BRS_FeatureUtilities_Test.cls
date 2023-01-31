@isTest
public class BRS_FeatureUtilities_Test {
    static testmethod void FeatureGroupFieldMappingByFieldName_ContainsPairTestStringTestSetting_WhenTestSettingExistsAndHasFieldNameTestString()
    {
    	String settingName = 'BRS_FeatureUtilities_Test.testName';
    	String settingFieldName = 'testString';
    	
    	BRS_FeatureGroupFieldMappingByCode__c testSetting = new BRS_FeatureGroupFieldMappingByCode__c(Name=settingName,Field_Name__c=settingFieldName);
    	insert testSetting;
    	
    	Map<String, BRS_FeatureGroupFieldMappingByCode__c> settingMap = BRS_FeatureUtilities.FeatureGroupFieldMappingByFieldName;
    	
    	System.AssertEquals(settingName, settingMap.get(settingFieldName).Name);
    }
    
    //Test checks that setting is not re-queried when called a second time
    static testmethod void FeatureGroupFieldMappingByFieldName_DoesNotContainPairTestString2TestSetting2_WhenTestSetting2InsertedAfterAttributeIsFirstRetrieved()
    {
    	String settingName = 'BRS_FeatureUtilities_Test.testName';
    	String settingFieldName = 'testString';
    	String settingName2 = 'BRS_FeatureUtilities_Test.testName2';
    	String settingFieldName2 = 'testString2';
    	
    	BRS_FeatureGroupFieldMappingByCode__c testSetting = new BRS_FeatureGroupFieldMappingByCode__c(Name=settingName,Field_Name__c=settingFieldName);
    	insert testSetting;
    	
    	Map<String, BRS_FeatureGroupFieldMappingByCode__c> settingMap1 = BRS_FeatureUtilities.FeatureGroupFieldMappingByFieldName;
    	
    	BRS_FeatureGroupFieldMappingByCode__c testSetting2 = new BRS_FeatureGroupFieldMappingByCode__c(Name=settingName2,Field_Name__c=settingFieldName2);
    	insert testSetting2;
    	
    	Map<String, BRS_FeatureGroupFieldMappingByCode__c> settingMap2 = BRS_FeatureUtilities.FeatureGroupFieldMappingByFieldName;
    	
    	System.AssertEquals(null, settingMap2.get(settingFieldName2));
    }
}