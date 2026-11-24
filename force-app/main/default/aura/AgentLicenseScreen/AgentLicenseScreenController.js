({
    
    doInit : function(component, event, helper) {
        helper.getPicklistVal(component);
        helper.getAvailableLicense(component);
        helper.getTotalLicense(component);
        var sobjectListval = component.get("v.SObjectList");
        console.log('sobjectListval after return-->'+JSON.stringify(sobjectListval));
    },
	handleComponentEvent : function(component, event, helper) {
        try{
            console.log('Event: ' + JSON.stringify(event));
            var selectedAccountGetFromEvent = event.getParam("recordByEvent");
            var selectedMLSGetFromEvent = event.getParam("recordByEventMLS");
            var selectedSubGetFromEvent = event.getParam("recordByEventSub");
            var selectedProductFromEvent = event.getParam("productVal");
            var selectedNumberValGetFromEvent = event.getParam("numberVal");
            var selectedSharedtype = event.getParam("SelectedType");
            var indexVal = event.getParam("index");
            var accDetails = event.getParam("AccountDetailsEve");
            var sobjectListval = component.get("v.SObjectList");
            var sObjectRecord = sobjectListval[indexVal];
            if(selectedAccountGetFromEvent != undefined)
                sObjectRecord.AccountVal = selectedAccountGetFromEvent;
            if(selectedProductFromEvent != undefined)
                sObjectRecord.Product = selectedProductFromEvent;
            if(selectedNumberValGetFromEvent != undefined)
                sObjectRecord.Numb = selectedNumberValGetFromEvent;
            if(selectedMLSGetFromEvent != undefined){
                 console.log('sObjectRecord.MLS 1-->'+sObjectRecord.MLS );
                sObjectRecord.MLS = selectedMLSGetFromEvent;
                console.log('sObjectRecord.MLS 2-->'+sObjectRecord.MLS );
            }
            console.log('selectedSubGetFromEvent: ' + selectedSubGetFromEvent);
            if(selectedSubGetFromEvent != undefined){
                sObjectRecord.subId = selectedSubGetFromEvent;
            }
            if(selectedSharedtype != undefined)
                sObjectRecord.SharedType = selectedSharedtype;
            console.log('sObjectRecord'+JSON.stringify(sObjectRecord));
            if(accDetails != undefined)
                component.set("v.AccountDetails",accDetails);
            sObjectRecord.exist = false;
            sobjectListval[indexVal] = sObjectRecord;
            component.set('v.SObjectList',sobjectListval);
            
            if(selectedProductFromEvent == 'Five Street' || selectedProductFromEvent == 'Top Producer Website' || selectedProductFromEvent == 'HouseValues'){
                sObjectRecord.MLS=[];
            }
            
            if(sObjectRecord.AccountVal !='' && sObjectRecord.Product !=''){
                component.set("v.curIndex",indexVal);
                helper.AccountProductMap(component);
            }
            console.log('sobjectListval after return-->'+JSON.stringify(sobjectListval));
            component.set('v.valueChanged',false);
        }
        catch(e){
            alert(e);
        }
	},
    insertUserEntitlements : function(component, event, helper) {
         var recordId = component.get('v.recordId');
        var sobjectListval = component.get("v.SObjectList");
        var sobjectListvalStr = JSON.stringify(sobjectListval);
        var accountsDetails = component.get('v.AccountDetails');
        console.log('sobjectListvalStr value beofre insert---> '+sobjectListvalStr);
        console.log('accDetails value beofre insert---> '+JSON.stringify(accountsDetails));
        var action = component.get("c.insertUserEntitlementsController");
        action.setParams({
            recId : recordId,
            userEntStr : sobjectListvalStr,
            accountDetails : JSON.stringify(accountsDetails),
            Fiveet : accountsDetails.Fivestreet
            
        });
        action.setCallback(this, function(response) {
            var state = response.getReturnValue();
            if (state === 'true') {
                console.log('true');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'License Assigned Successfully',
                    type: 'success',
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if(state === 'false'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'License Assignment failed 2 ' + response.getError() + response.getReturnValue(),
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
    addRows : function(component, event, helper) {
        var eve = event.getSource().get("v.value");
        console.log('eve-->'+eve);
        var sobjectListval = component.get("v.SObjectList");
        var emptyRec = {'AccountVal':'','Product':'','Numb':''};
        //sobjectListval.push(emptyRec);
        sobjectListval.splice(eve+1, 0, emptyRec);
        component.set('v.SObjectList',sobjectListval);
        console.log('sobjectListval-->'+JSON.stringify(sobjectListval));
        
    },
    delRows : function(component, event, helper) {
        var eve = event.getSource().get("v.value");
        console.log('eve-->'+eve);
        var sobjectListval = component.get("v.SObjectList");
        var valAtIndex = sobjectListval[eve];
        var accDetailList = component.get("v.AccountDetails");
        console.log('sobjectListval-->'+JSON.stringify(sobjectListval));
        console.log('AccountDetails-->'+JSON.stringify(accDetailList));
        if(valAtIndex.Product == "Five street")
            accDetailList.Fivestreet = parseInt(accDetailList.Fivestreet) + parseInt(valAtIndex.Numb);
        if(valAtIndex.Product == "Market Snapshot")
            accDetailList.MarketSnapshot = parseInt(accDetailList.MarketSnapshot) + parseInt(valAtIndex.Numb);
        if(valAtIndex.Product == "Top Producer Assistant License")
            accDetailList.TopProducerAssistantLicense = parseInt(accDetailList.TopProducerAssistantLicense) + parseInt(valAtIndex.Numb);
        if(valAtIndex.Product == "HomeIntelle Hub")
            accDetailList.HomeIntelleHub = parseInt(accDetailList.HomeIntelleHub) + parseInt(valAtIndex.Numb);
        if(valAtIndex.Product == "Top Producer CRM"){
            console.log('parseInt(accDetailList.TopProducerCRM)----->>>'+parseInt(accDetailList.TopProducerCRM));
            console.log(' parseInt(valAtIndex.Numb)----->>>'+ parseInt(valAtIndex.Numb));
            accDetailList.TopProducerCRM = parseInt(accDetailList.TopProducerCRM) + parseInt(valAtIndex.Numb);
  
        }
        if(valAtIndex.Product == "Top Producer Website")
            accDetailList.TopProducerWebsites = parseInt(accDetailList.TopProducerWebsites) + parseInt(valAtIndex.Numb);
        component.set('v.AccountDetails',accDetailList);
        //sobjectListval.push(emptyRec);
        sobjectListval.splice(eve, 1);
        component.set('v.SObjectList',sobjectListval);
        console.log('sobjectListval-->'+JSON.stringify(sobjectListval));
        
    },
    updateNumberValue : function(component, event, helper) {
        var selectedProductFromEvent = event.currentTarget.value;
        var indexVal = event.currentTarget.dataset.index;
        console.log('index--->'+selectedProductFromEvent);
        var sobjectListval = component.get("v.SObjectList");
        var sObjectRecord = sobjectListval[indexVal];
        sObjectRecord.Numb = selectedProductFromEvent;
        sobjectListval[indexVal] = sObjectRecord;
        component.set('v.SObjectList',sobjectListval);
        console.log('sobjectListval after change-->'+JSON.stringify(sobjectListval));
    },
    addAnotherRecord : function(component, event, helper) {
         component.set("v.showModal",true);
    },
    closeModal: function(component, event, helper) {
        component.set("v.showModal",false);
        component.set("v.recordTypeModal",false);

    },
    proceed: function(component, event, helper) {
        try {
            var recordtypeId=component.get('v.recordTypeId');
            
            
            console.log('recordtypeId----> '+recordtypeId);
            component.set("v.showModal",false);
            console.log("We are in addinsurance_helper ");
            var recordEvent = $A.get("event.force:createRecord");
            recordEvent.setParams({
                "entityApiName": "Account",
                "recordTypeId": recordtypeId
            });
            recordEvent.fire();            
        }
        catch (err) {
            console.error('Java script error', err.message);
        }
    },
    fetchRecordType: function(component, event, helper) {
        var action = component.get("c.fetchRecordTypeId");
            action.setParams({
                recordName : component.get("v.recordTypeSelected")
            });
            action.setCallback(this, function(response) {
                component.set('v.recordTypeId',response.getReturnValue());
                console.log('response---> '+response.getReturnValue());
            });
            $A.enqueueAction(action);
        
    },
    isRefreshed: function(component, event, helper) {
        console.log('reload');
        location.reload();
    },
    openChangeRecordTypeModal:function(component, event, helper){
        component.set("v.recordTypeModal",true);

    },
    convertRecordType:function(component, event, helper){
        try{
            component.set("v.showModal",false);
            component.set("v.recordTypeModal",false);
            if(component.get('v.seletedChangeRecordType') =='Team'){
                component.set('v.seletedChangeRecordType','');
                var curIndx = event.currentTarget.dataset.ind;
                var sObjectLst = component.get("v.SObjectList");
                var cursObject = sObjectLst[curIndx];
                var accountId = cursObject.AccountVal;
                console.log('accountId--->'+accountId);
                var action = component.get("c.changeRecordTypeController");
                action.setParams({
                    accId : accountId
                });
                action.setCallback(this,function(response)
                                   {
                                       var changed = response.getReturnValue();
                                       if(changed){
                                           cursObject.exist = false;
                                           sObjectLst[curIndx] = cursObject;
                                           component.set("v.SObjectList",sObjectLst);
                                           var toastEvent = $A.get("e.force:showToast");
                                           toastEvent.setParams({
                                               title : 'Success',
                                               message: 'Record Type Changed From Agent To Team Sucessfully !!',
                                               type: 'success',
                                           });
                                           toastEvent.fire();
                                       }else{
                                           var toastEvent = $A.get("e.force:showToast");
                                           toastEvent.setParams({
                                               title : 'Error',
                                               message:'RecordType Change Prcess Failed !!',
                                               type: 'error',
                                           });
                                           toastEvent.fire();
                                       }
                                       
                                   });
                $A.enqueueAction(action);   
            }
        }
        catch (err) {
            console.error('Java script error', err.message);
        }
    },
})