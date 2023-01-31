/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/09/2019.
 */

public with sharing class GetTrimBadgesRequestDto {

    @AuraEnabled
    public string ModelId {get; set;}

}