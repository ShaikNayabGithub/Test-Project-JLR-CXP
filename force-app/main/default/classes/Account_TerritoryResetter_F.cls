public class Account_TerritoryResetter_F {
	public Account_TerritoryResetter Create()
	{
		Territory_Evaluator_F territoryEvaluatorFactory = new Territory_Evaluator_F();

		Territory_AssociationRetriever territoryAssociationRetriever = new Territory_AssociationRetriever();
		Territory_Evaluator territoryEvaluator = territoryEvaluatorFactory.Create(new Set<Schema.SObjectType> { Account.SObjectType });
		Territory_ObjectAssociationBuilder territoryAssociationBuilder = new Territory_ObjectAssociationBuilder();

		return new Account_TerritoryResetter(territoryAssociationRetriever, territoryEvaluator, 
				territoryAssociationBuilder);
	}
}