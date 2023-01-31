/**
 * Created by GrantMillgate-EasyTe on 27/08/2019.
 */

@RestResource(urlMapping='/v1/contacts/*')
global with sharing class ContactsService {

    @HttpGet
    global static GetContactsResponseDto getContacts(){


        // Reading parameters from URL
        RestRequest restReq = RestContext.request;
        //RestResponse restRes = RestContext.response;
        String id = restReq.params.get('id');
        String nameFirst = restReq.params.get('nameFirst');
        String nameLast = restReq.params.get('nameLast');
        String email = restReq.params.get('email');
        String priority = restReq.params.get('priority');
        GetContactsRequestDto request = new GetContactsRequestDto();
        return ContactsController.getContacts(request);
    }

    @HttpPost
    global static GetContactLoyaltyStatusResponseDto verifyContactLoyaltyStatus(GetContactLoyaltyStatusRequestDto request){
        return ContactsController.getContactLoyaltyStatus(request);
    }
}