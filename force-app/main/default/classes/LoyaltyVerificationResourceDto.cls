/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 24/10/2019.
 */

global with sharing class LoyaltyVerificationResourceDto extends BaseResourceDto{

    global LoyaltyVerificationResourceDto(){
        super();
        init();
    }
    private void init(){
        this.Type = 'LoyaltyVerification';
        if (this.Attributes == null){
            this.Attributes = new LoyaltyVerificationAttributeDto();
        }
    }
    global LoyaltyVerificationAttributeDto Attributes {get; set;}
}