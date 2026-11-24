trigger LeadTrigger on Lead (after insert,after update, before update) {
    
    if(!(trigger.isupdate && trigger.isbefore)){
    if(LeadConvertClass.flag==true){
        LeadConvertClass.flag=false;
        LeadConvertClass.LinkAccountLead(trigger.new);
       
    }
    }
    if(trigger.isInsert){
        System.debug('!Before entery-->: +'+convertleadtriggerhandler.stoptrigger);
        if(!convertleadtriggerhandler.stoptrigger){
           // system.debug('convertleadtriggerhandler.stoptrigger::::'+convertleadtriggerhandler.stoptrigger);
            convertleadtriggerhandler.stoptrigger =true;
            //convertleadtriggerhandler convertLead = new convertleadtriggerhandler();
            convertleadtriggerhandler.leadAccountInsert(trigger.new);
        }
    }
    if(trigger.isupdate && trigger.isAfter){
        System.debug('insidetrigger');
        List<Lead> leadList=new List<Lead>();
        for(Lead lead:trigger.new){
            System.debug('--->:'+lead);
            if(lead.IsConverted && lead.Account__c!=null){
                leadList.add(Lead);
            }
        }
        if(!convertleadtriggerhandler.stoptrigger){
            system.debug('convertleadtriggerhandler.stoptrigger::::'+convertleadtriggerhandler.stoptrigger);
            convertleadtriggerhandler.stoptrigger =true;
            //convertleadtriggerhandler convertLead = new convertleadtriggerhandler();
            convertleadtriggerhandler.leadupdate(trigger.new);
            system.debug('Triger '+trigger.new);
        }
        // LeadConvertClass.leadConvert(leadList);
         //convertleadtriggerhandler.stoptrigger =true;
    }
    if(trigger.isupdate && trigger.isbefore)
    {
        for(Lead ld: trigger.new){
            if(ld.Status == 'Working - Open Deal'){
                ld.Converted__c = true;
            }
        }    	
            
            
    }
    
    
    
    
    
    
}