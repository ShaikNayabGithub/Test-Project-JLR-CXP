/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 1/11/2019.
 */

global with sharing class CreateRoadsideServiceEventRequestDto extends BaseRequestDto{

    global CreateRoadsideServiceEventRequestDto(){
        super();
        init();
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<RoadsideServiceEventResourceDto>();
        }
    }

    global List<RoadsideServiceEventResourceDto> Data {get; set;}

}