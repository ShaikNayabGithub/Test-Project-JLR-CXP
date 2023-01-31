public class Service_DMS_Opportunity_Updater  {
	private Service_DMS_Opportunity_Data.UpdateOpportunityRequest data;
	private Set<Id> opportunityRequestIds;
	private Map<Id, Opportunity> opportunities;
	private Boolean hasErrors;
	private Map<Id,Opportunity> opportunitiesToUpdate;

	public Service_DMS_Opportunity_Updater(Service_DMS_Opportunity_Data.UpdateOpportunityRequest data){
		this.data = data;
		opportunitiesToUpdate = new Map<Id,Opportunity>();
		hasErrors = false; 
	}

	public Service_DMS_Opportunity_Data.UpdateOpportunityResponse UpdateOpportunities(){
		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = new Service_DMS_Opportunity_Data.UpdateOpportunityResponse();
		
		if(data == null || data.CXPSalesOrders.size() == 0){
			response.Error = 'Opportunity data required';
			return response;
		}

		if(String.isBlank(data.DealerCode)){
			response.Error = 'DealerCode required';
			return response;
		}

		String retailerId;
		//Check dealer code is valid
		try{	        
			retailerId = Service_DMS_Opportunity_Endpoint.DecryptDealerCode(this.data.DealerCode);
			List<Account> retailerAccount = [SELECT Id
											FROM Account 
											WHERE Id=:retailerId];
			
			if(retailerAccount.isEmpty()){
				response.Error = 'Could not find retailer';
				return response;
			}	
		}
		catch (Exception  e){
			response.Error = 'Error decrypting dealercode';
			return response;			
		}

		

		try{	        
			if(containsDuplicateOppId()){
				response.Error = 'Duplicate Opportunity Id';
				return response;
			}
		}
		catch (Exception e){
			//if(e.getMessage() == 'Invalid Id'){
				return createInvalidIdResponse();
			//}			
		}
		retreiveOpportunities();

		
		for(Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem request : data.CXPSalesOrders){
			response.CXPSalesOrders.add(processOpportunity(request));
		}

		
		Database.SaveResult[] result =  Database.update( opportunities.values(),false);
		
		for(Database.SaveResult r : result){
			if(!r.isSuccess()){
				hasErrors = true;
				//find response item
				for(Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem item : response.CXPSalesOrders){
					if(item.SFOpportunityId == r.getId()){
						item.Success = false;

						List<Database.Error> errors = r.getErrors();

						for(Database.Error err : errors){
							item.Error += err.getMessage() + '\n';
						}						
						break;
					}
				}
			}
		}


		response.HasItemErrors = hasErrors;
		return response;
	}

	public Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem processOpportunity(Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem requestItem){
		Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem responseItem  = new Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem(requestItem);
		responseItem.Success = false;

		if(!opportunities.containsKey(requestItem.SFOpportunityId)){
			return setItemError(responseItem,'Opportunity not found');
		}

		if(!String.isBlank(requestItem.Status)){
			if(requestItem.Status == 'NOK' && String.isBlank(requestItem.Reason)){
			return setItemError(responseItem,'Reason is required for status NOK');
			}

			if(requestItem.Status == 'OK' && String.isBlank(requestItem.NBSorderID)){
				return setItemError(responseItem,'Order Id is required');
			} 
		}		

		Opportunity opp = opportunities.get(requestItem.SFOpportunityId);

		if(String.isNotBlank(requestItem.NBSorderID)){
			opp.DMS_Opportunity_ID__c = requestItem.NBSorderID;
		}
		
		if(opp.TimeLastSentToDMS__c == null){
			opp.TimeLastSentToDMS__c = Datetime.now();
		}

		if(requestItem.Status == 'NOK'){
			opp.DMS_Reason__c = requestItem.Reason;
		}
		
		//remove any existing errors if a successful reply has come in
		if(requestItem.Status == 'OK'){
			opp.DMS_Reason__c = null;
		}

		responseItem.Success = true;		
		return responseItem;
	}

	private Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem setItemError(Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem item, String error){
		item.Error = error;
		hasErrors = true;
		return item;
	}

	public void retreiveOpportunities(){
		opportunities = new Map<Id, Opportunity> ([SELECT Id, TimeLastSentToDMS__c
													FROM Opportunity
													WHERE Id in : opportunityRequestIds
													]);
	}

	public Service_DMS_Opportunity_Data.UpdateOpportunityResponse createInvalidIdResponse(){
		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = new Service_DMS_Opportunity_Data.UpdateOpportunityResponse();

		for(Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem request : data.CXPSalesOrders){
			Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem responseItem  = new Service_DMS_Opportunity_Data.UpdateOpportunityResponseItem(request);
			//responseItem.SFOpportunityId = request.SFOpportunityId;
			try{	        
				ID oppId = request.SFOpportunityId;				 
			}
			catch (Exception  e){		
					responseItem.Error = 'Invalid Salesforce Id';				
			}
			response.CXPSalesOrders.add(responseItem);
			response.Error = 'Invalid Salesforce Id';
		}
		return response;
	}

	public Boolean containsDuplicateOppId(){
		opportunityRequestIds = new Set<Id>();
		for(Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item : data.CXPSalesOrders){
			if(opportunityRequestIds.contains(item.SFOpportunityId)){
				opportunityRequestIds = null;
				return true;
			}

			opportunityRequestIds.add(Id.valueOf(item.SFOpportunityId));
		}
		return false;
	}
}