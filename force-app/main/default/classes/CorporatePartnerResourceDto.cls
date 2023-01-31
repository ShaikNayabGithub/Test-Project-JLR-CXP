/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 10/02/2020.
 */

public with sharing class CorporatePartnerResourceDto extends SimpleResourceDto{

    public CorporatePartnerResourceDto(){
        super();
        init();
    }

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new AttributesDto();
        }
    }

    public CorporatePartnerResourceDto(KeyValuePair kvp){
        this();
        this.Id = kvp.Key;
        this.Attributes.Name = kvp.Value;
    }
}