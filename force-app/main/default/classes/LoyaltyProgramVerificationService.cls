/**
 * Created by Ethan Sargent on 21/10/19.
 */

@RestResource(UrlMapping='/v1/LoyaltyProgramVerification/*')
global with sharing class LoyaltyProgramVerificationService {

    @HttpPost
    global static CreateLoyaltyVerificationResponseDto create(CreateLoyaltyVerificationRequestDto request)
    {
        return QantasController.createLoyaltyProgramVerification(request);
    }
}