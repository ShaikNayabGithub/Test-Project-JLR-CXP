public class BRS_PicklistGroup_F {
	public BRS_PicklistGroup_A Create(String pickListName, Boolean isLocal)
	{
		if(isLocal) {
			return new BRS_PicklistGroup_Local(pickListName);
		} else {
			return new BRS_PicklistGroup_Global(pickListName);
		}
	}
}