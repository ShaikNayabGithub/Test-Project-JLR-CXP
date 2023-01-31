/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 12/08/2019.
 */

public with sharing class MakeResourceDto extends SimpleResourceDto {

    private static final String RESOURCE_TYPE = 'Make';

    public MakeResourceDto(){
        super();
        this.Type = RESOURCE_TYPE;
    }

    public MakeResourceDto(String id, String nm){
        this();
        this.Id = id;
        this.Attributes.Name = nm;
    }

    public MakeResourceDto(Id id, String nm){
        this();
        this.Id = String.valueOf(id);
        this.Attributes.Name = nm;
    }

}