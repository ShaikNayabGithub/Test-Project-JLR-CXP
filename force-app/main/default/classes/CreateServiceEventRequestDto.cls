/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 24/09/2019.
 */

global with sharing class CreateServiceEventRequestDto
{
    public CreateServiceEventRequestDto(){
        init();
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<ServiceEventResourceDto>();
        }
    }

    public List<ServiceEventResourceDto> Data {get; set;}
}