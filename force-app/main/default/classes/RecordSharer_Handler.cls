public class RecordSharer_Handler  {
	
	public void CheckForDuplicates(List<Record_Share__c> shares){
		
		//check within created list
		Map<String,Record_Share__c> retailerAndUser = new Map<String,Record_Share__c>();
		for(Record_Share__c share : shares){
			String combineIds = String.valueOf(share.User__c) + String.valueOf(share.Retailer__c);
			if(retailerAndUser.containsKey(combineIds)){
				//duplicate detected
				retailerAndUser.get(combineIds).addError('Duplicate combination of user and retailer');
				share.addError('Duplicate combination of user and retailer');
			}else{
				retailerAndUser.put(combineIds,share);
			}
		}

		Set<Id> userIds = SObjectUtilities.GetFieldValuesId(shares,'User__C');
		//check against records in the database
		List<Record_Share__c> existingShares = [Select User__c, Retailer__c from Record_Share__c where User__c in : userIds ];
		Map<Id,List<Record_Share__c>> existingSharesByUser = SObjectUtilities.MapByIdField(existingShares, Record_Share__c.User__c.getDescribe());

		for(Record_Share__c share : shares){
			List<Record_Share__c> existingUsersShares = existingSharesByUser.get(share.User__c);
			if(existingUsersShares == null) continue;

			for(Record_Share__c existingUserShare : existingUsersShares){
				if(share.Retailer__c == existingUserShare.Retailer__c){
					share.addError('Duplicate combination of user and retailer');
					break;
				}
			}
		}
	}


	public static Boolean AllowEdit = false;
	public void UpdateRecords(Map<Id,Record_Share__c> oldShares, Map<Id,Record_Share__c> newShares){
		for(Record_Share__c share : newShares.values()){
			Record_Share__c oldShare = oldShares.get(share.id);

			if(share.User__c != oldShare.User__c || share.Retailer__c != oldShare.Retailer__c){
				share.addError('You can not edit the user or retailer once a record is created');
			}


			if(share.Status__c == oldShare.Status__c){
				share.Status__c = 'Pending';
			}		
			
			if(oldShare.Status__c == 'Processing' && !AllowEdit){
				share.addError('You can not edit the record while it is being processed');
			}
				
		}
	}

	public void InsertRecords(List<Record_Share__c> shares){
		for(Record_Share__c share : shares){
			share.Status__c = 'Pending';
		}
Profile pr = [Select id, name from Profile where id=:UserInfo.getProfileId()];
        if(pr.name != 'JLR System Administrator (Super)'){
		CheckForDuplicates(shares);
		  }
	}

	public static Boolean AllowDelete = false;
	public void DeleteRecord(List<Record_Share__c> shares){
		if(!AllowDelete){
			for(Record_Share__c share : shares){
				share.addError('Users are not allowed to delete records');
			}
		}
	}

}