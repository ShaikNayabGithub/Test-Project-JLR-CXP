@isTest
public class Vista_OrderBuilder_A_T {
	static testmethod void Build_SetsLastEventToT1_GivenEventCodeT1()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';
		String eventCode = 'e1';
		Order order1 = new Order();

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Orders.put(orderNumber, order1);

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.EventCode = eventCode;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(eventCode, order1.Last_Event__c);
	}

	static testmethod void Build_SetsLastEventDateToToday_GivenRequest()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';
		Order order1 = new Order();

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Orders.put(orderNumber, order1);

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(Date.today(), order1.Last_Event_Date__c);
	}

	static testmethod void Build_AddsOrderWithStatusDraft_GivenOrderDoesntExist()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(System.label.Order_DraftStatus, requestCollection.Orders.get(orderNumber).Status);
	}

	static testmethod void Build_AddsOrderWithOrderNumberO1_GivenOrderO1DoesntExist()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(orderNumber, requestCollection.Orders.get(orderNumber).Vista_Order_Number__c);
	}

	static testmethod void Build_AddsOrderWithRetailerId_GivenOrderDoesntExistAndRetailerFound()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';
		Account retailer = TestClass_AccountCreator.CreateRetailer();

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Retailers.put(retailer.Primary_Dealer_Code__c, retailer);

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID = 
				retailer.Primary_Dealer_Code__c;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(retailer.Id, requestCollection.Orders.get(orderNumber).AccountId);
	}

	static testmethod void Build_AddsOrderWithRetailerSetToParentId_GivenOrderDoesntExistAndChildRetailerFound()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';
		Account parentRetailer = TestClass_AccountCreator.CreateRetailer();
		Account retailer = TestClass_AccountCreator.CreateRetailer();
		retailer.Record_Sub_Type__c = System.Label.Account_Sub_Type_Branded;
		retailer.ParentId = parentRetailer.Id;

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Retailers.put(retailer.Primary_Dealer_Code__c, retailer);

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID = 
				retailer.Primary_Dealer_Code__c;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(parentRetailer.Id, requestCollection.Orders.get(orderNumber).AccountId);
	}

	static testmethod void Build_AddsOrderWithStatusActive_GivenOrderO1DoesntExistAndOpportunityFound()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.OpportunityLineItems.put(orderNumber, new OpportunityLineItem(Opportunity=new Opportunity()));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(System.label.Order_ActivatedStatus, requestCollection.Orders.get(orderNumber).Status);
	}

	static testmethod void Build_AddsOrderWithAccountId_GivenOrderO1DoesntExistAndOpportunityWithAccountFound()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';
		Account retailer = TestClass_AccountCreator.CreateRetailer();

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.OpportunityLineItems.put(orderNumber, new OpportunityLineItem(
			Opportunity=new Opportunity(AccountId=retailer.Id)));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(retailer.Id, requestCollection.Orders.get(orderNumber).AccountId);
	}

	static testmethod void Build_AddsOrderWithOpportunityAccountId_GivenOrderO1DoesntExistAndOpportunityWithAccountFoundAndRetailerFound()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();

		String orderNumber = 'o1';
		Account retailer = TestClass_AccountCreator.CreateRetailer();
		Account opportunityRetailer = TestClass_AccountCreator.CreateRetailer();

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.OpportunityLineItems.put(orderNumber, new OpportunityLineItem(
			Opportunity=new Opportunity(AccountId=opportunityRetailer.Id)));
		requestCollection.Retailers.put(retailer.Primary_Dealer_Code__c, retailer);

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID = 
				retailer.Primary_Dealer_Code__c;

		orderBuilder.Build(recordGroup, requestCollection);
		System.assertEquals(opportunityRetailer.Id, requestCollection.Orders.get(orderNumber).AccountId);
	}

	static testmethod void Build_AddsOrderWithOwnerId_GivenOrderO1DoesntExistAndOpportunityWithOwnerFound()
	{
		Vista_OrderBuilder_Dummy orderBuilder = new Vista_OrderBuilder_Dummy();


		String orderNumber = 'o1';
		User owner = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.OpportunityLineItems.put(orderNumber, new OpportunityLineItem(
			Opportunity=new Opportunity(OwnerId=owner.Id)));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


		orderBuilder.Build(recordGroup, requestCollection);

		System.assertEquals(owner.Id, requestCollection.Orders.get(orderNumber).OwnerId);
	}


	private static Vista_RequestCollection CreateEmptyCollection()
	{
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
		requestCollection.Orders = new Map<String, Order>();
		requestCollection.PriceBookEntries = new Map<String, PriceBookEntry>();
		requestCollection.OpportunityLineItems = new Map<String, OpportunityLineItem>();
		requestCollection.Retailers = new Map<String, Account>();

		return requestCollection;
	}

	private static Vista_RecordGroup CreateEmptyRecordGroup()
	{
		Vista_RecordGroup recordGroup = new Vista_RecordGroup();

		recordGroup.Request = new Vista_Request__c();
		recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		recordGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
		recordGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
		recordGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();

		return recordGroup;
	}


	private class Vista_OrderBuilder_Dummy extends Vista_OrderBuilder_A {
		protected override void Build(Order order, Vista_RecordGroup request)
	    {
	        //do nothing
	    }
	}
}