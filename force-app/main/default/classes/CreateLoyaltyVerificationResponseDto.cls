/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 24/10/2019.
 */

global with sharing class CreateLoyaltyVerificationResponseDto extends BaseResponseDto{

    global CreateLoyaltyVerificationResponseDto(){
        super();
        init();
    }

    private void init() {
        if (this.Data == null) {
            this.Data = new List<LoyaltyVerificationResourceDto>();
        }
    }

    global List<LoyaltyVerificationResourceDto> Data { get; set; }
}