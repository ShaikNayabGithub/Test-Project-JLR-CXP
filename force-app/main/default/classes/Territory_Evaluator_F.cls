public class Territory_Evaluator_F {

	// Start - Added by NTT as part of Code optimisation - 14/06/2021
	public static List<RuleTerritory2Association> retrievedRuleAssociations {
        get {
            if (retrievedRuleAssociations == null) {
                retrievedRuleAssociations = [SELECT RuleId, Territory2Id 
                                                FROM RuleTerritory2Association 
                                                WHERE Rule.IsActive = true]; // NTT - As on 14/06/2021 Query resulted in 140 records
            }
            return retrievedRuleAssociations;
        }
        set;
    }
    
    public static List<ObjectTerritory2AssignmentRuleItem> allRetrievedRuleItems {
        get {
            if (allRetrievedRuleItems == null) {
                allRetrievedRuleItems = [SELECT Field, Operation, SortOrder, Value, RuleId, Rule.Id, Rule.BooleanFilter, Rule.ObjectType 
                                        FROM ObjectTerritory2AssignmentRuleItem 
                                        WHERE Rule.IsActive = true]; // NTT - As on 14/06/2021 Query resulted in 642 records
            }
        return allRetrievedRuleItems;
        }
        set;
    }
	// End - Added by NTT as part of Code optimisation - 14/06/2021
    private final Territory_RuleItem_Field_F ruleItemFieldFactory = new Territory_RuleItem_Field_F();
    private final Territory_ObjectAssignmentRuleItemSorter objectAssignmentRuleItemSorter = new Territory_ObjectAssignmentRuleItemSorter();
    private final Territory_RuleAssociationMapper ruleAssociationMapper = new Territory_RuleAssociationMapper();


    public Territory_Evaluator Create(Set<Schema.SObjectType> sObjectTypes)
    {
        Map<String, Schema.SObjectType> sObjectTypesByName = new Map<String, Schema.SObjectType>();
        for(Schema.SObjectType sObjectType : sObjectTypes) {
            sObjectTypesByName.put(sObjectType.getDescribe().getName(), sObjectType);
        }
		
		// NTT - Removed below queries out of the method and added as static APEX properties.
		// NTT - Returned number of records is < 1000; Upgrade the code if hitting the limit;
        /*List<RuleTerritory2Association> retrievedRuleAssociations = [SELECT RuleId, Territory2Id 
                FROM RuleTerritory2Association WHERE Rule.IsActive = true];
        List<ObjectTerritory2AssignmentRuleItem> retrievedRuleItems = [SELECT Field, Operation, SortOrder, Value, RuleId, 
                Rule.Id, Rule.BooleanFilter, Rule.ObjectType FROM ObjectTerritory2AssignmentRuleItem 
                WHERE Rule.IsActive = true AND Rule.ObjectType IN: sObjectTypesByName.keySet()];*/

        List<ObjectTerritory2AssignmentRuleItem> retrievedRuleItems = new List<ObjectTerritory2AssignmentRuleItem>();
        for (ObjectTerritory2AssignmentRuleItem retrievedRuleItem : allRetrievedRuleItems) {
            if (sObjectTypesByName.containsKey(retrievedRuleItem.Rule.ObjectType)) {
                retrievedRuleItems.add(retrievedRuleItem);
            }
        }
        
        Map<Id, List<ObjectTerritory2AssignmentRuleItem>> orderedRuleItemsByRuleId = this.objectAssignmentRuleItemSorter.MapByRuleId(retrievedRuleItems);
        Map<Id, Set<Id>> territoryIdsByRuleId = this.ruleAssociationMapper.MapByRuleId(retrievedRuleAssociations);

        Set<Territory_Rule> territoryRules = new Set<Territory_Rule>();

        for(Id ruleId : orderedRuleItemsByRuleId.keySet()) {
            List<ObjectTerritory2AssignmentRuleItem> orderedRuleItems = orderedRuleItemsByRuleId.get(ruleId);
            if(orderedRuleItems.Size() == 0) continue;

            Schema.SObjectType sObjectType = sObjectTypesByName.get(orderedRuleItems[0].Rule.ObjectType);
            List<Territory_RuleItem_I> ruleItems = this.BuildRuleItems(orderedRuleItems[0].Rule.BooleanFilter, 
                    orderedRuleItems);          

            Territory_Rule territoryRule = new Territory_Rule(sObjectType, territoryIdsByRuleId.get(ruleId), 
                    ruleItems);
            territoryRules.add(territoryRule);
        }


        return new Territory_Evaluator(territoryRules);
    }


    private List<Territory_RuleItem_I> BuildRuleItems(String inputString, 
            List<ObjectTerritory2AssignmentRuleItem> orderedRuleItems)
    {
        Map<String, Territory_RuleItem_I> ruleMap = new Map<String, Territory_RuleItem_I>();

        String processingString = inputString;
        if(String.isEmpty(processingString)) {
            processingString = '1';
            for(Integer i = 2; i <= orderedRuleItems.Size(); i++) {
                processingString += ' AND ' + String.valueOf(i);
            }
        }

        while(processingString.contains('(')) {
            String lastClause = processingString.substringAfterLast('(');
            String closingBlock = lastClause.substringBefore(')');

            Territory_RuleItem_I conjunctionRule = this.BuildRule(closingBlock, orderedRuleItems, ruleMap);
            String ruleKey = 'X' + ruleMap.Size();
            processingString = processingString.replace('('+closingBlock + ')', ruleKey);
            ruleMap.put(ruleKey, conjunctionRule);
        }

        return new List<Territory_RuleItem_I> { this.BuildRule(processingString, orderedRuleItems, ruleMap) }; 
    }


    private Territory_RuleItem_I BuildRule(String bracketFreeString,
            List<ObjectTerritory2AssignmentRuleItem> orderedRuleItems,
            Map<String, Territory_RuleItem_I> ruleMap)
    {
        List<Territory_RuleItem_I> conjunctionRuleItems = new List<Territory_RuleItem_I>();

        String[] splitString = bracketFreeString.split('OR|or|Or|oR');
        Boolean isOr = (splitString.Size() > 1);
        if(!isOr) {
            splitString = bracketFreeString.split('AND|and|And|aNd|anD|AnD|aND|ANd');
        }

        for(String indexString : splitString) {
            if(String.isEmpty(indexString)) continue;

            Territory_RuleItem_I ruleItem = ruleMap.get(indexString.deleteWhitespace());
            if(ruleItem == null) {
                Integer index = Integer.valueOf(indexString.deleteWhitespace()) - 1;
                ruleItem = this.ruleItemFieldFactory.Build(orderedRuleItems[index]);
            }
            
            conjunctionRuleItems.add(ruleItem);
        }
        return new Territory_RuleItem_Conjunction(conjunctionRuleItems, isOr);
    }
}