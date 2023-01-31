/**
 * Created by caleb@argologic.com.au on 19/03/2020.
 */

public without sharing class InvocableSetAccountOnRda
{
    @InvocableMethod
    public static void setRetailerOnRda(List<String> rdaIds)
    {
        List<RDA__c> rdas = [
                SELECT Id, OwnerId, CreatedById, Asset__r.Brand__r.Name
                FROM RDA__c
                Where Id IN :rdaIds
        ];

        List<String> ownerIds = new List<String>();
        for (RDA__c rda : rdas)
        {
            if (rda.OwnerId != null)
            {
                ownerIds.add(rda.OwnerId);
            }
            else if (rda.CreatedById != null)
            {
                ownerIds.add(rda.CreatedById);
            }
        }

        Map<String, User> ownerIdToUserMap = new Map<String, User> ([
                SELECT Id, Contact.AccountId
                FROM User
                WHERE Id IN :ownerIds
        ]);

        Map<String, String> rdaIdToParentAccountIdJag = new Map<String, String>();
        Map<String, String> rdaIdParentAccountIdLandRover = new Map<String, String>();
        for (RDA__c rda : rdas)
        {
            String parentAccountId;
            if (ownerIdToUserMap.containsKey(rda.OwnerId))
            {
                parentAccountId = ownerIdToUserMap.get(rda.OwnerId).Contact.AccountId;
            }
            else if (ownerIdToUserMap.containsKey(rda.CreatedById))
            {
                parentAccountId = ownerIdToUserMap.get(rda.CreatedById).Contact.AccountId;
            }
            if (parentAccountId == null) continue;

            if (rda.Asset__r.Brand__r.Name == Constants.MAKE_NAME_JAGUAR)
            {
                rdaIdToParentAccountIdJag.put(rda.Id, parentAccountId);
            }
            else if (rda.Asset__r.Brand__r.Name == Constants.MAKE_NAME_LAND_ROVER)
            {
                rdaIdParentAccountIdLandRover.put(rda.Id, parentAccountId);
            }
        }

        Map<String, Account> parentIdToChildJag = ChildDealershipUtility.getParentToChildDealershipMap(rdaIdToParentAccountIdJag.values(), true);
        Map<String, Account> parentIdToChildLandRover = ChildDealershipUtility.getParentToChildDealershipMap(rdaIdParentAccountIdLandRover.values(), false);

        List<RDA__c> rdasToUpdate = new List<RDA__c>();
        for (String rdaId : rdaIdToParentAccountIdJag.keySet())
        {
            RDA__c rda = new RDA__c();
            rda.Id = rdaId;
            if (!rdaIdToParentAccountIdJag.containsKey(rdaId)) continue;
            String parentAccountId = rdaIdToParentAccountIdJag.get(rdaId);
            if (!parentIdToChildJag.containsKey(parentAccountId)) continue;
            String childAccountId = parentIdToChildJag.get(parentAccountId).Id;
            rda.Dealership__c = childAccountId;
            rdasToUpdate.add(rda);
        }
        for (String rdaId : rdaIdParentAccountIdLandRover.keySet())
        {
            RDA__c rda = new RDA__c();
            rda.Id = rdaId;
            if (!rdaIdParentAccountIdLandRover.containsKey(rdaId)) continue;
            String parentAccountId = rdaIdParentAccountIdLandRover.get(rdaId);
            if (!parentIdToChildLandRover.containsKey(parentAccountId)) continue;
            String childAccountId = parentIdToChildLandRover.get(parentAccountId).Id;
            rda.Dealership__c = childAccountId;
            rdasToUpdate.add(rda);
        }
        update rdasToUpdate;
    }
}