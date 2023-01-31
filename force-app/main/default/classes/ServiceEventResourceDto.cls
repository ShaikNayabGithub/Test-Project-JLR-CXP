public class ServiceEventResourceDto extends BaseResourceDto{
    
    public ServiceEventResourceDto(){
        super();
        init();
    }
    
    private void init(){
        this.Type = 'ServiceEvent';
        if (this.Attributes == null){
            this.Attributes = new ServiceEventAttributesDto();
        }
    }
    public ServiceEventAttributesDto Attributes {get; set;}

}