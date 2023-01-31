/**
 * Created by caleb on 26/04/2022.
 */

@RestResource(UrlMapping='/v1/OSBGetAssets/*')
global without sharing class OSBService
{
    global class ResponseDto
    {
        public String Vin {get; set;}
        public String Rego {get; set;}
        public String ModelYear {get; set;}
        public String Make {get; set;}
        public String Model {get; set;}
    }

    @HttpPost
    global static List<OSBService.ResponseDto> post(String PhoneNumber, String RegistrationNumber)
    {
        if (PhoneNumber != null && PhoneNumber.startsWith('+614'))
        {
            PhoneNumber = PhoneNumber.replace('+614', '04');
        }

        List<Asset> assets = [
                SELECT VIN__c, Registration_Number__c, Derivative__r.Model_Year_Alternative_CXP__c, Brand__r.Name, Model__r.Model_Alternative__c
                FROM Asset
                WHERE (Registration_Number__c = :RegistrationNumber AND Registration_Number__c != NULL AND Registration_Number__c != '' AND Account.Country_ISO_Code__c = 'AU')
                OR (Account.Phone = :PhoneNumber AND Account.Phone != NULL AND Account.Phone != '' AND Account.Country_ISO_Code__c = 'AU')
                OR (Account.IsPersonAccount = TRUE AND Account.PersonMobilePhone = :PhoneNumber AND Account.PersonMobilePhone != NULL AND Account.PersonMobilePhone != '' AND Account.Country_ISO_Code__c = 'AU')
                OR (Account.IsPersonAccount = FALSE AND Key_Contact__r.MobilePhone = :PhoneNumber AND Key_Contact__r.MobilePhone != NULL AND Key_Contact__r.MobilePhone != '' AND Account.Country_ISO_Code__c = 'AU')
        ];

        List<OSBService.ResponseDto> response = new List<OSBService.ResponseDto>();
        for (Asset ass : assets)
        {
            OSBService.ResponseDto res = new OSBService.ResponseDto();
            res.Vin = ass.VIN__c;
            res.Rego = ass.Registration_Number__c;
            res.ModelYear = ass.Derivative__r.Model_Year_Alternative_CXP__c == null ? null : ass.Derivative__r.Model_Year_Alternative_CXP__c.replaceAll('[^0-9]', '');
            res.Make = ass.Brand__r.Name;
            res.Model = ass.Model__r.Model_Alternative__c;
            response.add(res);
        }
        return response;
    }
}