({
    returnValue : function(component, event, helper) {
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        var indexVal = component.get("v.index");
        var productSel = component.get("v.selectedValue");
        var numbVal = component.get("v.numberValue");
        
        console.log('indexVal--->'+indexVal);
        compEvent.setParams({
            "recordByEvent" : undefined,
            "index": indexVal,
            "productVal": productSel,
            "numberVal": numbVal
        });  
        // fire the event  
        compEvent.fire();
    },
    checkLimit : function(component, event, helper) {
        try {
            
            var priorNumbVal = component.get('v.PrevNumberValue');
            var priorPordVal = component.get('v.PrevSelectedValue');
            if(priorNumbVal != undefined && priorNumbVal != -1 ){
                var accDetailsVal = component.get("v.AccountDetails");
                console.log('previous Update priorNumbVal--->'+priorNumbVal);
                console.log('previous Update '+ JSON.stringify(accDetailsVal));
                if(priorPordVal == 'FiveStreet'){
                    var numbV = parseInt(accDetailsVal.Fivestreet) + parseInt(priorNumbVal);
                    if(!Number.isNaN(numbV))
                        accDetailsVal.Fivestreet = numbV;
                }if(priorPordVal == 'MarketSnapshot'){
                    var numbV = parseInt(accDetailsVal.MarketSnapshot) + parseInt(priorNumbVal);
                    if(!Number.isNaN(numbV))
                        accDetailsVal.MarketSnapshot = numbV;
                }if(priorPordVal == 'TopProducerAssistantLicense'){
                    var numbV = parseInt(accDetailsVal.TopProducerAssistantLicense) + parseInt(priorNumbVal);
                    if(!Number.isNaN(numbV))
                        accDetailsVal.TopProducerAssistantLicense = numbV;
                }if(priorPordVal == 'TopProducerCRM'){
                    var numbV = parseInt(accDetailsVal.TopProducerCRM) + parseInt(priorNumbVal);
                    if(!Number.isNaN(numbV))
                        accDetailsVal.TopProducerCRM = numbV;
                }if(priorPordVal == 'TopProducerWebsite'){
                    var numbV = parseInt(accDetailsVal.TopProducerWebsites) + parseInt(priorNumbVal);
                    if(!Number.isNaN(numbV))
                        accDetailsVal.TopProducerWebsites = numbV;
                }
                var selectedSharedVal = component.get('v.SharedOrNot');
                accDetailsVal.SharedType = selectedSharedVal;
                component.set('v.AccountDetails',accDetailsVal);
                component.set('v.PrevNumberValue',-1);
            }
            var compEvent = component.getEvent("oSelectedRecordEvent");
            // set the Selected sObject Record to the event attribute.  
            var indexVal = component.get("v.index");
            var productSel = component.get("v.selectedValue");
            var numbVal = component.get("v.numberValue");
            var valSelected = productSel.replace(/\s/g, '');
            var selectedSharedVal1 = component.get('v.SharedOrNot');
            var accDetails = component.get("v.AccountDetails");
            var accDet = accDetails;
            console.log('--->value'+ JSON.stringify(accDetails));
            var exceeded = 0;
            if(valSelected == 'FiveStreet'){
                exceeded = accDetails.Fivestreet - numbVal;
                if(exceeded >= 0){
                    accDet.Fivestreet = exceeded;
                }
            }
            if(valSelected == 'MarketSnapshot'){
                exceeded = accDetails.MarketSnapshot - numbVal;
                if(exceeded >= 0){
                    accDet.MarketSnapshot = exceeded;
                }
               
            }if(valSelected == 'TopProducerAssistantLicense'){
                exceeded = accDetails.TopProducerAssistantLicense - numbVal;
                if(exceeded >= 0){
                    accDet.TopProducerAssistantLicense = exceeded;
                }
                
            }if(valSelected == 'TopProducerCRM'){
                exceeded = accDetails.TopProducerCRM - numbVal;
                if(exceeded >= 0){
                    accDet.TopProducerCRM = exceeded;
                }
              
            }if(valSelected == 'TopProducerWebsite'){
                exceeded = accDetails.TopProducerWebsites - numbVal;
                if(exceeded >= 0){
                    accDet.TopProducerWebsites = exceeded;
                }
            }
            var nameField = component.find("expname");//.get("v.value");
            if(exceeded < 0){
                component.set('v.Labels','Limit Exceeded!!!');
                $A.util.addClass(nameField, "error");
                if(productSel != undefined){
                    component.set('v.PrevNumberValue',numbVal);
                    component.set('v.PrevSelectedValue',valSelected);
                    component.set('v.AccountDetails',accDet);
                    console.log('indexVal- 213-->'+valSelected);
                    compEvent.setParams({
                        "recordByEvent" : undefined,
                        "index": indexVal,
                        "productVal": productSel,
                        "numberVal": 0,
                        "SelectedType":selectedSharedVal1,
                        "AccountDetailsEve" : component.get('v.AccountDetails')
                    });  
                    // fire the event  
                    compEvent.fire();
                }
            }
            else{
                component.set('v.Labels','No Of License:');
                $A.util.removeClass(nameField, "error");
                if(productSel != undefined && (numbVal != undefined || numbVal!= '' )){
                    component.set('v.PrevNumberValue',numbVal);
                    component.set('v.PrevSelectedValue',valSelected);
                    component.set('v.AccountDetails',accDet);
                    console.log('indexVal- 213-->'+valSelected);
                    compEvent.setParams({
                        "recordByEvent" : undefined,
                        "index": indexVal,
                        "productVal": productSel,
                        "numberVal": numbVal,
                        "SelectedType":selectedSharedVal1,
                        "AccountDetailsEve" : component.get('v.AccountDetails')
                    });  
                    // fire the event  
                    compEvent.fire();
                }
            }
            
            
            if(exceeded == -1){
                
            } 
            
            
        }
        catch (err) {
            console.error('Java script error', err.message);
        }
    },
    sendValue:  function(component, event, helper) {
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        var indexVal = component.get("v.index");
        var productSel = component.get("v.selectedValue");
        var numbVal = component.get("v.numberValue");
        var valSelected = productSel.replace(/\s/g, '');
        var selectedSharedVal1 = component.get('v.SharedOrNot');
        var accDetails = component.get("v.AccountDetails");
        var accDet = accDetails;
        console.log('--->value'+ JSON.stringify(accDetails));
        var exceeded = 0;
        if(valSelected == 'FiveStreet'){
            exceeded = accDetails.Fivestreet - numbVal;
            if(exceeded >= 0){
                accDet.Fivestreet = exceeded;
            }
        }
        if(valSelected == 'MarketSnapshot'){
            exceeded = accDetails.MarketSnapshot - numbVal;
            if(exceeded >= 0){
                accDet.MarketSnapshot = exceeded;
            }
            
        }if(valSelected == 'TopProducerAssistantLicense'){
            exceeded = accDetails.TopProducerAssistantLicense - numbVal;
            if(exceeded >= 0){
                accDet.TopProducerAssistantLicense = exceeded;
            }
            
        }if(valSelected == 'TopProducerCRM'){
            exceeded = accDetails.TopProducerCRM - numbVal;
            if(exceeded >= 0){
                accDet.TopProducerCRM = exceeded;
            }
            
        }if(valSelected == 'TopProducerWebsite'){
            exceeded = accDetails.TopProducerWebsites - numbVal;
            if(exceeded >= 0){
                accDet.TopProducerWebsites = exceeded;
            }
        }
        var nameField = component.find("expname");//.get("v.value");
        if(exceeded < 0){
            component.set('v.Labels','Limit Exceeded!!!');
            $A.util.addClass(nameField, "error");
        }
        else{
            component.set('v.Labels','No Of License:');
            $A.util.removeClass(nameField, "error");
            if(productSel != undefined && (numbVal != undefined || numbVal!= '' )){
                component.set('v.PrevNumberValue',numbVal);
                component.set('v.PrevSelectedValue',valSelected);
                component.set('v.AccountDetails',accDet);
                console.log('indexVal- 213-->'+valSelected);
                compEvent.setParams({
                    "recordByEvent" : undefined,
                    "index": indexVal,
                    "productVal": productSel,
                    "numberVal": numbVal,
                    "SelectedType":selectedSharedVal1,
                    "AccountDetailsEve" : component.get('v.AccountDetails')
                });  
                // fire the event  
                compEvent.fire();
            }
        }
    },
})