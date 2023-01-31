/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 21/10/2019.
 */

global with sharing class GetWelcomePacksResponseDto extends BaseResponseDto{

    public GetWelcomePacksResponseDto(){
        super();
        init();
    }

    public GetWelcomePacksResponseDto(List<Task> tasks, Map<Id, Contact> contacts, Map<Id, Asset> assets, Map<Contact, List<Role__c>> contactToListOfRoles)
    {
        this();
        for (Task t : tasks)
        {
            Contact contact = contacts.get(t.WhoId);
            Asset asset = assets.get(t.WhatId);
            if (contact == null) continue;
            if (asset == null) continue;
            Data.add(new WelcomePackResourceDto(t, contact, asset, contactToListOfRoles.get(contact)));
        }
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<WelcomePackResourceDto>();
        }
    }

    public List<WelcomePackResourceDto> Data {get; set;}
}