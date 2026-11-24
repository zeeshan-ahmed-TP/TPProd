({
    doInit : function(component, event, helper) {
        
        console.log('inside in it handler');
    },
    onfocus : function(component,event,helper){
        //document.getElementById("lookupField").disabled = true;
        console.log('inside onfocus');
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    selectRecord : function(component, event, helper) {
        try{
            // get the selected Account record from the COMPONETN event 	 
            //var selId = event.currentTarget;
            var selId = event.currentTarget.dataset.id;
            var selName = event.currentTarget.dataset.name;
            //component.set('v.Idmls',selId);
            var pillObj = {'ID':'','Name':''};
            pillObj.ID = selId;
            pillObj.Name = selName;
            var pillListval = component.get("v.pillList");
            pillListval.push(pillObj);
            component.set("v.pillList" , pillListval);
            console.log('value pillList--->'+JSON.stringify(component.get("v.pillList")));
            console.log('lookup Id: ',selId);
            component.set("v.selectedRecord" , selName); 
            var ListIds = [];
            for (let i = 0; i < pillListval.length; i++) {
                ListIds.push(pillListval[i].ID);
            }
            
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
            
            var changeStyle = component.get("v.showPill");
            if(changeStyle){
                var forclose = component.find("lookup-pill");
                $A.util.removeClass(forclose, 'slds-show');
                $A.util.addClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                
                var lookUpTarget = component.find("lookupField");
                $A.util.removeClass(lookUpTarget, 'slds-hide');
                $A.util.addClass(lookUpTarget, 'slds-show');
            }
            
            var compEvent = component.getEvent("oSelectedRecordEvent");
            // set the Selected sObject Record to the event attribute.  
            var indexVal = component.get("v.index");
            var ObjName= component.get("v.objectAPIName");
            console.log('indexVal--->'+indexVal);
            if(ObjName == 'Account'){
                compEvent.setParams({"recordByEvent" : selId, "index": indexVal, "objectName": ObjName});  
            }
            else if(ObjName == 'MLS_Association__c'){
                compEvent.setParams({"recordByEventMLS" : ListIds, "index": indexVal, "objectName": ObjName}); 
            }
            else if(ObjName == 'SBQQ__Subscription__c'){
                console.log('Inner recordByEventSub: ' + selId);
                compEvent.setParams({"recordByEventSub" : selId, "index": indexVal, "objectName": ObjName}); 
            }
            console.log('Outer recordByEventSub: ' + selId);
            // fire the event  
            compEvent.fire();
        }
        catch(e){
            alert(e);
        }
        
	},
    ClearPill :function(component,event,heplper){
        
        var pillTarget = component.find("look-pill");
        var indexId = event.currentTarget.dataset.index;
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        var pillListVal = component.get('v.pillList');
        pillListVal.splice(indexId, 1);
        component.set('v.pillList',pillListVal);
        console.log('value pillList--->'+JSON.stringify(component.get("v.pillList")));
        var ListIds = [];
        for (let i = 0; i < pillListVal.length; i++) {
            ListIds.push(pillListVal[i].ID);
        }
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        var indexVal = component.get("v.index");
        var ObjName= component.get("v.objectAPIName");
        console.log('indexVal--->'+indexVal);
        if(ObjName == 'MLS_Association__c'){
            compEvent.setParams({"recordByEventMLS" : ListIds, "index": indexVal, "objectName": ObjName}); 
        }else if(ObjName == 'SBQQ__Subscription__c'){
            compEvent.setParams({"recordByEventSub" : ListIds, "index": indexVal, "objectName": ObjName});
        }
        // fire the event  
        compEvent.fire();
    },
})