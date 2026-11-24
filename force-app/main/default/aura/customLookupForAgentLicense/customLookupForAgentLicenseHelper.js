({
    searchHelper : function(component,event,getInputkeyWord) {
        try{
            // call the apex class method 
            var sObjList = component.get('v.accId');
            var indx = component.get('v.index');
            var stateValue = component.get('v.stateVal');
            var subId = component.get('v.subId');
            console.log('<--val of State--> '+stateValue);
            //var curSobject =sObjList[indx];
            var action = component.get("c.fetchLookUpValues");
           // console.log('valuews before searching sObjList--> '+JSON.stringify(sObjList));
           /// console.log('valuews before searching indx--> '+indx);
//console.log('valuews before searching curSobject--> '+JSON.stringify(curSobject));
            //console.log('valuews before searching--> '+JSON.stringify(curSobject));
            // set param to method  
            action.setParams({
                'stateVal': stateValue,
                'currentObj': sObjList,
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : component.get("v.objectAPIName"),
                'CurrentRecordId' : component.get("v.recordFromParentId")
            });
            // set a callBack    
            action.setCallback(this, function(response) {
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    // set searchResult list with return value from server.
                    component.set("v.listOfSearchRecords", storeResponse);
                   // console.log("list-->"+component.get("v.listOfSearchRecords"));
                }
                
            });
            // enqueue the Action  
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e);
        }
        
    },
})