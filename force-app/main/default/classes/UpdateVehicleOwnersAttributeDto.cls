/**
 * Created by caleb@argologic.com.au on 11/12/2019.
 */

public class UpdateVehicleOwnersAttributeDto
{
    public String ContactName
    {
        get
        {
            return this.ContactNameFirst + ' ' + this.ContactNameLast;
        }
    }
    public String DealerName {get; set;}
    public String DealerCode {get; set;}
    public String InvoiceDate {get; set;}
    public String VehicleIdentificationNumber {get; set;}
    public String VehicleRegistrationNumber {get; set;}
    public String CompanyName {get; set;}
    public String ContactSalutation {get; set;}
    public String ContactNameFirst {get; set;}
    public String ContactNameLast {get; set;}
    public String ContactAddressLine1 {get; set;}
    public String ContactAddressLine2 {get; set;}
    public String ContactAddressLine3 {get; set;}
    public String ContactSuburb {get; set;}
    public String ContactState {get; set;}
    public String ContactPostCode {get; set;}
    public String ContactPhoneHome {get; set;}
    public String ContactPhoneWork {get; set;}
    public String ContactPhoneMobile {get; set;}
    public String ContactEmail {get; set;}

    public static UpdateVehicleOwnersAttributeDto parse(String json)
    {
        return (UpdateVehicleOwnersAttributeDto) System.JSON.deserialize(json, UpdateVehicleOwnersAttributeDto.class);
    }

    public static UpdateVehicleOwnersAttributeDto generateTestData()
    {
        String json =
                '   {'+
                '       "UpdateType": "OWNERSHIPNEW",'+
                '		"DealerName": "Rex Gorell Jaguar",'+
                '		"DealerCode": "2761",'+
                '		"InvoiceDate": "2019-09-10 00:00:00",'+
                '       "VehicleIdentificationNumber": "SAJAB4AV2JCP34186",'+
                '       "VehicleRegistrationNumber": "AXT861",'+
                '       "CompanyName": "Sandshell Pty Ltd",'+
                '		"ContactSalutation": "",'+
                '		"ContactNameFirst": "",'+
                '		"ContactNameLast": "",'+
                '		"ContactAddressLine1": "24 INVERLOCH ROAD",'+
                '		"ContactAddressLine2": "",'+
                '		"ContactAddressLine3": "",'+
                '		"ContactSuburb": "WONTHAGGI",'+
                '		"ContactState": "VIC",'+
                '		"ContactPostCode": "3995",'+
                '		"ContactPhoneHome": "",'+
                '		"ContactPhoneWork": "",'+
                '		"ContactPhoneMobile": "0419388827",'+
                '		"ContactEmail": "arthur.rigby@bigpond.com"'+
                '	}';
        UpdateVehicleOwnersAttributeDto obj = parse(json);
        System.assertNotEquals(null, obj);
        return obj;
    }
}