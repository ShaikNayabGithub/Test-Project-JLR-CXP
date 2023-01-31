public class BRS_TranslationGroup_F {
	public BRS_TranslationGroup_A Create(String language, Boolean isLocal)
	{
		if(isLocal) {
			return new BRS_TranslationGroup_Local(Asset.sObjectType.getDescribe().getName(), language);
		} else {
			return new BRS_TranslationGroup_Global(language);
		}
	}
}