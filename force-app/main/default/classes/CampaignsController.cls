/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 12/01/2020.
 */

public with sharing class CampaignsController {

    @AuraEnabled
    public static GetCampaignsResponseDto getCampaigns(GetCampaignsRequestDto request){
        List<Campaign> campaigns = [
                SELECT Id, Name
                FROM Campaign
                //WHERE IsActive = TRUE
                ORDER BY Name
        ];

        return new GetCampaignsResponseDto(campaigns);
    }
}