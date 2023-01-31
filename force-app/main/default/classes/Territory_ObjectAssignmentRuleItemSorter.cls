public class Territory_ObjectAssignmentRuleItemSorter {
	private static final ObjectTerritory2AssignmentRuleItem PLACEHOLDER_ITEM = new ObjectTerritory2AssignmentRuleItem();


	public Map<Id, List<ObjectTerritory2AssignmentRuleItem>> MapByRuleId(List<ObjectTerritory2AssignmentRuleItem> ruleItems)
	{
		Map<Id, List<ObjectTerritory2AssignmentRuleItem>> orderedRuleItemsByRuleId = new Map<Id, List<ObjectTerritory2AssignmentRuleItem>>();

		for(ObjectTerritory2AssignmentRuleItem ruleItem : ruleItems) {
			List<ObjectTerritory2AssignmentRuleItem> ruleItemList = orderedRuleItemsByRuleId.get(ruleItem.RuleId);
			if(ruleItemList == null) {
				ruleItemList = new List<ObjectTerritory2AssignmentRuleItem>();
				orderedRuleItemsByRuleId.put(ruleItem.RuleId, ruleItemList);
			}

			while(ruleItemList.Size() < ruleItem.SortOrder) {
				ruleItemList.add(PLACEHOLDER_ITEM);
			}

			ruleItemList[ruleItem.SortOrder - 1] = ruleItem;
		}

		return orderedRuleItemsByRuleId;
	}
}