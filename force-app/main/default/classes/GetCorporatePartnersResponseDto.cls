/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/11/2019.
 */

global with sharing class GetCorporatePartnersResponseDto extends BaseResponseDto{

    global GetCorporatePartnersResponseDto(){
        super();
        init();
    }

    global GetCorporatePartnersResponseDto(Map<Id,String> vals){
        this();
        for(Id key : vals.keySet()){
            KeyValuePair kvp = new KeyValuePair();
            kvp.Key = key;
            kvp.Value = vals.get(key);
            this.Data.add(new CorporatePartnerResourceDto(kvp));
        }
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<CorporatePartnerResourceDto>();
        }
    }

    @AuraEnabled
    global List<CorporatePartnerResourceDto> Data {get; set;}
}