({
	doInit : function(component, event, helper) {
        var transactionParams = {};
        component.set("v.SaveForFuture", "true");
        transactionParams.accountId = component.get("v.recordId");
        transactionParams.gatewayId = component.get("v.gatewayId");
        transactionParams.amount = component.get("v.amount");
        console.log('Account Id: ' + component.get("v.recordId"));
        component.set("v.transactionParams", transactionParams);
    },

    handleTransactionResponse : function(cmp, event, helper) {
        var response = event.getParam("response");
        console.log('response: ' + JSON.stringify(response));
        if(response.isSuccess) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type" : 'success',
                "message": "Payment method is added successfully."
            });
            toastEvent.fire();
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failure!",
                "type" : 'error',
                "message": "Operation Failed. Please try again!"
            });
            toastEvent.fire();
        }
        $A.get("e.force:closeQuickAction").fire();
    }
})