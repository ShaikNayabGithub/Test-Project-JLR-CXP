public without sharing class HomologationController {
    @AuraEnabled
    public static Product2 updateHomologationFields(String homologationData){
        Product2 productToUpdate = (Product2) JSON.deserialize(homologationData, Product2.class );

        update productToUpdate;

        return productToUpdate;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean checkHomologationManagerPermission(){
        return FeatureManagement.checkPermission('Homologation_Manager');
    }

    
}