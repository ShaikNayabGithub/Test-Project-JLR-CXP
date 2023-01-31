/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

public with sharing class ContactsController {

    @AuraEnabled
    public static GetContactsResponseDto getContacts(GetContactsRequestDto request){

        if (String.isNotBlank(request.PersonAccountId))
        {
            List<Contact> contacts = [
                    SELECT id, name, firstname, lastname, Account.Name, IsPersonAccount, MobilePhone, Email, AccountId, Account.RecordType.Name
                    FROM Contact
                    WHERE IsPersonAccount = TRUE AND AccountId = :request.PersonAccountId
            ];
            return new GetContactsResponseDto(ContactTransformer.transform(contacts));
        }
        else if (String.isNotBlank(request.ContactId))
        {
            List<Contact> contacts = [
                    SELECT id, name, firstname, lastname, Account.Name, IsPersonAccount, MobilePhone, Email, AccountId, Account.RecordType.Name
                    FROM Contact
                    WHERE Id = :request.ContactId
            ];
            return new GetContactsResponseDto(ContactTransformer.transform(contacts));
        }
        else
        {
            List<Contact> contacts = [
                    SELECT id, name, firstname, lastname, Account.Name, IsPersonAccount, MobilePhone, Email, AccountId, Account.RecordType.Name
                    FROM Contact];
            return new GetContactsResponseDto(ContactTransformer.transform(contacts));
        }
    }

    @AuraEnabled
    public static GetContactLoyaltyStatusResponseDto getContactLoyaltyStatus(GetContactLoyaltyStatusRequestDto request){
                BaseMulesoftConnector conn = new BaseMulesoftConnector(Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_VALIDATE_QFF);
                String body = (new GetContactsLoyaltyStatusRequestWrapper(request.Contact)).toJson();
                String response = conn.doCallout(HttpMethods.POST, body);
                System.debug(response);
                return new GetContactLoyaltyStatusResponseDto(response);
    }
}