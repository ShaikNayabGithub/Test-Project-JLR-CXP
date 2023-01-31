public class Territory_RuleAssociationMapper {
	public Map<Id, Set<Id>> MapByRuleId(List<RuleTerritory2Association> ruleAssociations)
	{
		Map<Id, Set<Id>> territoryIdsByRuleId = new Map<Id, Set<Id>>();

		for(RuleTerritory2Association ruleAssociation : ruleAssociations) {
			Set<Id> ruleTerritoryIds = territoryIdsByRuleId.get(ruleAssociation.RuleId);
			if(ruleTerritoryIds == null) {
				ruleTerritoryIds = new Set<Id>();
				territoryIdsByRuleId.put(ruleAssociation.RuleId, ruleTerritoryIds);
			}
			ruleTerritoryIds.add(ruleAssociation.Territory2Id);
		}

		return territoryIdsByRuleId;
	}
}