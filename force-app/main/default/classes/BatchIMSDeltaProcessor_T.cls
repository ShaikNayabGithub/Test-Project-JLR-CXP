@isTest
public class BatchIMSDeltaProcessor_T  {

    @testSetup static void setup() {
        //Data needed:
        //1 records for vehicle spec (make)
        Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId(); 
        make.Is_Currently_Sold__c = false;
        make.aop_JLR_Owned__c = true;
        make.Name = 'Land Rover';  
        insert make;

        //1 record for migrated vehicles account
        Account ownerAccount = new Account(
            name = 'Singapore Migrated Vehicles',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId(),
            Country_Iso_code__c = 'SG' 
        );
        insert ownerAccount;

        //1 record for model 
        Product2 model = new Product2(
                                make__c = make.id,
                                productcode = 'AA',
                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId(),
                                IsActive = true,
                                Family = 'Vehicle',
                                Name = 'TestModel',
                                Alternative_Name__c = 'TestModel',
                                CurrencyIsoCode = 'GBP'
                                );
        insert model; 

        //1 record for derivative 
        Product2 derivative = new Product2(
                                make__c = make.id,
                                model__c = model.id,
                                productcode = '50000001',
                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId(),
                                IsActive = true,
                                Family = 'Vehicle',
                                Name = 'TestDerivative',
                                Alternative_Name__c = 'TestDerivative',
                                CurrencyIsoCode = 'GBP'
                                );
        insert derivative; 

        //1 record for asset
        Asset apoVehicle = new Asset( 
            APO__c = true,
            New_or_Used__c='Used',
            APO_Stock_Status__c='Retail',
            AccountId = OwnerAccount.id,
            Name = 'VIN000000000001',
            Vin__c = 'VIN000000000001',
            Brand__c = make.id,
            Model__c = Model.Id,
            Derivative__c = Derivative.Id,
            Product2id = Derivative.Id, 
            CurrencyIsoCode = 'GBP'
            
        );
        insert apoVehicle; 

    }

    public static testMethod void testMain() {
        IMS_Request__c ims_test_record = new IMS_Request__c(
                                                vin__c = 'VIN000000000002',  
                                                X5000_code__c = '50000001', 
                                                manufacturer__c = 'Land Rover',  
                                                model_code__c = 'AA', 
                                                additional_registration_fee__c = '120265',  
                                                bodystyle_code__c = 'A70C', 
                                                bodystyle_value_base__c = 'LWB Saloon', 
                                                bodystyle_value_local__c = 'LWB Saloon', 
                                                certificate_of_entitlement__c = '56206', 
                                                channel__c = 'Retail', 
                                                ci_code__c = '15000', 
                                                colour_exterior_code__c = '1AU', 
                                                colour_exterior_value_base__c = 'Storm Grey',  
                                                colour_interior_code__c = 'AAA', 
                                                colour_interior_value_base__c = 'Cashew',  
                                                country_code__c = 'SG', 
                                                country_name__c = 'Singapore',   
                                                CurrencyIsoCode = 'GBP', 
                                                currency__c = 'SGD', 
                                                date_mot_expiry__c = '2019-12-15', 
                                                date_registered__c = '2016-12-15', 
                                                date_stock__c = '2017-04-26', 
                                                date_visible_from__c = '2017-04-26', 
                                                date_warranty_expiry__c = '0000-00-00', 
                                                dealer_address__c = '45 Leng Kee Road,,,,Singapore,,,159103', 
                                                dealer_contact_no__c = '6378 2626', 
                                                dealer_email__c = 'jaguar.sales@wearnes.com', 
                                                dealer_gps_coordinates__c = '1.29087,103.81056', 
                                                dealer_id__c = '17070', 
                                                dealer_name__c = 'Wearnes Automotive', 
                                                drivetrain_name_base__c = 'R',
                                                drivetrain_name_local__c = 'R',
                                                doors_code__c = '0',  
                                                doors_value_base__c = '0',  
                                                drive_code__c = 'R',  
                                                drive_value_base__c = 'R',  
                                                engine_name_base__c = 'Test engine',
                                                engine_name_local__c = 'Test engine',
                                                engine_size_code__c = 'A20B', 
                                                engine_size_value_base__c = '3.0 V6 Supercharged',  
                                                features_base__c = '"A60R":"Rear Wheel Drive","C13A":"Front Parking Aid"',
                                                features_local__c = '"A60R":"Rear Wheel Drive","C13A":"Front Parking Aid"',
                                                highlighted_base__c = '"A60R":"Rear Wheel Drive","C13A":"Front Parking Aid"',
                                                highlighted_local__c = '"A60R":"Rear Wheel Drive","C13A":"Front Parking Aid"',
                                                int_material__c = 'Light Oyster Caramel Latte',
                                                fuel_value_base__c = 'Petrol',  
                                                model_description_base__c = 'XJ', 
                                                model_description_local__c = 'XJ', 
                                                model_value_base__c = 'XJ (X351)', 
                                                model_value_local__c = 'XJ', 
                                                model_year__c = '2016', 
                                                odometer__c = '1392', 
                                                open_market_value__c = '82369', 
                                                pic_refs__c = '//images-ims.motortrak.com/S/SAJ/AC2/282/H8W/049/34/SAJAC2282H8W04934_0_6E30CC664A25E1D6.jpg,//images-ims.motortrak.com/S/SAJ/AC2/282/H8W/049/34/SAJAC2282H8W04934_0_CD640EABD0A86687.jpg', 
                                                price_new__c = '0', 
                                                price_retail__c = '310800', 
                                                price_siv__c = '305000', 
                                                price_trade__c = '300000', 
                                                Processed_Status__c = 'Queued', 
                                                reg_no__c = 'SLM8659L', 
                                                seats_code__c = '0', 
                                                seats_value_base__c = '0',
                                                stock_number__c = '123',
                                                transmission_code__c = 'A40E', 
                                                transmission_meta_base__c = 'Automatic AWD', 
                                                transmission_value_base__c = '8 Speed Automatic', 
                                                variant_code__c = 'CJALB', 
                                                variant_value_base__c = 'Premium Luxury', 
                                                wheelbase_code__c = 'A70C', 
                                                wheelbase_name_base__c = '4 door LWB',                                                 
                                                year_reg__c = '2016'
                                    );
        insert ims_test_record;   

        Asset cxpAsset = [select APO_Stock_Status__c from asset where name = 'VIN000000000001' limit 1];

        System.assertEquals('Retail',cxpAsset.APO_Stock_Status__c);

        Test.startTest();
        Database.executeBatch(new BatchIMSDeltaProcessor('SG'),1);
        Test.stopTest();

        Asset cxpAsset_after_batch = [select APO_Stock_Status__c from asset where name = 'VIN000000000001' limit 1];

        System.assertEquals('Sold',cxpAsset_after_batch.APO_Stock_Status__c);  

    }

}