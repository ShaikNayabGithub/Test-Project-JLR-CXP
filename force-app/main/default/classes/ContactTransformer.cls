/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

public with sharing class ContactTransformer {

    public static ContactResourceDto transform(Contact con){
        ContactResourceDto dto = new ContactResourceDto();
        dto.Id = con.Id;
        dto.Type = 'Contact';
        dto.Attributes = new ContactAttributesDto();
        dto.Attributes.Name = con.Name;
        dto.Attributes.NameFirst = con.FirstName;
        dto.Attributes.NameLast = con.LastName;
        dto.Attributes.NameCompany = con.Account.Name;
        dto.Attributes.IsPersonAccount = con.IsPersonAccount;
        dto.Attributes.PhoneMobile = con.MobilePhone;
        dto.Attributes.Email = con.Email;
        dto.Attributes.AccountId = con.AccountId;
        dto.Attributes.IsCorporateContact = Constants.ACCOUNT_RECORD_TYPES_CORPORATE.contains(con.Account.RecordType.Name);
        //Todo JRL-131 - need real QFF number
        dto.Attributes.QantasFrequentFlyerNumber = '';
        return dto;
    }

    public static List<ContactResourceDto> transform (List<Contact> cons){
        List<ContactResourceDto> dtos = new List<ContactResourceDto>();
        For(Contact con : cons){
            dtos.add(transform(con));
        }
        return dtos;
    }
}