public virtual class Territory_RuleItem_Conjunction implements Territory_RuleItem_I {
	private final List<Territory_RuleItem_I> ruleItems;
	private final Boolean isOr;


	public Territory_RuleItem_Conjunction(List<Territory_RuleItem_I> ruleItems, Boolean isOr)
	{
		this.ruleItems = ruleItems;
		this.isOr = isOr;
	}


	public Boolean Validate(SObject recordToValidate)
	{
		if(ruleItems.Size() == 0) return true;

		for(Territory_RuleItem_I ruleItem : ruleItems) {
			if(ruleItem.Validate(recordToValidate) == this.isOr) return this.isOr;
		}

		return !this.isOr;
	}
}