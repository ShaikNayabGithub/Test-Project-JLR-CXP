public with Sharing class PdiRequestTriggerHelper {

	private Set<String> openPdiStatuses = new Set<String>{'Requested', 'Approved'};
	private Map<Id, Set<Id>> vehicleIdToOpenPdiIds = new Map<Id, Set<Id>>();

    public void ifRequestedDeliverydateChanged(List<PDI_Request__c> newPdiRequests, Map<Id,PDI_Request__c> mapPdiRequests)
    {       
         Id profileId = UserInfo.getProfileId();
         String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
         system.debug('Profile Name---->'+profileName);
         //Add profile check if required--> Dealer Principle MENA
         for(PDI_Request__c newPdirequest : newPdiRequests){
             if(newPdirequest.Requested_Delivery_Date__c !=null){
                if(newPdirequest.Requested_Delivery_Date__c != mapPdiRequests.get(newPdirequest.Id).Requested_Delivery_Date__c){
                    newPdirequest.PDI_Status__c = 'Requested';
                }
            }
        }
    }
    /*
    public void restrictToCreateDuplicatePdiRequests(List<PDI_Request__c> pdiRequestRecs)
    {

		Set<Id> vehicleIds = new Set<Id>();
		for(PDI_Request__c pdiRequest : pdiRequestRecs){
			system.debug('coming in pdi request--');
			if(pdiRequest.Vehicle__c !=null){
				vehicleIds.add(pdiRequest.Vehicle__c);
			}
		}

		List<PDI_Request__c> existingOpenPdiRequestsforAsset = [SELECT Id,Vehicle__c,PDI_Status__c FROM PDI_Request__c WHERE Vehicle__c IN :vehicleIds AND (PDI_Status__c ='Requested')];

		// Check for Preivously committed records
		this.collateOpenPdiRequestByVehcileId(existingOpenPdiRequestsforAsset);
		// Check for in memory changes to current records
		this.collateOpenPdiRequestByVehcileId(pdiRequestRecs);


		for(PDI_Request__c pdi : pdiRequestRecs){
			Set<Id> openPdiIds = this.vehicleIdToOpenPdiIds.get(pdi.Vehicle__c);
			if(openPdiIds == null) {
				continue;
			}
			Boolean newPdiStatusIsOpen = this.openPdiStatuses.contains(pdi.PDI_Status__c);
			Boolean vehcileHasMultipleOpenPdiRequests = openPdiIds.size() > 1;

			System.debug('this.vehicleIdToOpenPdiIds');
			System.debug(this.vehicleIdToOpenPdiIds);

			if(newPdiStatusIsOpen && vehcileHasMultipleOpenPdiRequests ) {
				pdi.addError(System.Label.CXP_RestrictDuplicatePDIRequest);
			}
		}

    }
    */
	private void collateOpenPdiRequestByVehcileId(List<PDI_Request__c> pdiRequests) {
		for(PDI_Request__c pdi : pdiRequests){

			if(this.openPdiStatuses.contains(pdi.PDI_Status__c)) {
				Set<Id> vehicleOptionPdiRequestIds;

				if(this.vehicleIdToOpenPdiIds.get(pdi.Vehicle__c) != null) {
					vehicleOptionPdiRequestIds = this.vehicleIdToOpenPdiIds.get(pdi.Vehicle__c);
				} else {
					vehicleOptionPdiRequestIds = new Set<Id>();
				}

				vehicleOptionPdiRequestIds.add(pdi.Id);
				this.vehicleIdToOpenPdiIds.put(pdi.Vehicle__c, vehicleOptionPdiRequestIds);
			}

		}
	}
   
   
   
}