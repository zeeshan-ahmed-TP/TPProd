trigger ContactTrigger on Contact (After insert, before update) {
    List<Trigger_Setting__mdt> conTrg = new List<Trigger_Setting__mdt>([Select id,Disable_Triggers__c from Trigger_Setting__mdt where QualifiedApiName = 'Contact']);
    if(!conTrg.get(0).Disable_Triggers__c){
        if(Trigger.isAfter && Trigger.isInsert){
            ContactTriggerHandler.InBeforeToastShow(Trigger.newMap);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            ContactTriggerHandler.InBeforeToastShow(Trigger.newMap); 
        }
    }
}