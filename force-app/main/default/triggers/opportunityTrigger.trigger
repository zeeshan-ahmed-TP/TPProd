trigger opportunityTrigger on Opportunity (after insert, after update) {
    if(Trigger.IsAfter){
        if(Trigger.IsInsert || Trigger.IsUpdate){
            opportunityTriggerHandler.checkContactRoleOnOpp(Trigger.newMap);
        }
    }
}