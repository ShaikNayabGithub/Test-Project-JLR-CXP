/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 16/08/2019.
 */

public with sharing class GetDrivesRequestDto extends SimpleResourceResponseDto{

    @AuraEnabled
    public String ModelId {get; set;}
}