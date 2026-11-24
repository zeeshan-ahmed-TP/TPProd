public class taskTriggerHandler {
    public static void beforeInsert(List<Task> lstTasks){
        List<Task> lstAirCallTasks = new List<Task>();
        for(Task task : lstTasks){
            if(task.aircall__CallId__c != null && task.CallDisposition != null){
                lstAirCallTasks.add(task);
            }
        }
        if(lstAirCallTasks.size() > 0){
            parseCallResult(lstAirCallTasks);
        }
    }
    public static void parseCallResult(List<Task> lstTasks){
        String tempCallDis;
        List<String> callTags;
        for(Task task : lstTasks){
            tempCallDis = task.CallDisposition.substringBefore(',\'aircall');
            if(tempCallDis != null){
                tempCallDis = tempCallDis.replace('[','');
                tempCallDis = tempCallDis.replace('\'','');
                callTags = tempCallDis.Split(',');
                for(String callTag : callTags){
                    System.debug('callTag.startsWithIgnoreCase' + callTag.startsWithIgnoreCase('TPSales_'));
                    if(callTag.startsWithIgnoreCase('TPInbound_')){
                        task.Aircall_tag_Inbound__c = callTag;
                        System.debug('task.Aircall_tag_Inbound__c: ' + task.Aircall_tag_Inbound__c);
                    }
                    if(callTag.startsWithIgnoreCase('TPSales_') || callTag.startsWithIgnoreCase('TPCS_')){
                        task.Aircall_tag_disposition__c = callTag;
                        if(!task.Subject.contains(task.Aircall_tag_disposition__c)){
                         	task.Subject = task.Aircall_tag_disposition__c + ' - ' + task.Subject;   
                        }
                        System.debug('task.Aircall_tag_disposition__c: ' + task.Aircall_tag_disposition__c);
                    }
                    System.debug('Temp String: ' + callTag);
                }
            }
        }
    }
}