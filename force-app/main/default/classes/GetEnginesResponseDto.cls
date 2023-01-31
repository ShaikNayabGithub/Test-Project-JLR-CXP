/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 14/08/2019.
 */

public with sharing class GetEnginesResponseDto extends SimpleResourceResponseDto{

    public GetEnginesResponseDto(){
        super();
    }

    public GetEnginesResponseDto(List<AggregateResult> results, SObjectField field){
        super(results, field);
    }

}