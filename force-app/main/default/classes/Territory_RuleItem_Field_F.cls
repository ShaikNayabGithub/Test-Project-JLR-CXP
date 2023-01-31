public class Territory_RuleItem_Field_F {
	private static Map<String, Schema.SObjectType> sObjectTypesByName { get {
		if(sObjectTypesByName == null) {
			sObjectTypesByName = Schema.getGlobalDescribe();
		}
		return sObjectTypesByName;
	} set; }

	private static final String EQUALS = 'equals';
	private static final String NOT_EQUALS = 'notEqual';


	public Territory_RuleItem_I Build(ObjectTerritory2AssignmentRuleItem assignmentRuleItem)
	{
		if(assignmentRuleItem.Value == null) { 
			assignmentRuleItem.Value = ''; 
		}
		Set<String> values = new Set<String>(assignmentRuleItem.Value.split(','));

		if(assignmentRuleItem.Operation == EQUALS) {
			return new Territory_RuleItem_FieldEquals(assignmentRuleItem.Field.split('\\.')[1],
					sObjectTypesByName.get(assignmentRuleItem.Rule.ObjectType), values);
		} else if(assignmentRuleItem.Operation == NOT_EQUALS) {
			return new Territory_RuleItem_FieldNotEquals(assignmentRuleItem.Field.split('\\.')[1],
					sObjectTypesByName.get(assignmentRuleItem.Rule.ObjectType), values);
		}
		throw new TypeException('Unsupported operation: ' + assignmentRuleItem.Operation);
	}
}