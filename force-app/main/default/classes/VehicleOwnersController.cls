/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019.
 */

public with sharing class VehicleOwnersController {

    public static final String ASSET_ROLE_CURRENT_OWNER = 'Current Owner';
    public static final String ASSET_ROLE_PREVIOUS_OWNER = 'Previous Owner';
    public static final Integer MAX_ASSET_QUERY_LIMIT_DEFAULT = 10000;

    @AuraEnabled
    public static GetVehicleOwnersResponseDto getVehicleOwners(GetVehicleOwnersRequestDto request)
    {
        List<Role__c> modifiedAssetRoles = [
                SELECT
                        Export_Number__c,
                        Vehicle__c,
                        CreatedDate,
                        LastModifiedDate,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Account__r.Name,
                        Contact__r.Title,
                        Account__r.BillingStreet,
                        Account__r.BillingCity,
                        Account__r.BillingState,
                        Account__r.BillingPostalCode,
                        Account__r.BillingCountry,
                        Contact__r.Account.BillingStreet,
                        Contact__r.Account.BillingCity,
                        Contact__r.Account.BillingState,
                        Contact__r.Account.BillingPostalCode,
                        Contact__r.Account.BillingCountry,
                        Contact__r.MailingStreet,
                        Contact__r.MailingCity,
                        Contact__r.MailingState,
                        Contact__r.MailingPostalCode,
                        Contact__r.MailingCountry,
                        Account__r.ShippingStreet,
                        Account__r.ShippingCity,
                        Account__r.ShippingState,
                        Account__r.ShippingPostalCode,
                        Account__r.ShippingCountry,
                        Account__r.IsPersonAccount,
                        Account__r.Phone,
                        Account__r.Dealer_CI_Code__c,
                        Account__r.Dealer_CI_Code_2__c,
                        Account__r.RecordType.Name,
                        Contact__r.HomePhone,
                        Contact__r.MobilePhone,
                        Contact__r.Email,
                        Contact__r.Email2__c,
                        Contact__r.Email3__c,
                        Contact__r.LastModifiedDate,
                        Account__r.LastModifiedDate,

                        Contact__r.HasOptedOutOfEmail,
                        Contact__r.Direct_Mail_Opt_Out__c,
                        Contact__r.Retailer__r.Dealer_CI_Code__c,
                        Contact__r.Retailer__r.Dealer_CI_Code_2__c,
                        Contact__r.Account.Name,
                        
                        Vehicle__r.Id,
                        Vehicle__r.Name,
                        Vehicle__r.LastModifiedDate,
                        Vehicle__r.CreatedDate,
                        Vehicle__r.Derivative__r.ProductCode,
                        Vehicle__r.Derivative__r.Product_Description__c,
                        Vehicle__r.VIN__c,
                        Vehicle__r.Brand__r.Name,
                        Vehicle__r.Model__r.Name,
                        Vehicle__r.Derivative__r.Name,
                        Vehicle__r.Derivative__r.Description,
                        Vehicle__r.Warranty_Start_Date__c,
                        Vehicle__r.Vehicle_Initial_Registration_Date__c,
                        Vehicle__r.Registration_Number__c,
                        Vehicle__r.Retailer_Name__r.Primary_Dealer_Code__c,
                        Vehicle__r.Retailer_Name__r.Name,
                        Vehicle__r.ProductCode,
                        Vehicle__r.Derivative__r.Model_Alternative__c,
                        Account__r.Id,
                        Contact__r.Id,
                        Contact__r.IsPersonAccount
                FROM Role__c
                WHERE Account__r.Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
                AND Role__c = :ASSET_ROLE_CURRENT_OWNER
                AND Account__c != null
                AND Contact__c != null
                AND (
                        Contact__r.Vehicle_Owner_Date_Last_Changed__c >= :request.DateStart
                        OR Account__r.Vehicle_Owner_Date_Last_Changed__c >= :request.DateStart
                        OR CreatedDate >= :request.DateStart
                )
                AND Export_Number__c >= :request.StartNumber.leftPad(10, '0')
                ORDER BY Export_Number__c
                LIMIT 200
        ];

        /*
         person account  account.billing account.shipping
         corpo account   contact.mailing
         */

        GetVehicleOwnersResponseDto response = new GetVehicleOwnersResponseDto(modifiedAssetRoles, request.DateStart);
        if (modifiedAssetRoles.size() == 0)
            response.ExportNumber = '-1';
        else
            response.ExportNumber = String.valueOf(Integer.valueOf(modifiedAssetRoles[modifiedAssetRoles.size() - 1].Export_Number__c) + 1);
        response.NPages = (Integer)Math.ceil(Decimal.valueOf([
                SELECT
                        COUNT()
                FROM Role__c
                WHERE Account__r.Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
                AND Role__c = :ASSET_ROLE_CURRENT_OWNER
                AND Account__c != null
                AND Contact__c != null
                AND (
                        Contact__r.Vehicle_Owner_Date_Last_Changed__c >= :request.DateStart
                        OR Account__r.Vehicle_Owner_Date_Last_Changed__c >= :request.DateStart
                        OR CreatedDate >= :request.DateStart
                )
        ]) / 200.0);
        return response;
    }

    public static void UpdateImportantInfoHasChangedOnAccount(List<Account> news, Map<Id, Account> oldMap)
    {
        for (Account xnew : news)
        {
            Account old = oldMap.get(xnew.Id);
            Boolean res = old.Name != xnew.Name
                    || old.FirstName!= xnew.FirstName
                    || old.LastName != xnew.LastName
                    || old.BillingStreet != xnew.BillingStreet
                    || old.BillingCity != xnew.BillingCity
                    || old.BillingState != xnew.BillingState
                    || old.BillingPostalCode != xnew.BillingPostalCode
                    || old.BillingCountry != xnew.BillingCountry
                    || old.ShippingStreet != xnew.ShippingStreet
                    || old.ShippingCity != xnew.ShippingCity
                    || old.ShippingState != xnew.ShippingState
                    || old.ShippingPostalCode != xnew.ShippingPostalCode
                    || old.ShippingCountry != xnew.ShippingCountry
                    || old.Phone != xnew.Phone
                    || old.RecordTypeId != xnew.RecordTypeId
                    || old.PersonTitle != xnew.PersonTitle
                    || old.PersonMailingStreet != xnew.PersonMailingStreet
                    || old.PersonMailingCity != xnew.PersonMailingCity
                    || old.PersonMailingState != xnew.PersonMailingState
                    || old.PersonMailingPostalCode != xnew.PersonMailingPostalCode
                    || old.PersonMailingCountry != xnew.PersonMailingCountry
                    || old.PersonEmail != xnew.PersonEmail
                    || old.PersonHomePhone != xnew.PersonHomePhone
                    || old.PersonMobilePhone != xnew.PersonMobilePhone
                    || old.Email2__pc != xnew.Email2__pc
                    || old.Email3__pc != xnew.Email3__pc;
            if (res)
            {
                xnew.Vehicle_Owner_Date_Last_Changed__c = Datetime.now();
            }
        }
    }

    public static void UpdateImportantInfoHasChangedOnContact(List<Contact> news, Map<Id, Contact> oldMap)
    {
        for (Contact xnew : news)
        {
            Contact old = oldMap.get(xnew.Id);
            Boolean res = old.Name != xnew.Name
                    || old.FirstName != xnew.FirstName
                    || old.LastName != xnew.LastName
                    || old.Title != xnew.Title
                    || old.Account?.BillingStreet != xnew.Account?.BillingStreet
                    || old.Account?.BillingCity != xnew.Account?.BillingCity
                    || old.Account?.BillingState != xnew.Account?.BillingState
                    || old.Account?.BillingPostalCode != xnew.Account?.BillingPostalCode
                    || old.Account?.BillingCountry != xnew.Account?.BillingCountry
                    || old.MailingStreet != xnew.MailingStreet
                    || old.MailingCity != xnew.MailingCity
                    || old.MailingState != xnew.MailingState
                    || old.MailingPostalCode != xnew.MailingPostalCode
                    || old.MailingCountry != xnew.MailingCountry
                    || old.Email != xnew.Email
                    || old.Email2__c != xnew.Email2__c
                    || old.Email3__c != xnew.Email3__c
                    || old.Account?.Name != xnew.Account?.Name
                    || old.HomePhone != xnew.HomePhone
                    || old.MobilePhone != xnew.MobilePhone;
            if (res)
            {
                xnew.Vehicle_Owner_Date_Last_Changed__c = Datetime.now();
            }
        }
    }

    /*
    public static UpdateVehicleOwnersResponseDto updateVehicleOwner(UpdateVehicleOwnersRequestDto request)
    {
        UpdateVehicleOwnersResponseDto response = new UpdateVehicleOwnersResponseDto();
        if (request.Data.size() > 20)
        {
            ErrorDto err = new ErrorDto();
            err.Detail = 'Too manny records ' + request.Data.size() + ' this resource accepts a maximum of 20 records';
            response.addError(err);
            return response;
        }
        // get all assets associated with the given vin
        List<String> vins = new List<String>();
        for (UpdateVehicleOwnersResourceDto resource : request.Data)
        {
            vins.add(resource.Attributes.VehicleIdentificationNumber);
        }
        List<Asset> assets = [
                SELECT
                        Id,
                        VIN__c,
                        (
                            SELECT
                                    Id,
                                    Role__c
                            FROM Roles__r
                        )
                FROM Asset WHERE VIN__c IN :vins
        ];
        // generate a map of all vins to assets
        Map<String, Asset> vinToAssetMap = new Map<String, Asset>();
        for (Asset a : assets)
        {
            vinToAssetMap.put(a.VIN__c, a);
        }
        // add errors for any asset that is not found
        for (String vin : vins)
        {
            if (!vinToAssetMap.containsKey(vin))
            {
                ErrorDto err = new ErrorDto();
                err.Detail = 'Asset with vin = ' + vin + ' could not be found';
                response.addError(err);
            }
        }

        // try to match the contact
        Map<String, Contact> vinToContactMap = getVinToContactMap(request);
        Map<String, Account> dealerCodeToDealerMap = getDealerCodeToDealerMap(request);
        // update and add all asset roles
        Map<Id, Role__c> rolesToUpdate = new Map<Id, Role__c>();
        Map<Id, Role__c> rolesToInsert = new Map<Id, Role__c>();
        Map<Id, Asset> assetsToUpdate = new Map<Id, Asset>();
        for (UpdateVehicleOwnersResourceDto resource : request.Data)
        {
            Asset a = vinToAssetMap.get(resource.Attributes.VehicleIdentificationNumber);
            if (resource.OwnershipType == UpdateVehicleOwnersResourceDto.OwnerType.NewOwner)
            {
                if (vinToContactMap.containsKey(resource.Attributes.VehicleIdentificationNumber))
                {
                    rolesToUpdate.putAll(endOwnership(a));
                    Role__c newOwnerRole = addOwnership(a, vinToContactMap.get(resource.Attributes.VehicleIdentificationNumber));
                    rolesToInsert.put(newOwnerRole.Id, newOwnerRole);
                    a.Last_Date_Change_of_Ownership__c = Date.today();
                    a.AccountId = vinToContactMap.get(resource.Attributes.VehicleIdentificationNumber).AccountId;
                    assetsToUpdate.put(a.Id, a);
                }
                else
                {
                    // add error if contact not found
                    ErrorDto err = new ErrorDto();
                    err.Detail = 'Contact with Name = ' + resource.Attributes.ContactName + ', Email = ' + resource.Attributes.ContactEmail + ' could not be found';
                    response.addError(err);
                }
            }
            else if (resource.OwnershipType == UpdateVehicleOwnersResourceDto.OwnerType.EndOfOwnership)
            {
                rolesToUpdate.putAll(endOwnership(a));
                a.Last_Date_Change_of_Ownership__c = Date.today();
                assetsToUpdate.put(a.Id, a);
            }
            // update dealer on asset
            if (resource.Attributes.DealerCode != null && dealerCodeToDealerMap.containsKey(resource.Attributes.DealerCode.leftPad(5, '0')))
            {
                String dealerCode5Digit = resource.Attributes.DealerCode.leftPad(5, '0');
                a.Retailer_Name__c = dealerCodeToDealerMap.get(dealerCode5Digit).Id;
                assetsToUpdate.put(a.Id, a);
            }
            else
            {
                // add error if contact not found
                ErrorDto err = new ErrorDto();
                err.Detail = 'Dealer with DealerCode = ' + resource.Attributes.DealerCode + ' could not be found';
                response.addError(err);
            }
        }
        update rolesToUpdate.values();
        insert rolesToInsert.values();
        update assetsToUpdate.values();
        return response;
    }

    private static Role__c addOwnership(Asset asset, Contact contact)
    {
        // adds a new current owner role to the asset
        Role__c role = new Role__c();
        role.Contact__c = contact.Id;
        role.Account__c = contact.AccountId;
        role.Vehicle__c = asset.Id;
        role.Role__c = ASSET_ROLE_CURRENT_OWNER;
        role.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        return role;
    }

    private static List<Role__c> endOwnership(Asset asset)
    {
        // updates all current owner asset roles to previous owner
        List<Role__c> roles = asset.Roles__r;
        List<Role__c> currentOwnerRoles = new List<Role__c>();
        for (Role__c r : roles)
        {
            if (r.Role__c == ASSET_ROLE_CURRENT_OWNER)
            {
                currentOwnerRoles.add(r);
            }
        }
        // change all current owner roles to previous owner
        for (Role__c r : currentOwnerRoles)
        {
            r.Role__c = ASSET_ROLE_PREVIOUS_OWNER;
        }
        return currentOwnerRoles;
    }

    private static Map<String, Contact> getVinToContactMap(UpdateVehicleOwnersRequestDto request)
    {
        Map<String, String> emailsToVin = new Map<String, String>();
        Map<String, String> mobilesToVin = new Map<String, String>();
        Map<String, String> namesToVin = new Map<String, String>();
        for (UpdateVehicleOwnersResourceDto resource : request.Data)
        {
            if (String.isNotBlank(resource.Attributes.ContactEmail))
            {
                emailsToVin.put(resource.Attributes.ContactEmail, resource.Attributes.VehicleIdentificationNumber);
            }
            if (String.isNotBlank(resource.Attributes.ContactPhoneMobile))
            {
                mobilesToVin.put(resource.Attributes.ContactPhoneMobile, resource.Attributes.VehicleIdentificationNumber);
            }
            if (String.isNotBlank(resource.Attributes.ContactName))
            {
                namesToVin.put(resource.Attributes.ContactName, resource.Attributes.VehicleIdentificationNumber);
            }
        }

        // first try match by email, mobile and name
        List<Contact> contacts = [
                SELECT
                        Id,
                        AccountId,
                        Name,
                        Email,
                        MobilePhone
                FROM Contact WHERE
                    Email IN :emailsToVin.keySet() OR
                    MobilePhone IN :mobilesToVin.keySet() OR
                    Name IN :namesToVin.keySet()
        ];
        // generate Vin To Contact Map
        Map<String, Contact> vinContactMap = new Map<String, Contact>();
        for (Contact con : contacts)
        {
            // find the corresponding vin for this contact
            String vin = null;
            if (namesToVin.containsKey(con.Name)) vin = namesToVin.get(con.Name);
            if (emailsToVin.containsKey(con.Email)) vin = emailsToVin.get(con.Email);
            if (mobilesToVin.containsKey(con.MobilePhone)) vin = mobilesToVin.get(con.MobilePhone);

            if (vin != null) vinContactMap.put(vin, con);
        }
        return vinContactMap;
    }

    public static Map<String, Account> getDealerCodeToDealerMap(UpdateVehicleOwnersRequestDto request)
    {
        List<String> dealerCodes5digit = new List<String>();
        for (UpdateVehicleOwnersResourceDto resource : request.Data)
        {
            dealerCodes5digit.add(resource.Attributes.DealerCode.leftPad(5, '0'));
        }

        List<Account> dealers =
        [
                SELECT
                        Id,
                        Dealer_CI_Code__c,
                        Dealer_CI_Code_2__c
                FROM Account
                WHERE Dealer_CI_Code_2__c IN :dealerCodes5digit OR Dealer_CI_Code__c IN :dealerCodes5digit
        ];
        Map<String, Account> codeToDealerMap = new Map<String, Account>();
        for (Account dealer : dealers)
        {
            if (dealerCodes5digit.contains(dealer.Dealer_CI_Code__c))
            {
                codeToDealerMap.put(dealer.Dealer_CI_Code__c, dealer);
            }
            else
            {
                codeToDealerMap.put(dealer.Dealer_CI_Code_2__c, dealer);
            }
        }
        return codeToDealerMap;
    }
    */
}