//@isTest(SeeAllData=true)
@isTest
private class RelatedRoleRetriever_Test {
    /*@isTest
    static void CurrentToPreviousRoleMap_OnlyContainsValidRolePicklistValues_Always() {
        //create set of Role values from Asset Role picklist
        Schema.DescribeFieldResult roleField = Role__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> rolePicklist = roleField.getPicklistValues();
        Set<String> availablePicklistValues = new Set<String>();
        
        for(Schema.PicklistEntry p : rolePicklist){
            availablePicklistValues.add(p.getValue());
        }
        
        //get values from Custom Setting
        Map<String, CurrentToPreviousRoleMap__c> rolePairs = CurrentToPreviousRoleMap__c.getAll();
        String nonFoundValues = '';
        
        for(String customSettingCurrentRole : rolePairs.keySet()){
            if(!availablePicklistValues.contains(customSettingCurrentRole)){
                if(nonFoundValues != '') nonFoundValues += ', ';
                nonFoundValues += customSettingCurrentRole;
            }
            String customSettingPreviousRole = rolePairs.get(customSettingCurrentRole).Previous_Role__c;
            if(!availablePicklistValues.contains(customSettingPreviousRole)){
                if(nonFoundValues != '') nonFoundValues += ', ';
                nonFoundValues += customSettingPreviousRole;
            }
        }

        System.assertEquals('', nonFoundValues);
    }*/
    
    @isTest
    static void RelatedRoleRetriever_DoesNotError_WhenPicklistValuePickedThatIsNotInCustomSetting() {
        CurrentToPreviousRoleMap__c ctpr = new CurrentToPreviousRoleMap__c();
        ctpr.Name = 'Current Owner';
        ctpr.Previous_Role__c = 'Previous';
        insert ctpr;
        Asset asset = TestClass_AssetBuilder.BuildVehicle();
        insert asset;
        Role__c role = new Role__c();
        asset = [SELECT Id, AccountId FROM Asset WHERE Name = :asset.Name ORDER BY CreatedDate DESC LIMIT 1];
        role.Account__c = asset.AccountId;
        role.Vehicle__c = asset.Id;
        role.Role__c = 'qwerty';
        insert role;
        Role__c role2 = new Role__c();
        role2.Account__c = asset.AccountId;
        role2.Vehicle__c = asset.Id;
        role2.Role__c = 'qwerty';
        insert role2;
        List<Role__c> roles = [SELECT Id FROM Role__c WHERE Account__c = :asset.AccountId AND Vehicle__c = :asset.Id AND Role__c = 'qwerty'];
        System.assertEquals(2, roles.size());
    }
    
    @isTest
    static void RelatedRoleRetriever_DoesNotError_WhenPicklistValuePickedThatIsInCustomSettingButReturnValueIsNot() {
        CurrentToPreviousRoleMap__c ctpr = new CurrentToPreviousRoleMap__c();
        ctpr.Name = 'Current Owner';
        ctpr.Previous_Role__c = 'qwerty';
        insert ctpr;
        Asset asset = TestClass_AssetBuilder.BuildVehicle();
        insert asset;
        Role__c role = new Role__c();
        asset = [SELECT Id, AccountId FROM Asset WHERE Name = :asset.Name ORDER BY CreatedDate DESC LIMIT 1];
        role.Account__c = asset.AccountId;
        role.Vehicle__c = asset.Id;
        role.Role__c = 'Current Owner';
        insert role;
        Role__c role2 = new Role__c();
        role2.Account__c = asset.AccountId;
        role2.Vehicle__c = asset.Id;
        role2.Role__c = 'Current Owner';
        insert role2;
        List<Role__c> roles = [SELECT Id, Role__c FROM Role__c WHERE Account__c = :asset.AccountId AND Vehicle__c = :asset.Id AND Role__c = 'qwerty'];
        String testStr = '';
        for(Role__c r : roles){
            testStr += r.Id + ': ' + r.Role__c + ', ';
        }
        System.assertEquals(1, roles.size());
    }
}