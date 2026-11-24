trigger taskTrigger on Task (before insert, before update) {
    If(Trigger.isBefore){
        if(Trigger.isInsert){
            taskTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            taskTriggerHandler.beforeInsert(Trigger.new);
        }
    }
}