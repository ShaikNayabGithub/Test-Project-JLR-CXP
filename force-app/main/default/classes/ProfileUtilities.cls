public class ProfileUtilities {
    public static Map<String, Profile> Profiles { get {
        if(Profiles == null) {
            Profiles = new Map<String, Profile>();
            List<Profile> profilesList = [Select Name From Profile];
            for(Profile profile : profilesList)
            {
                Profiles.put(profile.Name, profile);
            }
        }
        return Profiles;
    } private set; }
}