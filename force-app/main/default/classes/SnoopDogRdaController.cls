/**
 * Created by caleb@argologic.com.au on 1/07/2020.
 */

public with sharing class SnoopDogRdaController
{
    public static GetRdaResponseDto get(GetRdaRequestDto request)
    {
        List<RDA__c> rdas = [
                SELECT
                        Id,
                        Asset__r.VIN__c,
                        Handover_Date__c,
                        Make__c,
                        Model__c,
                        Asset__r.Registration_Number__c,
                        Sales_Person_RDA__c,
                        RecordType.DeveloperName,
                        Common_Sale_Type__c,
                        Submitted_Status__c,
                        Service_Plan_Type__r.Name,
                        Warranty_Start_Date__c,
                        CreatedDate,
                        Opportunity__r.Owner.Name
                FROM RDA__c
                WHERE CreatedDate >= :Datetime.now().addDays(-7)
        ];

        List<RdaResourceDto> resourceDtos = new List<RdaResourceDto>();
        for (RDA__c rda : rdas)
        {
            RdaAttributeDto attributeDto = new RdaAttributeDto();
            attributeDto.Vin = rda.Asset__r.VIN__c;
            attributeDto.HandoverDate = rda.Handover_Date__c;
            attributeDto.Make = rda.Make__c;
            attributeDto.Model = rda.Model__c;
            attributeDto.RegistrationNumber = rda.Asset__r.Registration_Number__c;
            attributeDto.SalesPersonRda = rda.Opportunity__r.Owner.Name;
            attributeDto.RecordType = rda.RecordType.DeveloperName;
            attributeDto.CommonSaleType = rda.Common_Sale_Type__c;
            attributeDto.Status = rda.Submitted_Status__c;
            attributeDto.ServicePlanType = rda.Service_Plan_Type__r.Name;
            attributeDto.WarrantyStartDate = rda.Warranty_Start_Date__c;
            attributeDto.CreatedDate = rda.CreatedDate;

            RdaResourceDto resourceDto = new RdaResourceDto();
            resourceDto.Attributes = attributeDto;
            resourceDto.Id = rda.Id;
            resourceDto.Type = 'Rda';
            resourceDtos.add(resourceDto);
        }
        GetRdaResponseDto res = new GetRdaResponseDto();
        res.Data = resourceDtos;
        return res;
    }
}