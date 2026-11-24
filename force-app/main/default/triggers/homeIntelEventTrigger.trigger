trigger homeIntelEventTrigger on HomeIntel_License__e (after insert) {
	Map<String,String> mapUlSubs = new Map<String,String>();
    for(HomeIntel_License__e hmIntLicense : Trigger.New){
        mapUlSubs.put(hmIntLicense.License_Id__c,hmIntLicense.Subscription_Id__c);
    }
    
    Map<Id,User_Licensing__c> mapUL = new Map<Id,User_Licensing__c>([Select Id,Quantity__c,Username__c,Account__c,Parent_Account__c,
                                                                               Status__c,Product__c,Account__r.Name,Account__r.Email__c,Account__r.Phone,
                                                                               Account__r.Owner.Name from User_Licensing__c where Id IN : mapUlSubs.keySet()]);
    for(User_Licensing__c ul : mapUL.values()){
        ID jobID = System.enqueueJob(new AssignhomeIntelLicenseQable(ul,mapUlSubs.get(ul.Id)));
    }
}