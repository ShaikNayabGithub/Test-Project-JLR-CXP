/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 16/08/2019.
 */

public with sharing class GetTransmissionsResponseDto extends SimpleResourceResponseDto{

    public GetTransmissionsResponseDto(){
        super();
    }

    public GetTransmissionsResponseDto(List<AggregateResult> results, SObjectField field){
        super(results, field);
    }
}