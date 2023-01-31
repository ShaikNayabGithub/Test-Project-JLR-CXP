/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 12/01/2020.
 */

public with sharing class GetCampaignsResponseDto  extends SimpleResourceResponseDto{

    public GetCampaignsResponseDto(){
        super();
    }

    public GetCampaignsResponseDto(List<Campaign> campaigns){
        this();
        for (Campaign campaign : campaigns){
            SimpleResourceDto resource = new SimpleResourceDto();
            resource.Type = 'Campaign';
            resource.Id = campaign.Id;
            resource.Attributes.Name = campaign.Name;
            this.Data.add(resource);
        }
    }

}