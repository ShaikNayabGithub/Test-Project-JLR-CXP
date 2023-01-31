/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 15/11/2019.
 */

public with sharing class ActivityResourceDto extends BaseResourceDto
{

    public ActivityResourceDto(){
        super();
        init();
    }

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new ActivityAttributeDto();
        }
        if (this.NextMilestone == null)
        {
            this.NextMilestone = new List<MilestoneTypeDto>();
        }
    }

    @AuraEnabled
    public ActivityAttributeDto Attributes {get; set;}

    @AuraEnabled
    public List<MilestoneTypeDto> NextMilestone {get; set;}
}