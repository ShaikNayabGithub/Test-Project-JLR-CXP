/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 15/11/2019.
 */

public with sharing class CreateActivityResponseDto extends BaseResponseDto{



    private void init(){
        if (this.Data == null){
            this.Data = new List<ActivityResourceDto>();
        }
    }

    public CreateActivityResponseDto(){
        super();
        init();
    }


    public CreateActivityResponseDto(Task task){
        this();
        ActivityResourceDto dto = new ActivityResourceDto();
        dto.Type = 'Task';
        dto.Id = task.Id;
        this.Data.add(dto);
    }

    public CreateActivityResponseDto(Event event){
        this();
        ActivityResourceDto dto = new ActivityResourceDto();
        dto.Type = 'Event';
        dto.Id = event.Id;
        this.Data.add(dto);
    }

    @AuraEnabled
    public List<ActivityResourceDto> Data {get; set;}

}