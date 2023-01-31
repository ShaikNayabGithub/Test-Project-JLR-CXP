public class CaseAssetRoleSetter{

	//if Case Contact, Asset and Vehicle Relationship have been defined, update the Asset's Account
	public void SetAssetRoles(List<Case> currentCases, Map<Id, Case> oldCaseMap){
		List<Case> casesWithVehicleRelationship = new List<Case>();
		List<Case> casesWithNewRegisteredKeeper = new List<Case>();
		List<Case> casesWithNewDriver = new List<Case>();
		for(Case cse : currentCases){
			if(String.IsNotBlank(cse.Vehicle_Relationship__c)){
				boolean updateAssetRole = false; //only need to action if this is a new Case or the Vehicle or Contact has changed
				if(oldCaseMap == null || !oldCaseMap.containsKey(cse.Id)){
					updateAssetRole = true;
				}
				else{
					Case oldCase = oldCaseMap.get(cse.Id);
					if(oldCase.ContactId != cse.ContactId || oldCase.AssetId != cse.AssetId){
						updateAssetRole = true;
					}
					if(String.IsBlank(oldCase.Vehicle_Relationship__c) || oldCase.Vehicle_Relationship__c != cse.Vehicle_Relationship__c){
						updateAssetRole = true;
					}
				}
				if(updateAssetRole){
					if(cse.Vehicle_Relationship__c.equalsIgnoreCase('OWNER')){
						casesWithVehicleRelationship.add(cse);
					}
					else if(cse.Vehicle_Relationship__c.equalsIgnoreCase('REGISTERED KEEPER')){
						casesWithNewRegisteredKeeper.add(cse);
					}
					else if(cse.Vehicle_Relationship__c.equalsIgnoreCase('DRIVER')){
						casesWithNewDriver.add(cse);
					}
				}
			}
		}
		if(casesWithVehicleRelationship.size() > 0){
			SetAssetOwner(casesWithVehicleRelationship);
		}
		if(casesWithNewRegisteredKeeper.size() > 0){
			SetContactAssetRole(casesWithNewRegisteredKeeper, 'Current Registered Keeper');
		}
		if(casesWithNewDriver.size() > 0){
			SetContactAssetRole(casesWithNewDriver, 'Current Driver');
		}
	}
    
    public void SetAssetOwner(List<Case> currentCases){
    	List<Asset> assetsToUpdate = new List<Asset>();
    	Map<Id, Id> assetContactMap = new Map<Id, Id>();
		Map<Id, Id> contactAccountMap = new Map<Id, Id>();
		for(Case cse : currentCases){
			if(String.IsNotBlank(cse.ContactId) && String.IsNotBlank(cse.AssetId)){
				assetContactMap.put(cse.AssetId, cse.ContactId);
				contactAccountMap.put(cse.ContactId, null);
			}
		}
		for(Contact con : [SELECT Id, AccountId FROM Contact WHERE Id IN :contactAccountMap.keySet()]){
			contactAccountMap.put(con.Id, con.AccountId);
			if(con.Id.getSobjectType() == Schema.Account.SObjectType){
				contactAccountMap.put(con.Id, con.AccountId); //person account
			}
		}
		for(Asset a : [SELECT Id, AccountId FROM Asset WHERE Id IN :assetContactMap.keySet()]){
			Id contactId = assetContactMap.get(a.Id);
			if(contactAccountMap.containsKey(contactId)){
				Id accountId = contactAccountMap.get(contactId);
				if(accountId != null && accountId != a.AccountId){
					a.AccountId = accountId;
					assetsToUpdate.add(a);
				}
			}
		}
		if(assetsToUpdate.size() > 0){
			update assetsToUpdate;
		}
    }
    
    public void SetContactAssetRole(List<Case> currentCases, String newRole){
    	Map<Id, Id> assetContactMap = new Map<Id, Id>();
    	List<Asset> assetsToCreate = new List<Asset>(); //create a list of Assets with a Contact Role set - do not save these but pass them to AssetRoleSetter to create the new AssetRoles
    	for(Case cse : currentCases){
    		if(String.IsNotBlank(cse.ContactId) && String.IsNotBlank(cse.AssetId)){
    			assetContactMap.put(cse.AssetId, cse.ContactId); //what happens if we have multiple Cases for the same Asset with different Contacts?
    		}
    	}
    	if(assetContactMap.size() > 0){
    		//check to see if the relevant Contact is already set as the Role for the Asset
    		Set<String> existingRoles = new Set<String>();
    		for(Role__c role : [SELECT Id, Contact__c, Vehicle__c FROM Role__c WHERE Role__c = :newRole AND Vehicle__c IN :assetContactMap.keySet()]){
    			existingRoles.add(role.Contact__c + '-' + role.Vehicle__c);
    		}
    		for(Id assetId : assetContactMap.keySet()){
    			Id contactId = assetContactMap.get(assetId);
    			if(!existingRoles.contains(contactId + '-' + assetId)){
    				assetsToCreate.add(new Asset(Id=assetId, ContactId=contactId));
    			}
    		}		
    	}
    	if(assetsToCreate.size() > 0){
    		AssetRoleSetter caseAssetRoleSetter = new AssetRoleSetter();
    		caseAssetRoleSetter.CreateNewAssetRole(assetsToCreate, newRole);
    	}
    }
    
}