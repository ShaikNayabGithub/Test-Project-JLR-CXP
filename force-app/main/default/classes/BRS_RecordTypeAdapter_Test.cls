@isTest
public class BRS_RecordTypeAdapter_Test {
    static testmethod void Adapt_ReturnsEmptyMap_GivenEmptyMap()
    {
    	BRS_RecordTypeAdapter adapter = new BRS_RecordTypeAdapter();
    	
    	Map<String, BRS_PicklistGroup_A> picklistGroups = new Map<String, BRS_PicklistGroup_A>();
    	
    	Map<String, BRS_RecordTypeGroup> results = adapter.Adapt(picklistGroups);
    	
    	System.AssertEquals(0, results.Size());
    }
    
    static testmethod void Adapt_ReturnsEmptyMap_GivenPicklistGroupWithNameTestAndSettingTestDoesNotExist()
    {
    	String picklistName = 'Test';
    	BRS_RecordTypeAdapter adapter = new BRS_RecordTypeAdapter();
    	
    	Map<String, BRS_PicklistGroup_A> picklistGroups = new Map<String, BRS_PicklistGroup_A>();
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global(picklistName);
    	picklistGroups.Put(picklistName, picklistGroup);
    	
    	Map<String, BRS_RecordTypeGroup> results = adapter.Adapt(picklistGroups);
    	
    	System.AssertEquals(0, results.Size());
    }
    
    static testmethod void Adapt_ReturnsRecordTypeGroupProduct2Derivative_GivenPicklistGroupWithNameTestAndSettingProduct2DerivativeExists()
    {
    	String recordtypeName = 'Product2.Derivative';
    	String picklistName = 'Test';
    	ESB_ObjectRecordTypes__c esbRecordTypeSetting = new ESB_ObjectRecordTypes__c(Name=recordtypeName);
    	insert esbRecordTypeSetting;
    	
    	BRS_RecordTypeAdapter adapter = new BRS_RecordTypeAdapter();
    	
    	Map<String, BRS_PicklistGroup_A> picklistGroups = new Map<String, BRS_PicklistGroup_A>();
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global(picklistName);
    	picklistGroups.Put(picklistName, picklistGroup);
    	
    	Map<String, BRS_RecordTypeGroup> results = adapter.Adapt(picklistGroups);
    	
    	System.AssertNotEquals(null, results.get(recordtypeName));
    }
    
    static testmethod void Adapt_ReturnsRecordTypeGroupProduct2Derivative_GivenPicklistGroupWithNameColourAndSettingProduct2DerivativeExistsWithUsesColourEqualsTrue()
    {
    	String recordtypeName = 'Product2.Derivative';
    	String picklistName = 'Test';
    	ESB_ObjectRecordTypes__c esbRecordTypeSetting = new ESB_ObjectRecordTypes__c(Name=recordtypeName,Uses_Colour__c=true);
    	insert esbRecordTypeSetting;
    	
    	BRS_RecordTypeAdapter adapter = new BRS_RecordTypeAdapter();
    	
    	Map<String, BRS_PicklistGroup_A> picklistGroups = new Map<String, BRS_PicklistGroup_A>();
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global(picklistName);
    	picklistGroups.Put(picklistName, picklistGroup);
    	
    	Map<String, BRS_RecordTypeGroup> results = adapter.Adapt(picklistGroups);
    	
    	System.AssertNotEquals(null, results.get(recordtypeName));
    }
    
    static testmethod void Adapt_ReturnsEmptyMap_GivenPicklistGroupWithNameColourAndSettingProduct2DerivativeExistsWithUsesColourEqualsFalse()
    {
    	String recordtypeName = 'Product2.Derivative';
    	String picklistName = 'Test';
    	ESB_ObjectRecordTypes__c esbRecordTypeSetting = new ESB_ObjectRecordTypes__c(Name=recordtypeName,Uses_Colour__c=false);
    	insert esbRecordTypeSetting;
    	
    	BRS_RecordTypeAdapter adapter = new BRS_RecordTypeAdapter();
    	
    	Map<String, BRS_PicklistGroup_A> picklistGroups = new Map<String, BRS_PicklistGroup_A>();
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global(picklistName);
    	picklistGroups.Put(picklistName, picklistGroup);
    	
    	Map<String, BRS_RecordTypeGroup> results = adapter.Adapt(picklistGroups);
    	
    	System.AssertNotEquals(null, results.get(recordtypeName));
    }
    
    static testmethod void Adapt_ReturnsRecordTypeGroupProduct2DerivativeWithValueOne_GivenPicklistGroupWithNameTestAndValueOneAndSettingProduct2DerivativeExists()
    {
    	String recordtypeName = 'Product2.Derivative';
    	String picklistName = 'Test';
    	String picklistValue = 'One';
    	ESB_ObjectRecordTypes__c esbRecordTypeSetting = new ESB_ObjectRecordTypes__c(Name=recordtypeName);
    	insert esbRecordTypeSetting;
    	
    	BRS_RecordTypeAdapter adapter = new BRS_RecordTypeAdapter();
    	
    	Map<String, BRS_PicklistGroup_A> picklistGroups = new Map<String, BRS_PicklistGroup_A>();
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global(picklistName);
    	picklistGroup.AddPicklistValue(picklistValue);
    	picklistGroups.Put(picklistName, picklistGroup);
    	
    	Map<String, BRS_RecordTypeGroup> results = adapter.Adapt(picklistGroups);
    	
    	System.AssertEquals(picklistValue, results.get(recordtypeName).RecordType.picklistValues[0].values[0].fullName);
    }
}