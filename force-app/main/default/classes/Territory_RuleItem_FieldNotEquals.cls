public class Territory_RuleItem_FieldNotEquals implements Territory_RuleItem_I {
	private final String field;
	private final Schema.SObjectType sObjectType;
	private final Set<String> values;


	public Territory_RuleItem_FieldNotEquals(String field, Schema.SObjectType sObjectType,
			Set<String> values) {
		this.field = field;
		this.sObjectType = sObjectType;
		this.values = values;
	}


	public Boolean Validate(SObject recordToValidate)
	{
		object fieldValue = recordToValidate.get(this.field);

		if(recordToValidate.getSObjectType() == this.SObjectType) {
			if(fieldValue == null) {
				if(!this.values.contains('')) {
					return true;
				}
			} else {
				if(!this.values.contains(String.valueOf(fieldValue))) {
					return true;
				}
			}
		}

		return false;
	}
}