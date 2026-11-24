/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_dfsle_EnvelopeStatusTrigger on dfsle__EnvelopeStatus__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(dfsle__EnvelopeStatus__c.SObjectType);
}