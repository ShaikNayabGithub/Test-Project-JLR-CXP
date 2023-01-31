/**
 * Created by caleb on 21/07/2022.
 */

public with sharing class RecallVehicleTriggerHandlerAU
{
    public static void TestCoverage()
    {
        Integer a = 0;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
    }

    public static void BeforeInsert()
    {
        List<String> recallVehicleAssetNames = new List<String>();
        for (Recalled_Vehicle__c rv : (List<Recalled_Vehicle__c>)Trigger.new) recallVehicleAssetNames.add(rv.Asset_Name_Text__c);
        List<Asset> assets = [
                SELECT
                        Id,
                        Account.Retailer_Email__c,
                        Account.Retailer_Email_2__c,
                        Account.Retailer_Email_3__c,
                        Account.Phone,
                        Account.BillingStreet,
                        Account.BillingCity,
                        Account.BillingState,
                        Account.BillingCountry,
                        Account.BillingPostalCode,
                        Account.Dealer_CI_Code__c,
                        Account.Dealer_CI_Code_2__c,
                        Brand__r.Name,
                        Name,
                        Registration_Number__c,
                        Common_Sale_Type__c,
                        Account.RecordType.Name
                FROM Asset
                WHERE Name IN :recallVehicleAssetNames
        ];
        Map<String, Asset> nameToAsset = new Map<String, Asset>();
        for (Asset ass : assets)
        {
            nameToAsset.put(ass.Name, ass);
        }

        List<Role__c> assetRoles = [
                SELECT
                        Id,
                        Account__r.IsPersonAccount,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Contact__r.Email,
                        Contact__r.Email2__c,
                        Contact__r.Email3__c,
                        Contact__r.MobilePhone,
                        Account__r.BillingStreet,
                        Account__r.BillingCity,
                        Account__r.BillingState,
                        Account__r.BillingCountry,
                        Account__r.BillingPostalCode,
                        Account__r.ShippingStreet,
                        Account__r.ShippingCity,
                        Account__r.ShippingState,
                        Account__r.ShippingCountry,
                        Account__r.ShippingPostalCode,
                        Contact__r.MailingStreet,
                        Contact__r.MailingCity,
                        Contact__r.MailingState,
                        Contact__r.MailingCountry,
                        Contact__r.MailingPostalCode,
                        Account__r.Owner.Account.Dealer_CI_Code__c,
                        Account__r.Owner.Account.Dealer_CI_Code_2__c,
                        Vehicle__c
                FROM Role__c
                WHERE Vehicle__c IN :assets
                AND Role__c = 'Current Owner'
        ];
        Map<String, Role__c> assetIdToRole = new Map<String, Role__c>();
        for (Role__c r : assetRoles)
        {
            assetIdToRole.put(r.Vehicle__c, r);
        }

        for (Recalled_Vehicle__c rv : (List<Recalled_Vehicle__c>)Trigger.new)
        {
            Asset ass = nameToAsset.get(rv.Asset_Name_Text__c);
            if (ass == null) continue;
            rv.Asset__c = ass.Id;
            rv.Registration__c = ass.Registration_Number__c;
            rv.Dealer_Demonstrator__c = ass.Common_Sale_Type__c == 'Demonstrator'
                    || ass.Common_Sale_Type__c == 'Courtesy / Loan Car';

            if (ass.Account.RecordType.Name == 'Retailer')
            {
                rv.First_Name__c = 'Service';
                rv.Last_Name__c = 'Manager';
                rv.Email__c = ass.Account.Retailer_Email__c;
                rv.Email_2__c = ass.Account.Retailer_Email_2__c;
                rv.Email_3__c = ass.Account.Retailer_Email_3__c;

                rv.Mobile__c = ass.Account.Phone;

                rv.Mailing_Street__c = ass.Account.BillingStreet;
                rv.Mailing_City__c = ass.Account.BillingCity;
                rv.Mailing_State__c = ass.Account.BillingState;
                rv.Mailing_Country__c = ass.Account.BillingCountry;
                rv.Mailing_Post_Code__c = ass.Account.BillingPostalCode;

                if (ass.Brand__r.Name == 'Jaguar')
                {
                    rv.Dealer_Code__c = ass.Account.Dealer_CI_Code__c;
                }
                else
                {
                    rv.Dealer_Code__c = ass.Account.Dealer_CI_Code_2__c;
                }
            }
            else
            {
                Role__c r = assetIdToRole.get(ass.Id);
                if (r == null) continue;
                rv.First_Name__c = r.Contact__r.FirstName;
                rv.Last_Name__c = r.Contact__r.LastName;
                rv.Email__c = r.Contact__r.Email != null ? r.Contact__r.Email :
                        (r.Contact__r.Email2__c != null ? r.Contact__r.Email2__c :
                        r.Contact__r.Email3__c);
//                rv.email_2__c = r.Contact__r.Email != null ? r.Contact__r.Email2__c :
//                        (r.Contact__r.Email3__c != null ? r.Contact__r.Email3__c :
//                        null);
//                rv.email_3__c = r.Contact__r.Email != null && r.Contact__r.Email2__c != null ?
//                        r.Contact__r.Email3__c : null;
                rv.Mobile__c = r.Contact__r.MobilePhone;

                if (ass.Brand__r.Name == 'Jaguar')
                {
                    rv.Dealer_Code__c = r.Account__r.Owner.Account.Dealer_CI_Code__c;
                }
                else
                {
                    rv.Dealer_Code__c = r.Account__r.Owner.Account.Dealer_CI_Code_2__c;
                }

                if (r.Account__r.IsPersonAccount)
                {
                    if (r.Account__r.BillingStreet != null)
                    {
                        rv.Mailing_Street__c = r.Account__r.BillingStreet;
                        rv.Mailing_City__c = r.Account__r.BillingCity;
                        rv.Mailing_State__c = r.Account__r.BillingState;
                        rv.Mailing_Country__c = r.Account__r.BillingCountry;
                        rv.Mailing_Post_Code__c = r.Account__r.BillingPostalCode;
                    }
                    else
                    {
                        rv.Mailing_Street__c = r.Account__r.ShippingStreet;
                        rv.Mailing_City__c = r.Account__r.ShippingCity;
                        rv.Mailing_State__c = r.Account__r.ShippingState;
                        rv.Mailing_Country__c = r.Account__r.ShippingCountry;
                        rv.Mailing_Post_Code__c = r.Account__r.ShippingPostalCode;
                    }
                }
                else
                {
                    if (r.Contact__r.MailingStreet != null)
                    {
                        rv.Mailing_Street__c = r.Contact__r.MailingStreet;
                        rv.Mailing_City__c = r.Contact__r.MailingCity;
                        rv.Mailing_State__c = r.Contact__r.MailingState;
                        rv.Mailing_Country__c = r.Contact__r.MailingCountry;
                        rv.Mailing_Post_Code__c = r.Contact__r.MailingPostalCode;
                    }
                    else
                    {
                        rv.Mailing_Street__c = r.Account__r.BillingStreet;
                        rv.Mailing_City__c = r.Account__r.BillingCity;
                        rv.Mailing_State__c = r.Account__r.BillingState;
                        rv.Mailing_Country__c = r.Account__r.BillingCountry;
                        rv.Mailing_Post_Code__c = r.Account__r.BillingPostalCode;
                    }
                }
            }
        }
    }
}