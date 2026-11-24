public class PorductOnAccountFromSubscriptionHandler {
    public static void populateProductAccountInsert(Map<Id,SBQQ__Subscription__c> subOldMap, Map<Id,SBQQ__Subscription__c> subNewMap){
        try{
            Set<Id> accIdSet = new Set<Id>();
            for(Id key : subNewMap.keySet()){
                accIdSet.add(subNewMap.get(key).SBQQ__Account__c);
            }
            Map<id,Account> accMap = new Map<Id, Account>([Select id,Top_Producer_Websites_License__c, Top_Producer_CRM_License__c, Top_Producer_Assistant_License__c, Market_Snapshot_License__c, Five_Street_License__c, Social_Connect_License__c,HomeIntel_License__c, HomeIntelle_Hub_License__c, House_Values_License__c from Account where id IN: accIdSet]);
            for(Id key : subNewMap.keySet()){
                id accId = subNewMap.get(key).SBQQ__Account__c	;
                if(subNewMap.get(key).SBQQ__ProductName__c == 'FiveStreet'){
                    if(accMap.get(accId).Five_Street_License__c == null)
                        accMap.get(accId).Five_Street_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Five_Street_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPMS){
                    if(accMap.get(accId).Market_Snapshot_License__c == null)
                        accMap.get(accId).Market_Snapshot_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Market_Snapshot_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPAL){
                    if(accMap.get(accId).Top_Producer_Assistant_License__c == null)
                        accMap.get(accId).Top_Producer_Assistant_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Top_Producer_Assistant_License__c += subNewMap.get(key).SBQQ__Quantity__c; 
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPCRM){
                    if(accMap.get(accId).Top_Producer_CRM_License__c == null)
                        accMap.get(accId).Top_Producer_CRM_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Top_Producer_CRM_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPWS){
                    if(accMap.get(accId).Top_Producer_Websites_License__c == null)
                        accMap.get(accId).Top_Producer_Websites_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Top_Producer_Websites_License__c += subNewMap.get(key).SBQQ__Quantity__c;              
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.HV){
                    if(accMap.get(accId).House_Values_License__c == null)
                        accMap.get(accId).House_Values_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).House_Values_License__c += subNewMap.get(key).SBQQ__Quantity__c;              
                }
                if(subNewMap.get(key).Product_Code__c == 'TPPRO-001'){
                    if(accMap.get(accId).Top_Producer_CRM_License__c == null)
                        accMap.get(accId).Top_Producer_CRM_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Top_Producer_CRM_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                    
                    if(accMap.get(accId).Market_Snapshot_License__c == null)
                        accMap.get(accId).Market_Snapshot_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Market_Snapshot_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                    
                    if(accMap.get(accId).HomeIntel_License__c == null)
                        accMap.get(accId).HomeIntel_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).HomeIntel_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                }
                
                if(subNewMap.get(key).Product_Code__c == 'SC-001' || subNewMap.get(key).Product_Code__c == 'SC-002' 
                   || subNewMap.get(key).Product_Code__c == 'SC-003' || subNewMap.get(key).Product_Code__c == 'SC-004'
                   || subNewMap.get(key).Product_Code__c == 'SC-005'){
                       if(accMap.get(accId).Social_Connect_License__c == null)
                           accMap.get(accId).Social_Connect_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                       else
                           accMap.get(accId).Social_Connect_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                   }
                
                if(subNewMap.get(key).Product_Code__c == 'HI-001'){
                    if(accMap.get(accId).HomeIntel_License__c == null)
                        accMap.get(accId).HomeIntel_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).HomeIntel_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.HIntH){
                    if(accMap.get(accId).HomeIntelle_Hub_License__c == null)
                        accMap.get(accId).HomeIntelle_Hub_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).HomeIntelle_Hub_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                }
                
                if(subNewMap.get(key).Product_Code__c == 'TPPROP-001'){
                    
                    if(accMap.get(accId).Top_Producer_CRM_License__c == null)
                        accMap.get(accId).Top_Producer_CRM_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Top_Producer_CRM_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                    
                    if(accMap.get(accId).Market_Snapshot_License__c == null)
                        accMap.get(accId).Market_Snapshot_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).Market_Snapshot_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                    
                    if(accMap.get(accId).HomeIntel_License__c == null)
                        accMap.get(accId).HomeIntel_License__c = subNewMap.get(key).SBQQ__Quantity__c;
                    else
                        accMap.get(accId).HomeIntel_License__c += subNewMap.get(key).SBQQ__Quantity__c;
                }
                
            }
            update accMap.values();
        }catch(Exception e){
            System.debug('Error---->'+e.getMessage());
            System.debug('Line---->'+e.getLineNumber());
        }
    }
    
    
    
    public static void populateProductAccountUpdate(Map<Id,SBQQ__Subscription__c> subOldMap, Map<Id,SBQQ__Subscription__c> subNewMap){
        try{
            Set<Id> accIdSet = new Set<Id>();
            for(Id key : subNewMap.keySet()){
          	      accIdSet.add(subNewMap.get(key).SBQQ__Account__c);
            }
            Map<id,Account> accMap = new Map<Id, Account>([Select id,Top_Producer_Websites_License__c, Top_Producer_CRM_License__c, Top_Producer_Assistant_License__c, Market_Snapshot_License__c, Five_Street_License__c,Social_Connect_License__c,HomeIntel_License__c, HomeIntelle_Hub_License__c, House_Values_License__c from Account where id IN: accIdSet]);
            for(Id key : subNewMap.keySet()){
                id accId = subNewMap.get(key).SBQQ__Account__c	;
                if(subNewMap.get(key).SBQQ__ProductName__c == 'FiveStreet'){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Five_Street_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Five_Street_License__c -= diff;
                        if(accMap.get(accId).Five_Street_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPMS){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Market_Snapshot_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Market_Snapshot_License__c -= diff;
                        if(accMap.get(accId).Market_Snapshot_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPAL){
                   if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_Assistant_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_Assistant_License__c -= diff;
                        if(accMap.get(accId).Top_Producer_Assistant_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPCRM){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_CRM_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_CRM_License__c -= diff;
                        if(accMap.get(accId).Top_Producer_CRM_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPWS){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_Websites_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_Websites_License__c -= diff;
                        if(accMap.get(accId).Top_Producer_Websites_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.TPHI){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntel_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntel_License__c -= diff;
                        if(accMap.get(accId).HomeIntel_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.HIntH){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntelle_Hub_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntelle_Hub_License__c -= diff;
                        if(accMap.get(accId).HomeIntelle_Hub_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                
                if(subNewMap.get(key).SBQQ__ProductName__c == ProductNames.HV){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).House_Values_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).House_Values_License__c -= diff;
                        if(accMap.get(accId).House_Values_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                
                if(subNewMap.get(key).Product_Code__c == 'SC-001' || subNewMap.get(key).Product_Code__c == 'SC-002' 
                   || subNewMap.get(key).Product_Code__c == 'SC-003' || subNewMap.get(key).Product_Code__c == 'SC-004'
                  || subNewMap.get(key).Product_Code__c == 'SC-005'){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Social_Connect_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Social_Connect_License__c -= diff;
                        if(accMap.get(accId).Social_Connect_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                
                if(subNewMap.get(key).Product_Code__c == 'TPPRO-001'){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_CRM_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_CRM_License__c -= diff;
                        if(accMap.get(accId).Top_Producer_CRM_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                    
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Market_Snapshot_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Market_Snapshot_License__c -= diff;
                        if(accMap.get(accId).Market_Snapshot_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                    
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntel_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntel_License__c -= diff;
                        if(accMap.get(accId).HomeIntel_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                
                if(subNewMap.get(key).Product_Code__c == 'TPPROP-001'){
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_CRM_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Top_Producer_CRM_License__c -= diff;
                        if(accMap.get(accId).Top_Producer_CRM_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                    
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Market_Snapshot_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).Market_Snapshot_License__c -= diff;
                        if(accMap.get(accId).Market_Snapshot_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                    
                    if(subOldMap.get(key).SBQQ__Quantity__c < subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff = subNewMap.get(key).SBQQ__Quantity__c - subOldMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntel_License__c += diff;
                    }
                    if(subOldMap.get(key).SBQQ__Quantity__c > subNewMap.get(key).SBQQ__Quantity__c ){
                        decimal diff =  subOldMap.get(key).SBQQ__Quantity__c - subNewMap.get(key).SBQQ__Quantity__c;
                        accMap.get(accId).HomeIntel_License__c -= diff;
                        if(accMap.get(accId).HomeIntel_License__c < 0){
                            subNewMap.get(key).addError('License already consumed');
                        }
                    }
                }
                
            }
            update accMap.values();
        }catch(Exception e){
            System.debug('Error---->'+e.getMessage());
            System.debug('Line---->'+e.getLineNumber());
        }
    }
}