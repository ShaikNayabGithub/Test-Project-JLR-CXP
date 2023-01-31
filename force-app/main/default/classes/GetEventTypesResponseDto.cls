/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 17/11/2019.
 */

public with sharing class GetEventTypesResponseDto {

    @AuraEnabled
    public List<String> Data {get; set;}
}