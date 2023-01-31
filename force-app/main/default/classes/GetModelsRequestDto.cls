/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 13/08/2019.
 */

public with sharing class GetModelsRequestDto extends BaseVariantRequestDto{

    public GetModelsRequestDto(){

    }

    public GetModelsRequestDto(String makeId){
            this.MakeId = makeId;
    }

    @AuraEnabled
    public String MakeId {get; set;}
}