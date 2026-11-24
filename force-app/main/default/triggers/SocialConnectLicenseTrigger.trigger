trigger SocialConnectLicenseTrigger on Social_Connect_License__e (after insert) {
    Map<String,String> mapUlSubs = new Map<String,String>();
    for(Social_Connect_License__e scLicense : Trigger.New){
        mapUlSubs.put(scLicense.License_Id__c,scLicense.Subscription_Id__c);
    }
    
    Map<Id,User_Licensing__c> mapUL = new Map<Id,User_Licensing__c>([Select Id,Quantity__c,Username__c,Account__c,Parent_Account__c,
                                                                               Status__c,Product__c,Account__r.Name,Account__r.Email__c,Account__r.Phone,
                                                                               Account__r.Owner.Name, Start_Time_UTC__c,End_Time_UTC__c,Location_Radius__c,
                                                                               Daily_Budget__c from User_Licensing__c where Id IN : mapUlSubs.keySet()]);
    for(User_Licensing__c ul : mapUL.values()){
        ID jobID = System.enqueueJob(new AssignSocialConnectLicenseQable(ul,mapUlSubs.get(ul.Id)));
    }
}