trigger EmailMessageTrigger on EmailMessage (before insert) {

    Id tier1RT = [select id from recordtype where developername='Tier_1' limit 1].id;

    Id queueId = [select Id from Group where Type = 'Queue' AND developername = 'Email_Support_Queue'].id;

    Set<Id> caseIds = new Set<Id>();

    Map<Id, Case> casesToInsert = new Map<Id, Case>();
    
    List<Case> casesToUpdate = new List<Case>();

    for(EmailMessage em : Trigger.New){if(em.parentId !=null && em.Incoming) caseIds.add(em.parentId);}

    Map<ID, Case> m = new Map<ID, Case>([SELECT Id, isClosed, ClosedDate, Status, AccountId, ContactId, RecordType.DeveloperName FROM Case where id in :caseIds]);
    
    for(EmailMessage em : Trigger.New){
        if(em.parentId != null && m.get(em.parentId) != null && m.get(em.parentId).isClosed == true && (m.get(em.parentId).ClosedDate.Date().daysBetween(Date.Today()) > 30 || m.get(em.parentId).RecordType.DeveloperName == 'Tier_1')){
            Case c = new Case(RecordTypeId=tier1RT, OwnerId=queueId, Origin='Email', Description=(em.Subject==null ? '': em.Subject)+'\n'+'\n'+(em.TextBody==null ? '':em.TextBody), AccountId = m.get(em.ParentId).AccountId, ContactId = m.get(em.ParentId).ContactId, ParentId = m.get(em.ParentId).Id);
            casesToInsert.put(em.id, c);
        }
        else if(em.parentId != null && m.get(em.parentId) != null && m.get(em.parentId).isClosed == true && m.get(em.parentId).ClosedDate.Date().daysBetween(Date.Today()) <= 30){
            m.get(em.parentId).Status = 'Reopened';
            casesToUpdate.add(m.get(em.parentId));            
        }
    }

    if(casesToInsert.size() > 0){

        insert casesToInsert.values();   

        for(EmailMessage em : Trigger.new){
            if(casesToInsert.keySet().contains(em.id)){em.ParentId=casesToInsert.get(em.id).id;}
        }
    }
    
    if(casesToUpdate.size() > 0){
       Update casesToUpdate; 
    }
}