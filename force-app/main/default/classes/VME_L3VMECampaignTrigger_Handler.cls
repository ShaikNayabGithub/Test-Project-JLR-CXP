/*-------------------------------------------------------------------------------
##Developed By : Rachit Bhargava
##Created Date : 12th. June 2019
##Company : ETMarlabs
##Description : Handler to create bundling on every BASE L3 VME Campaign creation
##Last MOdified Date : 24th June 2019
##Modified By : Sumit Kumar
##Modified Reason : Added a method to rename L3 VME Campaign name formatted //YYQQ-Model-CAT-SubCat-#0001
--------------------------------------------------------------------------------*/
public without sharing class VME_L3VMECampaignTrigger_Handler {
        private static VME_L3VMECampaignTrigger_Handler instance;
        public static VME_L3VMECampaignTrigger_Handler getInstance() {
                if (instance == null) {
                        instance = new VME_L3VMECampaignTrigger_Handler();
                }
                return instance;
        }
        //-- PUBLIC METHODS
        public void onBeforeInsert(final List < VME_Schemes__c > newObjects) {}
        public void onBeforeUpdate(final List < VME_Schemes__c > oldObjects, final Map < Id, VME_Schemes__c > oldObjectsMap, final List < VME_Schemes__c > newObjects, final Map < Id, VME_Schemes__c > newObjectsMap) {}
        public void onAfterUpdate (List < VME_Schemes__c > newObjects, final Map < Id, VME_Schemes__c > newObjectsMap) {
                //this.renameAllSchemes(newObjects, newObjectsMap);
        }
        public void onAfterInsert(final List < VME_Schemes__c > newObjects, final Map < Id, VME_Schemes__c > newObjectsMap) {
                //renaming L3 Scheme based on L2 Category
                this.renameAllSchemes(newObjects, newObjectsMap);
                //after rename create Bundling for Base Scheme
                this.createBundlingForBaseScheme(newObjects, newObjectsMap);
        }
        //--PRIVATE METHODS to rename all scheme  based on some format
        private void renameAllSchemes(final List < VME_Schemes__c > newL3List, final Map < Id, VME_Schemes__c > newL3Map) {
                //set to have L2 ids
                Set<Id> setOfL2Ids = new Set<Id>();
                //iterate l3 list ti get L2 Ids
                for (VME_Schemes__c l3Object : newL3List) {
                        if(l3Object.VME_Campaign__c != null && l3Object.VME_External_Id__c == null){
                                setOfL2Ids.add(l3Object.VME_Campaign__c);
                        }
                }
                Map<Id,String> mapOfL2IdExternalId = new Map<Id, String>();
                if(setOfL2Ids!= null && setOfL2Ids.size() > 0){
                        Map < String, String > getCatSubCatCodeMap = VME_Utility_Class.getCatSubCatCodeMappingForL2();
                        for(VME_Campaign__c vmeL2 : [SELECT Id, Name, VME_Brand__c, VME_Model__c,VME_Model__r.ProductCode, VME_Quarter__c, VME_Fiscal_Year__c, VME_Country__c, VME_Country_ISO_Code__c, VME_Market_Code__c, VME_Category__c, VME_Sub_Category__c FROM VME_Campaign__c WHERE Id IN: setOfL2Ids]) {
                                //YYQQ-Model - CAT-Syb-Cat - #0001
                                //if Category and SubCategory  in L2 is null the External ID will be
                                //YYQQ-Model - null-null - #0001 (20Q2-R8-USC-null-0000000465)
                                String externalL3Id = vmeL2.VME_Fiscal_Year__c.subString(0,2)+vmeL2.VME_Quarter__c+'-'+vmeL2.VME_Model__r.ProductCode+'-'+getCatSubCatCodeMap.get(vmeL2.VME_Category__c+'-C')+'-'+getCatSubCatCodeMap.get(vmeL2.VME_Sub_Category__c+'-SC');
                                mapOfL2IdExternalId.put(vmeL2.Id, externalL3Id);
                        }
                        List < VME_Schemes__c > l3SchemeToUpdate = new List < VME_Schemes__c >();
                        System.debug('SubCatMap :: ' + mapOfL2IdExternalId);
                        for (VME_Schemes__c l3Schm : newL3List) {
                                if(mapOfL2IdExternalId != null && mapOfL2IdExternalId.containsKey(l3Schm.VME_Campaign__c)){
                                        VME_Schemes__c tempScheme = new VME_Schemes__c();
                                        tempScheme.Id = l3Schm.Id;
                                        tempScheme.Name = mapOfL2IdExternalId.get(l3Schm.VME_Campaign__c)+'-'+l3Schm.VME_L3_Name__c;
                                        tempScheme.VME_External_Id__c = mapOfL2IdExternalId.get(l3Schm.VME_Campaign__c)+'-'+l3Schm.VME_L3_Name__c;
                                        l3SchemeToUpdate.add(tempScheme);
                                }
                        }
                        if(l3SchemeToUpdate != null && l3SchemeToUpdate.size() > 0 && Schema.sObjectType.VME_Schemes__c.isCreateable()){
                                Update l3SchemeToUpdate;
                        }
                }
        }
        //--PRIVATE METHODS
        private void createBundlingForBaseScheme(final List < VME_Schemes__c > newObjects, final Map < Id, VME_Schemes__c > newObjectsMap) {
                List < Id > listOfSchemeId = new List < Id > ();
                List < VME_Bundling__c > listOfBundling = new List < VME_Bundling__c > ();
                for (VME_Schemes__c instance: newObjects) {
                        listOfSchemeId.add(instance.id);
                }
                List < VME_Schemes__c > queriedList = new List < VME_Schemes__c > ();
                if (listOfSchemeId != null && listOfSchemeId.size() > 0) {
                        queriedList = [SELECT Id, VME_Scheme_Type__c,VME_Type__c, VME_Campaign__r.VME_Category__c,VME_Campaign__r.VME_Model__c FROM VME_Schemes__c WHERE Id IN: listOfSchemeId];
                }
                for (VME_Schemes__c instance: queriedList) {
                        if (instance.VME_Scheme_Type__c == 'Base' && instance.VME_Type__c != 'Discretionary' && instance.VME_Campaign__r.VME_Category__c != 'Discretionary Support') {
                                VME_Bundling__c instanceOfBundling = new VME_Bundling__c();
                                instanceOfBundling.VME_Scheme__c = instance.Id;
                                instanceOfBundling.VME_Model_Derivative__c = instance.VME_Campaign__r.VME_Model__c;
                                listOfBundling.add(instanceOfBundling);
                        }
                }
                if (listOfBundling != null && listOfBundling.size() > 0) {
                        Database.insert(listOfBundling);
                }
        }
}