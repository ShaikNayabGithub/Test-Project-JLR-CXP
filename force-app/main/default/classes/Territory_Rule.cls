public class Territory_Rule extends Territory_RuleItem_Conjunction {
	public Schema.SObjectType SObjectType { get; private set; }
	public Set<Id> Territories { get; private set; }


	public Territory_Rule(Schema.SObjectType sObjectType, Set<Id> territories, 
			List<Territory_RuleItem_I> ruleItems) 
	{
		super(ruleItems, false);
		this.SObjectType = sObjectType;
		this.Territories = territories;
	}
}