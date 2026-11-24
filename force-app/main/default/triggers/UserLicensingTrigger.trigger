trigger UserLicensingTrigger on User_Licensing__c (after insert,after update) {
    List<Trigger_Setting__mdt> ulTrigger = new List<Trigger_Setting__mdt>([Select id,Disable_Triggers__c from Trigger_Setting__mdt where QualifiedApiName = 'User_licensing']);
    if(!ulTrigger.get(0).Disable_Triggers__c){
        UserLicensingTriggerHandler handler = new UserLicensingTriggerHandler(Trigger.isExecuting, Trigger.size);
        
        if( Trigger.isInsert && UserLicensingRecursion.flag){
            UserLicensingRecursion.flag = false;
            Set<Id> licenseIds = new Set<Id>();
            for(User_Licensing__c license : trigger.New){
                if(license.Status__c != null && license.Status__c.equals('Pending Fulfillment')){
                    licenseIds.add(license.Id);   
                }
            }
            handler.OnAfterInsert(licenseIds,null);
        } else if(Trigger.isUpdate){
            Set<Id> licenseIds = new Set<Id>();
            
            for(User_Licensing__c license : trigger.New){
                if(trigger.oldMap.get(license.Id).Status__c != 'Pending Fulfillment'){
                    licenseIds.add(license.Id);   
                }  
            }
            
            if(UserLicensingRecursion.flag){
                UserLicensingRecursion.flag = false;
                if(!System.isFuture() && !System.isBatch()){
                    handler.OnAfterUpdate(licenseIds,trigger.oldMap);   
                }
            }
            handler.refundLicensesToAccount(Trigger.New, Trigger.oldMap);
            handler.adjustLicensesFromAccount(Trigger.New, Trigger.oldMap);
            handler.accountChangeLicenseAdjustment(Trigger.New, Trigger.oldMap);
        }   
    }
}