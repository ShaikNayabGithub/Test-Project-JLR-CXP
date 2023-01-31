/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 14/08/2019.
 */

public with sharing class GetBodyStylesRequestDto {

    @AuraEnabled
    public String ModelId {get; set;}
}