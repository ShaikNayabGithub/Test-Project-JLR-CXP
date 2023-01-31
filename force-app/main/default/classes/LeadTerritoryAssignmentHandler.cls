public with sharing class LeadTerritoryAssignmentHandler {
    
    

    public void applyKoreanRules(List<Lead> newLeads) {
        List<Lead> koreanLeads = new List<Lead>();
        Set<Id> koreanUserLeadOwners = new Set<Id>();
        for(Lead l : newLeads) {
            String ownerId = (String) l.ownerId;
            if(l.Country_ISO_Code__c == 'KR' && ownerId.left(3) == '005') {
                koreanLeads.add(l);
                koreanUserLeadOwners.add(l.OwnerId);
            }
        }
        if(koreanUserLeadOwners.size() == 0) {
            System.debug('koreanUserLeadOwners.size() == 0');
            return;
        }

        
        Map<Id, User> subTeamOwnerDetails = new Map<Id, User>([
            SELECT Id, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Division
            FROM User
            WHERE Id IN :koreanUserLeadOwners
            AND Dealer_CI_Code__c != null AND Dealer_CI_Code_2__c != null AND Division != null
        ]);

        if(subTeamOwnerDetails.size() == 0 ) {
            System.debug('subTeamOwnerDetails.size() == 0');
            return;
        }

        Set<String> subTeamTerritoryNames = new Set<String>();
        for(User krUser : subTeamOwnerDetails.values()) {
            String subTeamName = 'KR_';
            subTeamName += krUser.Dealer_CI_Code__c.trim() + '_';
            subTeamName += krUser.Dealer_CI_Code_2__c.trim() + '_';
            subTeamName += krUser.Division.trim().replaceAll(' ', '_');
            subTeamTerritoryNames.add(subTeamName);
        }

        Map<String, Id> territoryDeveloperNameToId = new Map<String, Id>();
        for (Territory2 territory :  [SELECT Id, DeveloperName  from Territory2 WHERE DeveloperName IN :subTeamTerritoryNames]) {
            territoryDeveloperNameToId.put(territory.DeveloperName, territory.Id);
        }


        List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();        
        for(Lead krLead : koreanLeads) {
            User krUser = subTeamOwnerDetails.get(krLead.ownerId);
            String subTeamName = 'KR_';
            subTeamName += krUser.Dealer_CI_Code__c.trim() + '_';
            subTeamName += krUser.Dealer_CI_Code_2__c.trim() + '_';
            subTeamName += krUser.Division.trim().replaceAll(' ', '_');


            ObjectTerritory2Association leadTerritoryAssociation = new ObjectTerritory2Association();
            leadTerritoryAssociation.AssociationCause = 'Territory2Manual';
            leadTerritoryAssociation.ObjectId = krLead.Id;
            leadTerritoryAssociation.Territory2Id = territoryDeveloperNameToId.get(subTeamName);
            if(leadTerritoryAssociation.ObjectId != null && leadTerritoryAssociation.Territory2Id != null) {
                territoryAssociations.add(leadTerritoryAssociation);
            } 
            
        }

        if(territoryAssociations.size() > 0) {
            insert territoryAssociations;
        }

    }
}