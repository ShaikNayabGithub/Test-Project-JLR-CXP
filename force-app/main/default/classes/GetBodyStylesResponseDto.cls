/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 14/08/2019.
 */

public with sharing class GetBodyStylesResponseDto extends SimpleResourceResponseDto{

    public GetBodyStylesResponseDto(){
        super();
    }

    public GetBodyStylesResponseDto(List<AggregateResult> results, SObjectField field){
        super(results, field);
    }
}