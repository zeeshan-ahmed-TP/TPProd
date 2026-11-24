({
	getPicklistVal: function(component){
        var recordId = component.get('v.recordId');
        console.log('values recordId::>'+recordId);
        var action = component.get("c.getPicklistValue");
        action.setParams({
            recordID : recordId
        });
        action.setCallback(this,function(response)
                           {
                               var state = response.getState();
                               if(state === "SUCCESS") {
                                   component.set("v.picklistvalue", response.getReturnValue());
                                   console.log('response.getReturnValue()'+response.getReturnValue());
                               }
                           });
        $A.enqueueAction(action);                  
    },
    AccountProductMap: function(component, event, helper){
        
        console.log('index-->helper='+component.get("v.index"));
        var ind = component.get("v.curIndex");
        var sObjList = component.get("v.SObjectList");
        var cursObject = sObjList[ind];
        var objectdetails=JSON.stringify(sObjList[ind]);
        var action= component.get("c.checkExistingENTError");
        action.setParams({
            objectRecord:objectdetails
            
        });
        action.setCallback(this,function(response)
                           {	
                               console.log('exist or not--->'+response.getReturnValue());
                               var isexist = response.getReturnValue();
                               if(isexist == true){
                                   cursObject.exist = true;
                                   sObjList[ind] = cursObject;
                                   component.set("v.SObjectList",sObjList);
                               }
                               else{
                                   cursObject.exist = false;
                                   sObjList[ind] = cursObject;
                                   component.set("v.SObjectList",sObjList);
                               }
                           });
        $A.enqueueAction(action); 
            
    },
    getTotalLicense: function(component, event, helper){
        var recordId = component.get('v.recordId');
        var action = component.get("c.getTotalLicenseDetails");
        action.setParams({
            recId : recordId
        });
        action.setCallback(this,function(response)
                           {
                               var state = response.getState();
                               if(response.getReturnValue()){
                                   console.log('response.getReturnValue()',response.getReturnValue());
                                   component.set('v.AccountDetailsFinal',JSON.parse(response.getReturnValue()));
                                   console.log('response.getReturnValue()'+JSON.stringify(component.get('v.AccountDetails')));
                                   console.log('response.getReturnValue()'+JSON.stringify(component.get('v.AccountDetailsFinal')));

                               }
                               
                           });
        $A.enqueueAction(action);                  
    },
    
    getAvailableLicense: function(component, event, helper){
        var recordId = component.get('v.recordId');
        var action = component.get("c.getAvailableLicenseDetails");
        action.setParams({
            recId : recordId
        });
        action.setCallback(this,function(response)
                           {
                               var state = response.getState();
                               if(response.getReturnValue()){
                                   console.log('response.getReturnValue()',response.getReturnValue());
                                   component.set('v.AccountDetails',JSON.parse(response.getReturnValue()));
                                   console.log('response.getReturnValue()'+JSON.stringify(component.get('v.AccountDetails')));
                                   console.log('response.getReturnValue()'+JSON.stringify(component.get('v.AccountDetailsFinal')));

                               }
                               
                           });
        $A.enqueueAction(action);                  
    },
    helper_insertUserEntitlements: function(component, event, helper){
        var recordId = component.get('v.recordId');
        var sobjectListval = component.get("v.SObjectList");
        var sobjectListvalStr = JSON.stringify(sobjectListval);
        var accountsDetails = component.get('v.AccountDetails');
        console.log('sobjectListvalStr value beofre insert---> '+sobjectListvalStr);
        console.log('accDetails value beofre insert---> '+JSON.stringify(accountsDetails));
        var action = component.get("c.insertUserEntitlementsController");
        action.setParams({
            recId : recordId,
            userEntStr : sobjectListvalStr
        });
        action.setCallback(this, function(response) {
            var state = response.getReturnValue();
           alert('value---->'+response.getReturnValue());
            if (state === undefined) {
                console.log('true');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'License Assigned Successfully',
                    type: 'success',
                });
                toastEvent.fire();
            }
            else if(state === 'false'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'License Assignment failed',
                    type: 'error',
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: state,
                    type: 'error',
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})