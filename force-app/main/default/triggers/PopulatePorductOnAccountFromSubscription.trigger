trigger PopulatePorductOnAccountFromSubscription on SBQQ__Subscription__c (after insert, after update) {
	if(trigger.isUpdate && trigger.isAfter)
        PorductOnAccountFromSubscriptionHandler.populateProductAccountUpdate(trigger.oldMap,trigger.newMap);
    if(trigger.isInsert && trigger.isAfter)
        PorductOnAccountFromSubscriptionHandler.populateProductAccountInsert(trigger.oldMap,trigger.newMap);
}