@isTest
public class Vista_AssetSpecSetter_T {
    static testmethod void Set_DoesNothing_GivenNullSpecification()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        Asset asset = new Asset();

        Vista_RecordGroup recordGroup = new Vista_RecordGroup();
        recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();

        Vista_RequestCollection requestCollection = CreateEmptyCollection();


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assert(true);
    }

    static testmethod void Set_SetsDerivative_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String derivativeId = '01t24000006MCsn';//id value irrelevant, just needs to be valid

        Asset asset = new Asset();
        Product2 derivative = new Product2(Id=derivativeId);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(derivativeId, asset.Derivative__c);
    }

    static testmethod void Set_SetsModel_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String modelId = '01t24000006MCsn';//id value irrelevant, just needs to be valid

        Asset asset = new Asset();
        Product2 derivative = new Product2(Model__c=modelId);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(modelId, asset.Model__c);
    }

    static testmethod void Set_SetsBrand_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String makeId = '01t24000006MCsn';//id value irrelevant, just needs to be valid

        Asset asset = new Asset();
        Product2 derivative = new Product2(Make__c=makeId);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(makeId, asset.Brand__c);
    }

    static testmethod void Set_SetsBodyStyle_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String bodyStyle = 'b1';

        Asset asset = new Asset();
        Product2 derivative = new Product2(Body_Style__c=bodyStyle);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(bodyStyle, asset.Body_Style__c);
    }

    static testmethod void Set_SetsEngine_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String engine = 'e1';

        Asset asset = new Asset();
        Product2 derivative = new Product2(Engine__c=engine);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(engine, asset.Engine__c);
    }

    static testmethod void Set_SetsWheelBase_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String wheelBase = 'w1';

        Asset asset = new Asset();
        Product2 derivative = new Product2(Wheel_Base__c=wheelBase);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(wheelBase, asset.Wheel_Base__c);
    }

    static testmethod void Set_SetsWheelDriven_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String wheelDriven = 'w1';

        Asset asset = new Asset();
        Product2 derivative = new Product2(Wheel_Driven__c=wheelDriven);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(wheelDriven, asset.Wheel_Driven__c);
    }

    static testmethod void Set_SetsTransmission_GivenDerivativeFound()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String transmission = 't1';

        Asset asset = new Asset();
        Product2 derivative = new Product2(Transmission__c=transmission);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(transmission, asset.Transmission__c);
    }

    static testmethod void Set_DoesNotSetTransmission_GivenDerivativeFoundAndTransmissionAlreadySetOnAsset()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String transmission1 = 't1';
        String transmission2 = 't2';

        Asset asset = new Asset(Transmission__c=transmission1);
        Product2 derivative = new Product2(Transmission__c=transmission2);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(transmission1, asset.Transmission__c);
    }

    static testmethod void Set_SetsColour_GivenFeatureColour()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String productCode = 'p1';
        String colourCode = 'c1';
        String colourValue = 'Fuji White';

        Asset asset = new Asset();
        Product2 derivative = new Product2(Model__r = new Product2(
                Model_Colours__c = '[{"Value":"'+colourValue+'","Key":"'+colourCode+'"}]'));

        Vista_OrderService.Feature colourFeature = new Vista_OrderService.Feature();
        colourFeature.Featuretype = 'PCOL';
        colourFeature.FeatureCode = colourCode;

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;
        recordGroup.VistaVehicleOrder.Specification.Features = new List<Vista_OrderService.Feature>{
                colourFeature };

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Derivatives.put(productCode, derivative);


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(colourValue, asset.Exterior_Colour__c);
        System.assertEquals(colourCode, asset.Exterior_Colour_Code__c);
    }

    static testmethod void Set_SetsTransmission_GivenFeatureTransmission()
    {
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();


        String transmission = 't1';

        Asset asset = new Asset();
        Vista_OrderService.Feature transmissionFeature = new Vista_OrderService.Feature();
        transmissionFeature.Featuretype = 'TRAN';
        transmissionFeature.FeatureCode = transmission;

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.Specification.Features = new List<Vista_OrderService.Feature>{
                transmissionFeature };

        Vista_RequestCollection requestCollection = CreateEmptyCollection();


        specSetter.Set(asset, recordGroup, requestCollection);

        System.assertEquals(transmission, asset.Transmission__c);
    }


    private static Vista_RecordGroup CreateEmptyRecordGroup()
    {
        Vista_RecordGroup recordGroup = new Vista_RecordGroup();

        recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recordGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();

        return recordGroup;
    }

    private static Vista_RequestCollection CreateEmptyCollection()
    {
        Vista_RequestCollection requestCollection = new Vista_RequestCollection();

        requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
        requestCollection.Derivatives = new Map<String, Product2>();

        return requestCollection;
    }
}