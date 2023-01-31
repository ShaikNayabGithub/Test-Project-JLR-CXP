public class RoleStatusSetter_Factory {
    public RoleStatusSetter Build()
    {
    	RelatedRoleRetriever relatedRoleRetriever = new RelatedRoleRetriever();
    	RelatedRoleMatcher relatedRoleMatcher = new RelatedRoleMatcher(); 
    	
    	return new RoleStatusSetter(relatedRoleRetriever, relatedRoleMatcher);
    }
}