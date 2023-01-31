/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/09/2019.
 */

public with sharing class GetTrimBadgesResponseDto extends SimpleResourceResponseDto{

    public GetTrimBadgesResponseDto(){
        super();
    }

    public GetTrimBadgesResponseDto(List<AggregateResult> results, SObjectField field){
        super(results, field);
    }

}