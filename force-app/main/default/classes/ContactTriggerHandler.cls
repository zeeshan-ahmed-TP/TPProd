public class ContactTriggerHandler {

    public static void InBeforeToastShow(Map<Id,Contact> ContactMap){
        String ErrorMessage = Label.MAO_Exist;
        Set<Id> AcctIds = new Set<Id>();
        if(ContactMap != null){
        for(Contact cnt:ContactMap.values()){
            if(cnt.Main_Account_Owner__c)
            AcctIds.add(cnt.AccountId);
        }
        for(Contact cnt:[SELECT Id,AccountId,Main_Account_Owner__c FROM Contact WHERE AccountId IN :AcctIds AND Main_Account_Owner__c = true]){
            for(Contact cntNow:ContactMap.values()){
                if(cntNow.AccountId == cnt.AccountId && cntNow.Id != cnt.Id)
                   cntNow.adderror(ErrorMessage); 
            }
        }
            }
    }
}