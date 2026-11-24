public class opportunityTriggerHandler {
    public static void checkContactRoleOnOpp(Map<Id,Opportunity> mapOpp){
        
        Map<Id,List<OpportunityContactRole>> mapOppContactRoles = new Map<Id,List<OpportunityContactRole>>();
        List<OpportunityContactRole> lstOppConRoles = new List<OpportunityContactRole>();
		List<Opportunity> lstOppToBeUpdated = new List<Opportunity>();
    	Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        for(Opportunity opp : mapOpp.values()){
            if(opp.AccountId != null && opp.SBQQ__Renewal__c == false){
                setOppIds.add(opp.Id);
                setAccountIds.add(opp.AccountId);
            }
        }
        
        if(setOppIds.size() > 0){
            // Query the accounts and their primary contacts
            Map<Id, Account> mapAccounts = new Map<Id, Account>([
                SELECT Id, (SELECT Id, Name,Phone, isPrimaryContact__c FROM Contacts WHERE isPrimaryContact__c = true)
                FROM Account WHERE Id IN :setAccountIds]);
            for (OpportunityContactRole OCR: [SELECT id, opportunityid, contactid, role from OpportunityContactRole WHERE opportunityid in :setOppIds]) {
                if (mapOppContactRoles.containsKey(OCR.opportunityid)) {
                    mapOppContactRoles.get(OCR.opportunityid).add(OCR);
                } else {
                    mapOppContactRoles.put(OCR.opportunityid, new List<OpportunityContactRole> {OCR});
                }
            }
            OpportunityContactRole contactRole;
            Account acc;
            for(Id oppId : setOppIds){
                if(!mapOppContactRoles.containsKey(oppId)){
                    acc = mapAccounts.get(mapOpp.get(oppId).AccountId);
                    if(acc.Contacts.size() > 0){
                        contactRole = new OpportunityContactRole(
                            OpportunityId = oppId,
                            ContactId = acc.Contacts[0].Id,
                            IsPrimary = true
                            // Add any other required fields
                        );
                        lstOppConRoles.add(contactRole);
                        lstOppToBeUpdated.add(new Opportunity(Id = oppId, Phone__c = acc.Contacts[0].Phone));
                    }
                }
            }
            if(lstOppConRoles.size() > 0){
             	insert lstOppConRoles;
                update lstOppToBeUpdated;
            }
        }
    }
}