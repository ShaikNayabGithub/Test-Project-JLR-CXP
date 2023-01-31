public class ProfileDao {
	private static ProfileDao instance;
    private Map<String, Profile> profileMap;
    private ProfileDao(){
        this.profileMap = new Map<String, Profile>();
        List<Profile> profileList = [Select Id, Name From Profile];
        for(Profile p : profileList){
            this.profileMap.put(p.Name, p);
        }
    }
    
    public static ProfileDao getInstance(){
        if(instance == null){
            instance = new ProfileDao();
        }
        return instance;
    }
    
    public Id getProfileId(String profileName){
        if(this.profileMap.containsKey(profileName)){
	        return this.profileMap.get(profileName).Id;
        }
        return null;
    }
}