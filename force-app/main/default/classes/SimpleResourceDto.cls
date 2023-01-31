/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global virtual with sharing class SimpleResourceDto extends BaseResourceDto{

    global SimpleResourceDto(){
        init();
    }

    global SimpleResourceDto(Id id, String name){
        this();
        this.Id = id;
        this.Attributes.Name = name;
    }

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new AttributesDto();
        }
    }

    @AuraEnabled
    global AttributesDto Attributes {get; set;}
}