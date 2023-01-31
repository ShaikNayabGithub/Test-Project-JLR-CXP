public virtual with sharing class SimpleResourceResponseDto extends BaseResponseDto{

    public SimpleResourceResponseDto(){
        super();
        init();
    }

    public SimpleResourceResponseDto(List<AggregateResult> results, SObjectField field){
        this();
        For (AggregateResult result : results){
            SimpleResourceDto dto = new SimpleResourceDto();
            String resource = (String)result.get(field.getDescribe().getName());
            if (String.isNotBlank(resource)){
                dto.Attributes.Name = resource;
                //dto.Id = engine.Id;
                this.Data.add(dto);
            }
        }
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<SimpleResourceDto>();
        }
    }

    @AuraEnabled
    public List<SimpleResourceDto> Data {get; set;}
}