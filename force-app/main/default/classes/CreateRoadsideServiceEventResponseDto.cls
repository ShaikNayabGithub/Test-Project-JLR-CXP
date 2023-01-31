/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 1/11/2019.
 */

global with sharing class CreateRoadsideServiceEventResponseDto extends BaseResponseDto{

    global CreateRoadsideServiceEventResponseDto(){
        super();
        init();
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<RoadsideServiceEventResourceDto>();
        }
    }

    global CreateRoadsideServiceEventResponseDto(List<RoadsideServiceEventResourceDto> data){
        this();
        this.Data = data;
    }

    global List<RoadsideServiceEventResourceDto> Data {get; set;}

}