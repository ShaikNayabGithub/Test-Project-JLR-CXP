/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 1/11/2019.
 */

global with sharing class RoadsideServiceEventResourceDto extends  BaseResourceDto{
    global RoadsideServiceEventResourceDto(){
        super();
        init();
    }

    private void init(){
        this.Type = 'RoadsideServiceEvent';
        if (this.Attributes == null){
            this.Attributes = new RoadsideServiceEventAttributesDto();
        }
    }
    global RoadsideServiceEventAttributesDto Attributes {get; set;}
}