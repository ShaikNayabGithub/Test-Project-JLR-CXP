/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

public with sharing class GetVariantsRequestDto extends BaseVariantRequestDto{

    public GetVariantsRequestDto(){
        super();
        init();
    }

    private void init(){
        if (Filters == null){
            Filters = new VariantFilterDto();
        }
    }


    @AuraEnabled
    public VariantFilterDto Filters {get; set;}

    @AuraEnabled
    public String ModelName {get; set;}

    @AuraEnabled
    public String ModelId {get; set;}

}