public class CustomAccount extends CustomSObject {
    public static final Schema.DescribeFieldResult PersonHomePhoneDescription = Account.PersonHomePhone.getDescribe();
    public static final Schema.DescribeFieldResult PhoneDescription = Account.Phone.getDescribe();
    public static final Schema.DescribeFieldResult PersonMobilePhoneDescription = Account.PersonMobilePhone.getDescribe();
    public static final Schema.DescribeFieldResult PersonEmailDescription = Account.PersonEmail.getDescribe();
    
    
    public final CustomSObjectField PersonHomePhone { get; private set; }
    public final CustomSObjectField Phone { get; private set; }
    public final CustomSObjectField PersonMobilePhone { get; private set; }
    public final CustomSObjectField PersonEmail { get; private set; }
    
    
    public CustomAccount()
    {
      this.PersonHomePhone = this.AddField(PersonHomePhoneDescription);
      this.Phone = this.AddField(PhoneDescription);
      this.PersonMobilePhone = this.AddField(PersonMobilePhoneDescription);
      this.PersonEmail = this.AddField(PersonEmailDescription);
    }
}