/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class VariantResourceDto  extends BaseResourceDto{

    private static final String RESOURCE_TYPE = 'Variant';
    global VariantResourceDto(){
        init();
    }

    private void init(){
        this.Type = RESOURCE_TYPE;
        if (this.Attributes == null){
            this.Attributes = new VariantAttributesDto();
        }
    }

    @AuraEnabled
    global VariantAttributesDto Attributes {get; set;}
}