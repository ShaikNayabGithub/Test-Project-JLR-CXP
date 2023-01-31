/**
 * Created by caleb@argologic.com.au on 26/05/2020.
 */

public without sharing class OpportunityInboundController
{
    public static final string OPPORTUNITY_SALE_TYPE = 'New';


    public static CreateOpportunityInboundResponseDto create(CreateOpportunityInboundRequestDto req)
    {
        Savepoint sp = Database.setSavepoint();

        CreateOpportunityInboundAttributeDto attributes = req.Data.Attributes;

        Opportunity opp = new Opportunity();

        opp.Trade_In__c = String.isNotEmpty(attributes.TradeInMake);
        opp.Trade_In_Brand__c = attributes.TradeInMake;
        opp.Trade_in_Model__c = attributes.TradeInModel;
        opp.Trade_in_Model_Year__c = String.ValueOf(attributes.TradeInYear);
        opp.Mileage__c = attributes.TradeInOdometer;
        opp.Trade_in_Color__c = attributes.TradeInColor;
        opp.Type = 'Product';

        // Item info
        List<Vehicle_Specification__c> makes = [
                SELECT Id
                FROM Vehicle_Specification__c
                WHERE Name LIKE :attributes.ItemMake AND RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MAKE LIMIT 1
        ];
        if (makes.size() >= 1) opp.Brand__c = makes[0].Id;
        else
        {
            Database.rollback(sp);
            throw new JlrCustomException('No matching make found');
        }
        List<Vehicle_Specification__c> models = [
                SELECT Id
                FROM Vehicle_Specification__c
                WHERE Name LIKE :attributes.ItemModel
                AND RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MODEL
                AND Is_Australia__c = TRUE
                LIMIT 1
        ];
        if (models.size() >= 1) opp.Primary_Model_Interest__c = models[0].Id;
        else if (attributes.ItemModel != null)
        {
            Database.rollback(sp);
            throw new JlrCustomException('No matching model found');
        }

        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        opp.RecordTypeId = recordTypes.get('Sales_Process_with_RDA').getRecordTypeId();

        opp.Enquiry_Stock_Number__c = attributes.ItemStockNumber;
        opp.Enquiry_Series__c = attributes.ItemSeries;
        opp.Enquiry_Year__c = String.valueOf(attributes.ItemYear);
        opp.Enquiry_Price__c = attributes.ItemPrice;
        opp.Enquiry_Registration_Number__c = attributes.ItemRegistrationNumber;
        opp.Enquiry_Engine_Description__c = attributes.ItemEngineDescription;
        opp.Transmission__c = attributes.ItemTransmission;
        opp.Enquiry_Colour__c = attributes.ItemColour;
        opp.Enquiry_Body_Type__c = attributes.ItemBodyType;
        opp.Enquiry_Fuel_Type__c = attributes.ItemFuelType;
        opp.Enquiry_Odometer__c = attributes.ItemOdometer;
        opp.Enquiry_Url__c = attributes.ItemDetailsUrl;
        opp.VIN__c = attributes.ItemVehicleIdentificationNumber;
        opp.Sale_Type__c = OPPORTUNITY_SALE_TYPE; // hard coded to New as per alex
        if (string.isNotBlank(attributes.ProspectPreferredTestDriveDate))
            opp.Test_Drive_Preferred_Date_Time__c = JlrDateParser.parseStringAsDatetime(attributes.ProspectPreferredTestDriveDate);

        // dealership
        if (attributes.DealerCode == null)
        {
            Database.rollback(sp);
            throw new JlrCustomException('Dealer Code is Required');
        }
        String dealerCode5digit = attributes.DealerCode.leftPad(5, '0');
        List<Account> retailers = [
                SELECT Id, ParentId
                FROM Account
                WHERE ((Dealer_CI_Code__c = :dealerCode5digit AND Dealer_CI_Code_2__c = NULL)
                OR (Dealer_CI_Code__c = NULL AND Dealer_CI_Code_2__c = :dealerCode5digit))
                AND ParentId != NULL
                LIMIT 1
        ];
        Account retailer;
        if (retailers.size() >= 1) retailer = retailers[0];
        else throw new JlrCustomException('no matching dealership found');
        opp.Retailer__c = retailer.Id;

        System.debug('retailerId = ' + retailer.Id);

        opp.Purchase_Type__c = getPurchaseTypeMapped(attributes.PurchaseType);
        opp.Enquiry_Type__c = getEnquiryTypeMapped(attributes.ItemEnquiryType);
        opp.Description = 'Was this vehicle purchased at your retailer? - ' + attributes.RetailingDealer + '\n\n'
        + 'Is there an active VWFS Loan against this vehicle? - ' + attributes.IsVWFS + '\n\n'
        + attributes.Comments;
        opp.Enquiry_Request_Type__c = attributes.RequestType;
        opp.LeadSource = getLeadSourceMapped(attributes.RequestType);

        opp.StageName = 'Qualified';
        opp.Name = attributes.ProspectNameFirst + ' ' + attributes.ProspectNameLast + ' ' + Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('d MMMM yyyy');
        opp.CloseDate = Date.today().addDays(14);
        opp.OwnerId = getDefaultUser(retailer).Id;
        opp.Do_Send_To_Vital__c = true;
        opp.Service_Booked_for_Date__c = JlrDateParser.parseStringAsDate(attributes.ServiceDate);
        opp.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = 'Australia' LIMIT 1].Id;


        if ((attributes.IsVWFS != null && attributes.IsVWFS) || (attributes.RetailingDealer != null && attributes.RetailingDealer))
        {
            if (String.isNotEmpty(attributes.VWFSLoadId))
            {
                List<Contract> contracts =
                [
                        SELECT Id
                        FROM Contract
                        WHERE VWFS_Loan_ID__c = :attributes.VWFSLoadId
                ];
                if (contracts.size() > 0) opp.VWFS_Loan_ID__c = contracts[0].Id;
            }
        }
        if (attributes.RequestType == 'Snoop')
        {
            // as per cxp208
            List<Asset> assets = [
                    SELECT
                            Id,
                            AccountId,
                            Account.RecordType.DeveloperName,
                            Account.Owner.Contact.Account.Dealer_CI_Code__c,
                            Account.Owner.Contact.Account.Dealer_CI_Code_2__c,
                            Account.PersonEmail,
                            Account.LastName,
                            Account.PersonMobilePhone,
                            Account.PersonContactId
                    FROM Asset
                    WHERE VIN__c = :attributes.ItemVehicleIdentificationNumber
            ];
            Asset asset;
            if (assets.size() >= 1) asset = assets[0];
            else throw new JlrCustomException('No asset matching Vin');

            if (personAccountMatches(asset.Account, attributes))
            {
                opp.AccountId = asset.AccountId;
                opp.ContactId = asset.Account.PersonContactId;
                opp.Primary_Contact__c = asset.Account.PersonContactId;
            }
            else if (asset.Account.RecordType.DeveloperName == 'Individual_Golden_Record')
            {
                List<Account> individualAccounts = [
                        SELECT
                                Id,
                                RecordType.DeveloperName,
                                Owner.Contact.Account.Dealer_CI_Code__c,
                                Owner.Contact.Account.Dealer_CI_Code_2__c,
                                PersonEmail,
                                LastName,
                                PersonMobilePhone,
                                PersonContactId
                        FROM Account
                        WHERE Primary_Account__c = :asset.AccountId
                        ORDER BY CreatedDate DESC
                ];

                for (Account acc : individualAccounts)
                {
                    if (personAccountMatches(acc, attributes))
                    {
                        opp.AccountId = acc.Id;
                        opp.ContactId = acc.PersonContactId;
                        opp.Primary_Contact__c = acc.PersonContactId;
                        break;
                    }
                }
            }
            else if (asset.Account.RecordType.DeveloperName == 'Corporate')
            {
                List<Contact> contacts = [
                        SELECT
                                RecordType.DeveloperName,
                                Owner.Account.Dealer_CI_Code__c,
                                Owner.Account.Dealer_CI_Code_2__c,
                                LastName,
                                MobilePhone,
                                Email,
                                Id,
                                AccountId,
                                Account.Name
                        FROM Contact
                        WHERE AccountId = :asset.AccountId
                        ORDER BY CreatedDate DESC
                ];

                for (Contact con : contacts)
                {
                    if (contactMatches(con, attributes))
                    {
                        opp.AccountId = asset.AccountId;
                        opp.ContactId = con.Id;
                        opp.Primary_Contact__c = con.Id;
                        break;
                    }
                }
            }
            else if (asset.Account.RecordType.DeveloperName == 'Corporate_Golden_Record')
            {
                List<Contact> contacts = [
                        SELECT
                                RecordType.DeveloperName,
                                Owner.Account.Dealer_CI_Code__c,
                                Owner.Account.Dealer_CI_Code_2__c,
                                LastName,
                                MobilePhone,
                                Email,
                                Id,
                                AccountId,
                                Account.Name
                        FROM Contact
                        WHERE Account.Primary_Account__c = :asset.AccountId
                        ORDER BY CreatedDate DESC
                ];

                for (Contact con : contacts)
                {
                    if (contactMatches(con, attributes))
                    {
                        opp.AccountId = con.AccountId;
                        opp.ContactId = con.Id;
                        opp.Primary_Contact__c = con.Id;
                        break;
                    }
                }
            }
            if (opp.AccountId == null && opp.ContactId == null && String.isNotBlank(attributes.ProspectNameFirst))
            {
                Account personAccount = createPersonAccount(attributes, retailer, opp.OwnerId);
                opp.AccountId = personAccount.Id;
                opp.Primary_Contact__c = personAccount.PersonContactId;
            }
            else if (opp.AccountId == null && opp.ContactId == null)
            {
                CreateOpportunityInboundResponseDto res = new CreateOpportunityInboundResponseDto();
                return res;
            }
        }
        else
        {
             if (isValidCompanyName(attributes.ProspectCompanyName))
             {
                 Account acc = getAccount(attributes, retailer, opp.OwnerId);
                 Contact con = getContact(attributes, acc);
                 opp.AccountId = acc.Id;
                 opp.Primary_Contact__c = con.Id;
             }
             else
             {
                 Account personAccount = createPersonAccount(attributes, retailer, opp.OwnerId);
                 opp.AccountId = personAccount.Id;
                 opp.ContactId = personAccount.PersonContactId;
                 opp.Primary_Contact__c = personAccount.PersonContactId;
             }
        }

        // update name to contact name if required
        if (opp.AccountId != null)
        {
            Account acc = [SELECT FirstName, LastName, Name, IsPersonAccount FROM Account WHERE Id = :opp.AccountId];
            if (acc.IsPersonAccount)
                opp.Name = acc.FirstName + ' ' + acc.LastName + ' ' + Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('d MMMM yyyy');
            else
                opp.Name = acc.Name + ' ' + Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('d MMMM yyyy');
        }

        insert opp;

        // create activity
        if (attributes.CreateActivity != null && attributes.CreateActivity)
        {
            Task t = new Task();
            t.OwnerId = getDefaultUser(retailer).Id;
            Map<String, Schema.RecordTypeInfo> taskRecordTypes = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName();
            t.RecordTypeId = taskRecordTypes.get('Milestone_Task').getRecordTypeId();
            t.WhatId = opp.Id;
            t.ActivityDate = opp.Service_Booked_for_Date__c.addDays(-1);
            t.Status = 'Not Started';
            t.Priority = 'High';
            t.Subject = 'Service Interception';
            t.Related_Milestone__c = 'Qualification';
            t.Description = 'This task has been created automatically to notify you of a Service Interception opportunity that requires action on';
            t.Description += String.valueOf(opp.Service_Booked_for_Date__c);
            insert t;
        }

        CreateOpportunityInboundResponseDto res = new CreateOpportunityInboundResponseDto();
        res.Id = opp.Id;
        return res;
    }

    public static Boolean personAccountMatches(Account acc, CreateOpportunityInboundAttributeDto attributes)
    {
        return acc.RecordType.DeveloperName == 'Individual'
                && (
                    acc.Owner.Contact.Account.Dealer_CI_Code__c == attributes.DealerCode.leftPad(5, '0')
                    || acc.Owner.Contact.Account.Dealer_CI_Code_2__c == attributes.DealerCode.leftPad(5, '0')
                )
                &&
                (((acc.PersonMobilePhone == attributes.ProspectPhoneMobile
                || acc.PersonMobilePhone == sanitizePhoneNumber(attributes.ProspectPhoneMobile))
                && acc.PersonEmail == attributes.ProspectEmail)
                || (acc.LastName == attributes.ProspectNameLast
                && (acc.PersonMobilePhone == attributes.ProspectPhoneMobile
                || acc.PersonMobilePhone == sanitizePhoneNumber(attributes.ProspectPhoneMobile)))
                || (acc.LastName == attributes.ProspectNameLast
                && acc.PersonEmail == attributes.ProspectEmail)
        );
    }

    public static Boolean contactMatches(Contact con, CreateOpportunityInboundAttributeDto attributes)
    {
        return con.RecordType.DeveloperName == 'Retailer_Contact'
                && (con.Owner.Account.Dealer_CI_Code__c == attributes.DealerCode.leftPad(5, '0')
                || con.Owner.Account.Dealer_CI_Code_2__c == attributes.DealerCode.leftPad(5, '0'))
                && (((con.MobilePhone == attributes.ProspectPhoneMobile
                || con.MobilePhone == sanitizePhoneNumber(attributes.ProspectPhoneMobile))
                && con.Email == attributes.ProspectEmail)
                || (con.Account.Name == attributes.ProspectNameLast
                && (con.MobilePhone == attributes.ProspectPhoneMobile
                || con.MobilePhone == sanitizePhoneNumber(attributes.ProspectPhoneMobile)))
                || (con.Account.Name == attributes.ProspectNameLast
                && con.Email == attributes.ProspectEmail));
    }

    private static Account createPersonAccount(CreateOpportunityInboundAttributeDto attributes, Account retailer, string ownerId)
    {
        // check for an exiting secondary account
        List<Account> matchingPersonAccounts = [
                SELECT
                        Id,
                        PersonContactId
                FROM Account
                WHERE Owner_Retailer__c = :retailer.Id
                AND RecordType.DeveloperName = 'Individual'
                AND (
                        (PersonEmail = :attributes.ProspectEmail AND PersonEmail != NULL)
                        OR (PersonMobilePhone = :attributes.ProspectPhoneMobile AND PersonMobilePhone != NULL)
                        OR (PersonHomePhone = :attributes.ProspectPhoneHome AND PersonHomePhone != NULL)
                        OR (PersonMobilePhone = :sanitizePhoneNumber(attributes.ProspectPhoneMobile) AND PersonMobilePhone != NULL)
                        OR (PersonHomePhone = :sanitizePhoneNumber(attributes.ProspectPhoneHome) AND PersonHomePhone != NULL)
                )
        ];
        if (matchingPersonAccounts.size() > 0) return matchingPersonAccounts[0];

        Account personAccount = new Account();
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        personAccount.RecordTypeId = recordTypes.get('Individual').getRecordTypeId();

        personAccount.PersonTitle = attributes.ProspectTitle;
        personAccount.FirstName = attributes.ProspectNameFirst;
        personAccount.LastName = attributes.ProspectNameLast;

        personAccount.PersonMailingStreet = attributes.ProspectAddressLine1 + '\n' + attributes.ProspectAddressLine2;
        personAccount.PersonMailingCity = attributes.ProspectAddressSuburb;
        personAccount.PersonMailingState = attributes.ProspectAddressState;
        personAccount.PersonMailingPostalCode = attributes.ProspectAddressPostcode;

        personAccount.PersonEmail = attributes.ProspectEmail;
        personAccount.Phone = sanitizePhoneNumber(attributes.ProspectPhoneWork);
        personAccount.PersonMobilePhone = sanitizePhoneNumber(attributes.ProspectPhoneMobile);
        personAccount.PersonHomePhone = sanitizePhoneNumber(attributes.ProspectPhoneHome);
        personAccount.Owner_Retailer__c = retailer.Id;
        personAccount.OwnerId = ownerId;
        personAccount.Preferred_Sales_Retailer__c = retailer.ParentId;

        insert personAccount;
        return personAccount;
    }

    public static Contact getContact(CreateOpportunityInboundAttributeDto attributes, Account acc)
    {
        // todo find matching contact
        List<Contact> matchingContacts = [
                SELECT Id
                FROM Contact
                WHERE AccountId = :acc.Id
                AND RecordType.DeveloperName = 'Retailer_Contact'
                AND (
                        (Email = :attributes.ProspectEmail AND Email != NULL)
                        OR (MobilePhone = :attributes.ProspectPhoneMobile AND MobilePhone != NULL)
                        OR (HomePhone = :attributes.ProspectPhoneHome AND HomePhone != NULL)
                        OR (MobilePhone = :sanitizePhoneNumber(attributes.ProspectPhoneMobile) AND MobilePhone != NULL)
                        OR (HomePhone = :sanitizePhoneNumber(attributes.ProspectPhoneHome) AND HomePhone != NULL)
                )
        ];
        if (matchingContacts.size() > 0) return matchingContacts[0];

        Contact con = new Contact();
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
        con.RecordTypeId = recordTypes.get('Retailer_Contact').getRecordTypeId();
        con.Title = attributes.ProspectTitle;
        con.FirstName = attributes.ProspectNameFirst;
        con.LastName = attributes.ProspectNameLast;

        con.MailingStreet = attributes.ProspectAddressLine1 + '\n' + attributes.ProspectAddressLine2;
        con.MailingCity = attributes.ProspectAddressSuburb;
        con.MailingState = attributes.ProspectAddressState;
        con.MailingPostalCode = attributes.ProspectAddressPostcode;

        con.Email = attributes.ProspectEmail;
        con.Phone = sanitizePhoneNumber(attributes.ProspectPhoneWork);
        con.MobilePhone = sanitizePhoneNumber(attributes.ProspectPhoneMobile);
        con.HomePhone = sanitizePhoneNumber(attributes.ProspectPhoneHome);

        con.AccountId = acc.Id;

        insert con;
        return con;
    }

    private static Boolean isValidCompanyName(string str)
    {
        if (string.isEmpty(str)) return false;
        if (str == 'N/A') return false;
        return true;
    }

    private static String sanitizePhoneNumber(String s)
    {
        if (s == null) return null;
        s = s.replace('-', '');
        if (s.startsWith('0') || s.startsWith('61')|| s.startsWith('+61')) return s;
        else return '0' + s;
    }

    public static Account getAccount(CreateOpportunityInboundAttributeDto attributes, Account retailer, string ownerId)
    {
        List<Account> matchingAccounts = [
                SELECT
                        Id
                FROM Account
                WHERE Name = :attributes.ProspectCompanyName
                AND RecordType.DeveloperName = 'Corporate'
                AND Owner_Retailer__c = :retailer.Id
        ];
        if (matchingAccounts.size() > 0) return matchingAccounts[0];

        Account acc = new Account();
        acc.Name = attributes.ProspectCompanyName;
        acc.Owner_Retailer__c = retailer.Id;
        acc.Preferred_Sales_Retailer__c = retailer.ParentId;
        acc.OwnerId = ownerId;

        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        acc.RecordTypeId = recordTypes.get('Corporate').getRecordTypeId();
        upsert acc;
        return acc;
    }

    public static final string DS_TYPE_NEW = 'NEW';
    public static final string CXP_TYPE_NEW = 'New Vehicle';
    public static final string CXP_TYPE_USED = 'Used Vehicle';

    private static String getPurchaseTypeMapped(string purchaseType)
    {
        if (purchaseType == DS_TYPE_NEW || string.isNotBlank(purchaseType))
        {
             return CXP_TYPE_NEW;
        }
        else
        {
            return CXP_TYPE_USED;
        }
    }

    public static final string DEFAULT_ENQUIRY_TYPE = 'Find & Price Enquiry';
    public static final Map<String, String> ENQUIRY_TYPE_MAP = new Map<String, String>
    {
            'KMI' => 'KMI',
            'BROCHURE' => 'Brochure Request',
            'TD' => 'Test Drive Request',
            'Approved Pre-owned' => 'Approved Pre-owned',
            'Approved Used Vehicle' => 'Approved Used Vehicle',
            'Brochure Request' => 'Brochure Request',
            'e-Brochure' => 'e-Brochure',
            'Find & Price Enquiry' => 'Find & Price Enquiry',
            'Generic' => 'Generic',
            'JLR Event' => 'JLR Event',
            'Mobile Lead' => 'Mobile Lead',
            'Online Reservation' => 'Online Reservation',
            'Personalised Brochure Request' => 'Personalised Brochure Request',
            'Resurrected Lead' => 'Resurrected Lead',
            'Test Drive Request' => 'Test Drive Request',
            'Vehicle Configuration' => 'Vehicle Configuration',
            'Fleet and Business Enquiry' => 'Fleet and Business Enquiry',
            'Service Interception' => 'Service Interception'
    };

    private static String getEnquiryTypeMapped(string enquiryType)
    {
        if (string.isBlank(enquiryType) || !ENQUIRY_TYPE_MAP.containsKey(enquiryType))
        {
            return DEFAULT_ENQUIRY_TYPE;
        }
        else
        {
            return ENQUIRY_TYPE_MAP.get(enquiryType);
        }
    }

    public static final string REQUEST_TYPE_DEALER = 'DEALER';
    public static final string REQUEST_TYPE_OEM = 'OEM';
    public static final string REQUEST_TYPE_SNOOP = 'Snoop';

    public static final string SOURCE_TYPE_DEALER = 'Retailer Website';
    public static final string SOURCE_TYPE_OEM = 'OEM Web & Digital';
    public static final string SOURCE_TYPE_SNOOP = 'Snoop';

    private static String getLeadSourceMapped(String leadSource)
    {
        if (leadSource == REQUEST_TYPE_DEALER)
        {
            // map this to sub type as well
            return SOURCE_TYPE_DEALER;
        }
        else if (leadSource == REQUEST_TYPE_SNOOP)
        {
            return SOURCE_TYPE_SNOOP;
        }
        else if (leadSource == REQUEST_TYPE_OEM)
        {
            return SOURCE_TYPE_OEM;
        }
        return null;
    }

    private static User getDefaultUser(Account childRetailerAccount)
    {
        System.debug('childRetailerAccount.ParentId = ' + childRetailerAccount.ParentId);
        List<User> defaultUsers = [
                SELECT Id
                FROM User
                WHERE Contact.AccountId = :childRetailerAccount.ParentId
                AND Contact.Name LIKE '%Default User%'
        ];
        if (defaultUsers.size() >= 1) return defaultUsers[0];
        throw new JlrCustomException('No Default user found');
    }


}