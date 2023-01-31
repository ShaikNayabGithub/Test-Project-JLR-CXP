/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 24/09/2019.
 */

global with sharing class CreateServiceEventResponseDto extends BaseResponseDto
{
    public CreateServiceEventResponseDto(){
        super();
		init();        
    }
    private void init(){
        if (this.Data == null){
            this.Data = new List<ServiceEventResourceDto>();
        }
        if (this.Errors == null){
            this.Errors = new List<ErrorDto>();
        }
    }

    public List<ServiceEventResourceDto> Data {get; set;}
}