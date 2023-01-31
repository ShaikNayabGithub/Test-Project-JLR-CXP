/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 16/08/2019.
 */

public with sharing class GetDrivesResponseDto extends SimpleResourceResponseDto {

    public GetDrivesResponseDto(){
        super();
    }

    public GetDrivesResponseDto(List<AggregateResult> results, SObjectField field){
        super(results, field);
    }

}