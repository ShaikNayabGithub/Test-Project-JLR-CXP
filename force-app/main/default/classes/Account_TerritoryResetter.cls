public class Account_TerritoryResetter {
	private final Territory_AssociationRetriever territoryAssociationRetriever;
	private final Territory_Evaluator territoryEvaluator;
	private final Territory_ObjectAssociationBuilder territoryAssociationBuilder;


	public Account_TerritoryResetter(Territory_AssociationRetriever territoryAssociationRetriever, 
			Territory_Evaluator territoryEvaluator,
			Territory_ObjectAssociationBuilder territoryAssociationBuilder) 
	{
		this.territoryAssociationRetriever = territoryAssociationRetriever;
		this.territoryEvaluator = territoryEvaluator;
		this.territoryAssociationBuilder = territoryAssociationBuilder;
	}


	public void ReevaluateTerritories(List<Account> accounts)
	{
		Map<Id, List<ObjectTerritory2Association>> existingTerritoryAssociationsByAccount = 
				this.territoryAssociationRetriever.RetrieveByAssociated(accounts);
		List<ObjectTerritory2Association> territoryAssociationsToInsert = new List<ObjectTerritory2Association>();

		for(Account account : accounts) {
			Set<Id> territoryIds = this.territoryEvaluator.GetTerritories(account);

			List<ObjectTerritory2Association> existingAccountTerritoryAssociations = 
					existingTerritoryAssociationsByAccount.get(account.Id);
			if(existingAccountTerritoryAssociations == null) existingAccountTerritoryAssociations = new List<ObjectTerritory2Association>();
			
			List<ObjectTerritory2Association> newTerritoryAssociations =
					this.territoryAssociationBuilder.Build(account.Id, territoryIds, 
							existingAccountTerritoryAssociations);
			territoryAssociationsToInsert.addAll(newTerritoryAssociations);
		}

		insert territoryAssociationsToInsert;
	}
}