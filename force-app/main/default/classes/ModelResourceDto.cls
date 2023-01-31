/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 13/08/2019.
 */

public with sharing class ModelResourceDto extends BaseResourceDto{

    public ModelResourceDto(){
        this.Attributes = new AttributesDto();
    }

    public ModelResourceDto(Id theId, String nm){
        this();
        this.Id = String.valueOf(theId);
        this.Attributes.Name = nm;
    }

    public ModelResourceDto(Id theId, String nm, String year){
        this();
        this.Id = String.valueOf(theId);
        this.Attributes.Name = nm;

    }

    @AuraEnabled
    public AttributesDto Attributes {get; set;}
}