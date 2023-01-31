public class aop_CheckfrontItemLogic {
    public void HandleCampaignCreation(aop_CheckfrontItemParser.aop_ItemContainer container)
    {
        aop_Area_Configuration__c areaConfig = GetAreaConfig(container.host);
        if(container != null && areaConfig != null)
        {
            if(container.type == 'item' && container.action ==  'insert')
            {
                if(areaConfig != null && areaConfig.aop_Checkfront_AOP_Id__c != null)
                {
                    if(container.item.category_id == integer.valueOf(areaConfig.aop_Checkfront_AOP_Id__c))
                    {
                        Campaign newCamp = CreateNewCampaign(container, areaConfig);
                    }
                    else
                    {
                        return;
                    }
                }
            }
            else if(container.type == 'item' && container.action == 'update')
            {
                Campaign existing = RetrieveExistingCampaign(container);
                if(existing != null  && areaConfig != null)
                {
                    UpdateExistingCampaign(container, existing, areaConfig);

                }
            }
        }
    }

    public aop_CheckfrontItemCalloutParser.aop_Container HandleUpdateCallout(aop_Area_Configuration__c areaConfig, aop_CheckfrontItemParser.aop_ItemContainer container)
    {
        if(container != null && areaConfig != null && container.item != null & container.item.item_id != null)
        {
            aop_CheckfrontBookingCallout calloutClass = new aop_CheckfrontBookingCallout();
            Date todayDate = Date.today();
            string month = string.valueOf(todayDate.month());
            string day = string.valueOf(todayDate.day());
            if(todayDate.month() < 10)
            {
            	month = '0' + month;
            }
            if(todayDate.day() < 10)
            {
            	day = '0' + day;
            }         
            string todayString = string.valueOf(todayDate.year()) + month + day;
            string query = '/api/3.0/item/'+ container.item.item_id + '/?start_date='  + todayString + '&end_date=next year';
            string jsonString = calloutClass.GetCalloutResponse(areaConfig, query);
            aop_CheckfrontItemCalloutParser.aop_Container calloutContainer = calloutClass.ParseToCalloutItem(jsonString);
            return calloutContainer;
        }
        return null;
    }

    public Campaign SetCampaignParamFromCallout(aop_CheckfrontItemCalloutParser.aop_Container calloutContainer, Campaign existingCampaign)
    {
        string existingValues = existingCampaign.aop_Event_Features__c;
        string newValues = '';
        List<aop_Event_Feature_Mapping__c> mappingList = aop_Event_Feature_Mapping__c.getAll().values();
        if(calloutContainer!= null && calloutContainer.item != null && calloutContainer.item.param != null)
        {
	        Map<string, aop_CheckfrontItemCalloutParser.aop_CalloutParam> paramMap = calloutContainer.item.param;
	        for(aop_Event_Feature_Mapping__c mapping : mappingList)
	        {
	            if(paramMap.containsKey(mapping.Name))
	            {
	                newValues = newValues + mapping.Feature_Picklist_String__c + ';';
	            }
	        }
	        if(!newValues.equals(existingValues))
	        {
	            existingCampaign.aop_Event_Features__c = newValues;
	        }
        }
        return existingCampaign;
    }

    public aop_Area_Configuration__c GetAreaConfig(string checkfrontURL)
    {
        List<aop_Area_Configuration__c> areaConfigs = [SELECT aop_New_Record_Owner__c, aop_Checkfront_Instance__c, aop_Checkfront_AOP_ID__c, aop_Checkfront_Token__C FROM aop_Area_Configuration__c WHERE aop_Checkfront_Instance__c =: checkfrontURL];
        if(!areaConfigs.isEmpty())
        {
            return areaConfigs[0];
        }
        return null;
    }

    public Campaign CreateNewCampaign(aop_CheckfrontItemParser.aop_ItemContainer container, aop_Area_Configuration__c areaConfig)
    {
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        List<RecordType> memberRts = [SELECT Id FROM RecordType WHERE Name = 'Event Booking' 
        							  AND sObjectType = 'CampaignMember' LIMIT 1];
        List<Vehicle_Specification__c> makeModel = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Vehicle_Specification__c 
        											WHERE Name = 'Jaguar'];
        if(!rts.isEmpty() && !memberRts.isEmpty())
        {
            RecordType memberRT = memberRts[0];
            aop_CheckfrontItemParser.aop_NewItem  item =  container.item;
        	Campaign newCamp = new Campaign(Campaign_Brand__c = 'Jaguar', CampaignMemberRecordTypeId = memberRT.Id, 
        									Campaign_Level__c = 'NSC', Type_1__c = 'EXP', ExpectedResponse = 100, 
        									Name = item.name, aop_Checkfront_Instance__c = container.host, 
        									aop_Checkfront_Item_Id__c = string.valueOf(item.item_id), 
        									aop_Event_Upload_Complete__c = false, 
        									RecordTypeId = rts[0].Id, aop_SKU__c = item.sku, Market_ID__c = 'IN');
            newCamp.Status = System.label.aop_Hidden;
            if(!makeModel.isEmpty())
            {
                for(Vehicle_Specification__c vehSpec : makeModel)
                {
                    if(vehSpec.RecordType.DeveloperName == 'Make' && newCamp.Campaign_Make__c == null)
                    {
                        newCamp.Campaign_Make__c = vehSpec.Id;
                    }
                }
            }
            insert newCamp;
            return newCamp;
        }
        return null;
    }

    public Campaign RetrieveExistingCampaign(aop_CheckfrontItemParser.aop_ItemContainer container)
    {
        List<Campaign> existingCamp = [SELECT Id, aop_Event_Features__c FROM Campaign 
        							   WHERE aop_Checkfront_Instance__c =: container.host 
        							   AND aop_Checkfront_Item_Id__c =: string.valueOf(container.item.item_id) LIMIT 1];
        if(!existingCamp.isEmpty())
        {
            return existingCamp[0];
        }
        return null;
    }

    public Campaign SetStartAndEndDate(aop_CheckfrontItemCalloutParser.aop_Container item, Campaign existingCamp)
    {
        if(item != null && existingCamp != null)
        {
            if(item.events != null && !item.events.isEmpty())
            {
                List<aop_CheckfrontItemCalloutParser.aop_CalloutEvent> eventsList = item.events.values();
                string startDate = eventsList[0].start_date;
                string endDate = eventsList[0].end_date;

                if(startDate.length() == 8)
                {
                    integer month = integer.valueOf(startdate.substring(4, 6)); 
                    integer day = integer.valueOf(startDate.substring(6));
                    integer year = integer.valueOf(startDate.substring(0, 4));
                    existingCamp.StartDate = Date.newInstance(year, month, day);
                }
                if(endDate.length() == 8)
                {
                    integer month = integer.valueOf(enddate.substring(4, 6)); 
                    integer day = integer.valueOf(endDate.substring(6));
                    integer year = integer.valueOf(endDate.substring(0, 4));
                    existingCamp.EndDate = Date.newInstance(year, month, day);
                }

            }
            else
            {
                existingCamp.StartDate = null;
                existingCamp.EndDate  = null;
            }
        }
        return existingCamp;
    }

    public void UpdateExistingCampaign(aop_CheckfrontItemParser.aop_ItemContainer container, Campaign existingCamp, aop_Area_Configuration__C areaConfig)
    {
        if(existingCamp != null && container != null)
        {
            aop_CheckfrontItemParser.aop_NewItem item = container.item;
            existingCamp.Name = item.name;
            existingCamp.aop_SKU__c = item.sku;
            existingCamp = SetCampaignImages(existingCamp, item);   
            if(item.meta.location != null)
            {
                if(item.meta.location.str != null)
                {
                    string addressSpecialChars = item.meta.location.str;
                    existingCamp.aop_Venue_Address__c = addressSpecialChars.unescapeUnicode();
                }
                if(item.meta.location.link != null)
                {
                    string locString = item.meta.location.link;
                    string locStringEscape = locstring.replace('\\/', '/');
            		existingCamp.aop_Google_Maps_Link__c  = locStringEscape.unescapeUnicode();
                }
            }
            aop_CheckfrontItemCalloutParser.aop_Container newContainer = HandleUpdateCallout(areaConfig, container);
            if(newContainer != null)
            {
                existingCamp = SetCampaignParamFromCallout(newContainer, existingCamp);
            	existingCamp = SetStartAndEndDate(newContainer, existingCamp);
            }
            existingCamp = SetCampaignParamFromCallout(newContainer, existingCamp);
            existingCamp = SetStartAndEndDate(newContainer, existingCamp);
            if(item.visibility == '*')
            {
                existingCamp.Status = System.label.aop_Visible;
            }
            else
            {
                existingCamp.Status = System.label.aop_Hidden;
            }
           	update existingCamp;
        }
    }

    public Campaign SetCampaignImages(Campaign existingCamp, aop_CheckfrontItemParser.aop_NewItem item)
    {
        if(item.image.one != null)
            {
                existingCamp.aop_Event_Image_1__c = item.image.one.src;
            }
            if(item.image.two != null)
            {
                existingCamp.aop_Event_Image_2__c = item.image.two.src;
            }
            if(item.image.three != null)  
            {
                existingCamp.aop_Event_Image_3__c = item.image.three.src;
            }
            if(item.image.four != null)
            {
				existingCamp.aop_Event_Image_4__c = item.image.four.src;                
            }
            if(item.image.five != null)
            {
                existingCamp.aop_Event_Image_5__c = item.image.five.src;
            }     
        return existingCamp;
    }
}