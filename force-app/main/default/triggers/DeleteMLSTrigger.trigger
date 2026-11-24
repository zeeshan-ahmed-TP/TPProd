trigger DeleteMLSTrigger on MLS__c (after insert) {
    UserLicensingTriggerHandler handler = new UserLicensingTriggerHandler(Trigger.isExecuting, Trigger.size);
	
     if(Trigger.isInsert){
         set<ID> setOFMLSID = new set<ID>();
         set<ID> setOFLicenseID = new set<ID>();
         for(MLS__c m : trigger.New){
            system.debug('m.User_Licensing__c'+m.User_Licensing__c);
             setOFLicenseID.add(m.User_Licensing__c);
         }
         
         for(User_Licensing__c license : [select Id,Status__c,Product__c from User_Licensing__c where Status__c = 'Pending Fulfillment' and Product__c='Market Snapshot' and id=:setOFLicenseID]){
           
             string sid = license.Id;
              for(MLS__c ml: [select id,User_Licensing__c from MLS__c where User_Licensing__c=:license.Id] ){
                 setOFMLSID.add(ml.Id);
             }
                 
         }
          system.debug('setOFMLSID'+setOFMLSID);
          system.debug('setOFMLSID'+setOFLicenseID);

          Handler.OnAfterInsert(setOFLicenseID,setOFMLSID);
     }
}