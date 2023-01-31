@isTest
public class Vista_AssetBuilder_CANHDOVER_T {
  static testmethod void Constructor_SetsEventCodeToCancelHandover_WhenCalled()
  {
    Vista_AssetBuilder_CANHDOVER assetBuilder = CreateAssetBuilder();

    System.assertEquals(Vista_EventCodes.CANHDOVER, assetBuilder.EventCode);
  }

  static testmethod void Build_SetsNullHandoverDate_WhenGivenHandoverDate()
  {
    Vista_AssetBuilder_CANHDOVER assetBuilder = CreateAssetBuilder();


    String orderNumber = 'o1';
    String dateString = '2016-12-18';
    Date expectedDate = Date.newInstance(2016, 12, 18);

    Asset asset = new Asset();

    Vista_RecordGroup request = CreateEmptyRecordGroup();
    request.VistaVehicleOrder.Customer = new Vista_OrderService.Customer();
    request.VistaVehicleOrder.Customer.CustomerHandoverDate = dateString;
    request.VistaVehicleOrder.MetaOrderNumber = orderNumber;
    request.VistaVehicleOrder.Misc=new Vista_OrderService.Misc();
    request.VistaVehicleOrder.Misc.CommonStatusPoint='Arrived at Dealer';

    Vista_RequestCollection requestCollection = CreateEmptyCollection();
    requestCollection.Assets.put(orderNumber, asset);


    assetBuilder.Build(request, requestCollection, null);

    System.assertEquals(null, asset.Handover_Date__c);
  }

  static testmethod void Build_DoesOverwriteHandoverWithNullValueDate_WhenGivenBlankHandoverDate()
  {
    Vista_AssetBuilder_CANHDOVER assetBuilder = CreateAssetBuilder();


    String orderNumber = 'o1';
    String dateString = '';
    Date expectedDate = null;

    Asset asset = new Asset(Handover_Date__c=expectedDate);

    Vista_RecordGroup request = CreateEmptyRecordGroup();
    request.VistaVehicleOrder.Customer = new Vista_OrderService.Customer();
    request.VistaVehicleOrder.Customer.CustomerHandoverDate = dateString;
    request.VistaVehicleOrder.MetaOrderNumber = orderNumber;
    request.VistaVehicleOrder.Misc=new Vista_OrderService.Misc();
    request.VistaVehicleOrder.Misc.CommonStatusPoint='Arrived at Dealer';

    Vista_RequestCollection requestCollection = CreateEmptyCollection();
    requestCollection.Assets.put(orderNumber, asset);


    assetBuilder.Build(request, requestCollection, null);

    System.assertEquals(expectedDate, asset.Handover_Date__c);
  }


  private static Vista_AssetBuilder_CANHDOVER CreateAssetBuilder()
  {
    Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
    Vista_AssetNonSpecSetter nonSpecSetter = new Vista_AssetNonSpecSetter(dateAdapter);
    Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();

    return new Vista_AssetBuilder_CANHDOVER(nonSpecSetter, specSetter, dateAdapter);
  }

  private static Vista_RecordGroup CreateEmptyRecordGroup()
  {
    Vista_RecordGroup recordGroup = new Vista_RecordGroup();

    recordGroup.Request = new Vista_Request__c();
    recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
    recordGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
    recordGroup.VistaVehicleOrder.Specification.Features = new List<Vista_OrderService.Feature>();
    recordGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
    recordGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();

    return recordGroup;
  }

  private static Vista_RequestCollection CreateEmptyCollection()
  {
    Vista_RequestCollection requestCollection = new Vista_RequestCollection();

    requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
    requestCollection.Assets = new Map<String, Asset>();
    requestCollection.Orders = new Map<String, Order>();
    requestCollection.OpportunityLineItems = new Map<String, OpportunityLineItem>();
    requestCollection.Retailers = new Map<String, Account>();
    requestCollection.Derivatives = new Map<String, Product2>();

    return requestCollection;
  }
}