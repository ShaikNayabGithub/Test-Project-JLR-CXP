/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 22/08/2019.
 *
 * This class will be extended depending of the attributes required by each resource.
 */

global with sharing virtual class AttributesDto {

    @AuraEnabled
    global String Name {get; set;}
}