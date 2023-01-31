@isTest
public class BatchIMSRequestProcessor_T  {

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

    public static testMethod void test_ims_with_matching_vin_and_product() {
        //1 record for IMS request with matching vin and matching product code 
        IMS_Request__c ims_with_matching_vin_and_product = new IMS_Request__c(
                                                vin__c = 'VIN000000000001',  
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
                                                price_siv__c = '', 
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
        insert ims_with_matching_vin_and_product;

        System.assertEquals(null,ims_with_matching_vin_and_product.asset__c);
        System.assertEquals(null,ims_with_matching_vin_and_product.product__c);
        Test.startTest();
        Database.executeBatch(new BatchIMSRequestProcessor('SG'),1);
        Test.stopTest();
        Asset updatedAsset = [select id from asset where name = 'VIN000000000001' limit 1];
        Product2 updatedProduct = [select id from product2 where recordtype.developername = 'Derivative' and ProductCode = '50000001' limit 1];
        IMS_Request__c ims_with_matching_vin_and_product_after_batch = [select processed_error_reason__c, asset__c, product__c from ims_request__c limit 1];
        String err = '';

        err = (ims_with_matching_vin_and_product_after_batch.processed_error_reason__c==null?'':ims_with_matching_vin_and_product_after_batch.processed_error_reason__c);
        System.assertEquals(updatedAsset.id,ims_with_matching_vin_and_product_after_batch.asset__c, err);
        System.assertEquals(updatedProduct.id,ims_with_matching_vin_and_product_after_batch.product__c, err); 
        System.assertEquals('',err,err);
    }

    public static testMethod void test_ims_with_matching_vin_but_no_product() {
        //1 record for IMS request with matching vin but no product code
        IMS_Request__c ims_with_matching_vin_but_no_product = new IMS_Request__c(
                                                vin__c = 'VIN000000000001',  
                                                X5000_code__c = '', 
                                                manufacturer__c = 'Land Rover',  
                                                model_code__c = 'AA', 
                                                additional_registration_fee__c = null,  
                                                bodystyle_code__c = 'A70C', 
                                                bodystyle_value_base__c = 'LWB Saloon', 
                                                bodystyle_value_local__c = 'LWB Saloon', 
                                                certificate_of_entitlement__c = null, 
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
                                                fuel_value_base__c = 'Petrol',  
                                                model_description_base__c = 'XJ', 
                                                model_description_local__c = 'XJ', 
                                                model_value_base__c = 'XJ (X351)', 
                                                model_value_local__c = 'XJ', 
                                                model_year__c = '2016', 
                                                odometer__c = '1392', 
                                                open_market_value__c = null, 
                                                pic_refs__c = '//images-ims.motortrak.com/S/SAJ/AC2/282/H8W/049/34/SAJAC2282H8W04934_0_6E30CC664A25E1D6.jpg,//images-ims.motortrak.com/S/SAJ/AC2/282/H8W/049/34/SAJAC2282H8W04934_0_CD640EABD0A86687.jpg', 
                                                price_new__c = '0', 
                                                price_retail__c = '310800', 
                                                price_siv__c = '', 
                                                price_trade__c = '300000', 
                                                Processed_Status__c = 'Queued', 
                                                reg_no__c = 'SLM8659L', 
                                                seats_code__c = '0', 
                                                seats_value_base__c = '0',
                                                transmission_code__c = 'A40E', 
                                                transmission_meta_base__c = 'Automatic AWD', 
                                                transmission_value_base__c = '8 Speed Automatic', 
                                                variant_code__c = 'CJALB', 
                                                variant_value_base__c = 'Premium Luxury', 
                                                wheelbase_code__c = 'A70C', 
                                                wheelbase_name_base__c = '4 door LWB',                                                 
                                                year_reg__c = '2016'
                                    );
        insert ims_with_matching_vin_but_no_product;

        System.assertEquals(null,ims_with_matching_vin_but_no_product.asset__c);
        System.assertEquals(null,ims_with_matching_vin_but_no_product.product__c);
        Test.startTest();
        Database.executeBatch(new BatchIMSRequestProcessor('SG'),1);
        Test.stopTest();
        Asset updatedAsset = [select id from asset where name = 'VIN000000000001' limit 1];

        IMS_Request__c ims_with_matching_vin_but_no_product_after_batch = [select processed_error_reason__c, asset__c, product__c from ims_request__c limit 1];
        String err = '';

        err = (ims_with_matching_vin_but_no_product_after_batch.processed_error_reason__c==null?'':ims_with_matching_vin_but_no_product_after_batch.processed_error_reason__c);
        System.assertEquals(updatedAsset.id,ims_with_matching_vin_but_no_product_after_batch.asset__c, err);
        System.assertNotEquals(null,ims_with_matching_vin_but_no_product_after_batch.product__c, err); 
        System.assertEquals('',err,err);    
    }

    public static testMethod void test_ims_with_no_matching_vin_and_product() {
        //1 record for IMS request with non-matching vin and product code
        IMS_Request__c ims_with_no_matching_vin_and_product = new IMS_Request__c(
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
                                                price_siv__c = '', 
                                                price_trade__c = '300000', 
                                                Processed_Status__c = 'Queued', 
                                                reg_no__c = 'SLM8659L', 
                                                seats_code__c = '0', 
                                                seats_value_base__c = '0',
                                                transmission_code__c = 'A40E', 
                                                transmission_meta_base__c = 'Automatic AWD', 
                                                transmission_value_base__c = '8 Speed Automatic', 
                                                variant_code__c = 'CJALB', 
                                                variant_value_base__c = 'Premium Luxury', 
                                                wheelbase_code__c = 'A70C', 
                                                wheelbase_name_base__c = '4 door LWB',                                                 
                                                year_reg__c = '2016'
                                    );
        insert ims_with_no_matching_vin_and_product;

        System.assertEquals(null,ims_with_no_matching_vin_and_product.asset__c);
        System.assertEquals(null,ims_with_no_matching_vin_and_product.product__c);
        Test.startTest();
        Database.executeBatch(new BatchIMSRequestProcessor('SG'),1);
        Test.stopTest();
        Asset createdAsset = [select id from asset where name = 'VIN000000000002' limit 1];
        Product2 updatedProduct = [select id from product2 where recordtype.developername = 'Derivative' and ProductCode = '50000001' limit 1];
        IMS_Request__c ims_with_no_matching_vin_and_product_after_batch = [select processed_error_reason__c, asset__c, product__c from ims_request__c limit 1];
        String err = '';

        err = (ims_with_no_matching_vin_and_product_after_batch.processed_error_reason__c==null?'':ims_with_no_matching_vin_and_product_after_batch.processed_error_reason__c);
        System.assertEquals(createdAsset.id,ims_with_no_matching_vin_and_product_after_batch.asset__c, err);
        System.assertEquals(updatedProduct.id,ims_with_no_matching_vin_and_product_after_batch.product__c, err); 
        System.assertEquals('',err,err);    
    }

    public static testMethod void test_ims_with_no_matching_vin_and_no_matching_product() {
        //1 record for IMS request with non-matching vin and no product code 
        IMS_Request__c ims_with_no_matching_vin_and_no_matching_product = new IMS_Request__c(
                                                vin__c = 'VIN000000000003',  
                                                X5000_code__c = '50000002', 
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
                                                price_siv__c = '', 
                                                price_trade__c = '300000', 
                                                Processed_Status__c = 'Queued', 
                                                reg_no__c = 'SLM8659L', 
                                                seats_code__c = '0', 
                                                seats_value_base__c = '0',
                                                transmission_code__c = 'A40E', 
                                                transmission_meta_base__c = 'Automatic AWD', 
                                                transmission_value_base__c = '8 Speed Automatic', 
                                                variant_code__c = 'CJALB', 
                                                variant_value_base__c = 'Premium Luxury', 
                                                wheelbase_code__c = 'A70C', 
                                                wheelbase_name_base__c = '4 door LWB',                                                 
                                                year_reg__c = '2016'
                                    );
        insert ims_with_no_matching_vin_and_no_matching_product;

        System.assertEquals(null,ims_with_no_matching_vin_and_no_matching_product.asset__c);
        System.assertEquals(null,ims_with_no_matching_vin_and_no_matching_product.product__c);
        Test.startTest();
        Database.executeBatch(new BatchIMSRequestProcessor('SG'),1);
        Test.stopTest();
        Asset createdAsset = [select id from asset where name = 'VIN000000000003' limit 1];
        Product2 createdProduct = [select id from product2 where recordtype.developername = 'Derivative' and ProductCode = '50000002' limit 1];
        IMS_Request__c ims_with_no_matching_vin_and_no_matching_product_after_batch = [select processed_error_reason__c, asset__c, product__c from ims_request__c limit 1];
        String err = '';

        err = (ims_with_no_matching_vin_and_no_matching_product_after_batch.processed_error_reason__c==null?'':ims_with_no_matching_vin_and_no_matching_product_after_batch.processed_error_reason__c);
        System.assertEquals(createdAsset.id,ims_with_no_matching_vin_and_no_matching_product_after_batch.asset__c, err);
        System.assertEquals(createdProduct.id,ims_with_no_matching_vin_and_no_matching_product_after_batch.product__c, err); 
        System.assertEquals('',err,err);           
    } 

    public static testMethod void test_ims_with_no_matching_model() {
        //1 record for IMS request with non-matching vin and no product code 
        IMS_Request__c ims_with_no_matching_model = new IMS_Request__c(
                                                vin__c = 'VIN000000000003',  
                                                X5000_code__c = '50000002', 
                                                manufacturer__c = 'Land Rover',  
                                                model_code__c = 'BB', 
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
                                                price_siv__c = '', 
                                                price_trade__c = '300000', 
                                                Processed_Status__c = 'Queued', 
                                                reg_no__c = 'SLM8659L', 
                                                seats_code__c = '0', 
                                                seats_value_base__c = '0',
                                                transmission_code__c = 'A40E', 
                                                transmission_meta_base__c = 'Automatic AWD', 
                                                transmission_value_base__c = '8 Speed Automatic', 
                                                variant_code__c = 'CJALB', 
                                                variant_value_base__c = 'Premium Luxury', 
                                                wheelbase_code__c = 'A70C', 
                                                wheelbase_name_base__c = '4 door LWB',                                                 
                                                year_reg__c = '2016'
                                    );
        insert ims_with_no_matching_model;

        System.assertEquals(null,ims_with_no_matching_model.asset__c);
        System.assertEquals(null,ims_with_no_matching_model.product__c);
        Test.startTest();
        Database.executeBatch(new BatchIMSRequestProcessor('SG'),1);
        Test.stopTest();  
                 
        Asset createdAsset = [select id from asset where name = 'VIN000000000003' limit 1];
        Product2 createdProduct = [select id from product2 where recordtype.developername = 'Derivative' and ProductCode = '50000002' limit 1];
        IMS_Request__c ims_with_no_matching_model_after_batch = [select processed_error_reason__c, asset__c, product__c from ims_request__c limit 1];
        String err = '';

        err = (ims_with_no_matching_model_after_batch.processed_error_reason__c==null?'':ims_with_no_matching_model_after_batch.processed_error_reason__c);
        System.assertEquals(createdAsset.id,ims_with_no_matching_model_after_batch.asset__c, err);
        System.assertEquals(createdProduct.id,ims_with_no_matching_model_after_batch.product__c, err); 
        System.assertEquals('',err,err);           
    } 

    public static testMethod void test_ims_with_bad_data() {
        //1 record for IMS request with bad data
        IMS_Request__c ims_with_bad_data = new IMS_Request__c(
                                                vin__c = 'VIN000000000001',  
                                                X5000_code__c = '50000001', 
                                                manufacturer__c = 'Land Rover',  
                                                model_code__c = 'BB', 
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
                                                date_mot_expiry__c = 'illegal data', // BAD DATA IN DATE FIELD
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
                                                price_siv__c = '', 
                                                price_trade__c = '300000', 
                                                Processed_Status__c = 'Queued', 
                                                reg_no__c = 'SLM8659L', 
                                                seats_code__c = '0', 
                                                seats_value_base__c = '0',
                                                transmission_code__c = 'A40E', 
                                                transmission_meta_base__c = 'Automatic AWD', 
                                                transmission_value_base__c = '8 Speed Automatic', 
                                                variant_code__c = 'CJALB', 
                                                variant_value_base__c = 'Premium Luxury', 
                                                wheelbase_code__c = 'A70C', 
                                                wheelbase_name_base__c = '4 door LWB',                                                 
                                                year_reg__c = '2016'
                                    );
        insert ims_with_bad_data;

        System.assertEquals(null,ims_with_bad_data.asset__c);
        System.assertEquals(null,ims_with_bad_data.product__c);
        Test.startTest();
        Database.executeBatch(new BatchIMSRequestProcessor('SG'),1);
        Test.stopTest();

        IMS_Request__c ims_with_bad_data_after_batch = [select processed_status__c, processed_error_reason__c, asset__c, product__c from ims_request__c limit 1];

        System.assertEquals('Failed',ims_with_bad_data_after_batch.processed_status__c);  
    } 

}