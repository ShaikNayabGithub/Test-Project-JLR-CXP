/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 14/08/2019.
 */

public with sharing class GetModelYearsResponseDto extends SimpleResourceResponseDto{

    public GetModelYearsResponseDto(){
        super();
    }

    public GetModelYearsResponseDto(List<AggregateResult> results, SObjectField field){
        super(results, field);
    }
}