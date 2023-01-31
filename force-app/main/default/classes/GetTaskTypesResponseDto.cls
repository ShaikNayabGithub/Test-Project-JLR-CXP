/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 17/11/2019.
 */

public with sharing class GetTaskTypesResponseDto {

    @AuraEnabled
    public List<String> Data {get; set;}
}