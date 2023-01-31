public class Territory_Evaluator {
	private final Set<Territory_Rule> rules;


	public Territory_Evaluator(Set<Territory_Rule> rules)
	{
		this.rules = rules;
	}


	public Set<Id> GetTerritories(SObject recordToEvaluate)
	{
		Set<Id> territories = new Set<Id>();

		for(Territory_Rule rule : rules) {
			if(rule.SObjectType == recordToEvaluate.getSObjectType() && rule.Validate(recordToEvaluate) &&
					rule.Territories != null && rule.Territories.size() > 0) {
				territories.addAll(rule.Territories);
			}
		}

		return territories;
	}
}