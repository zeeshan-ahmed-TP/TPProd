({
	gotoRelatedList : function (component, event, helper) {
  var relatedListEvent = $A.get("e.force:navigateToRelatedList");
  relatedListEvent.setParams({
      "relatedListId": component.get("v.RelatedList"),
      "parentRecordId": component.get("v.recordId")
  });
  relatedListEvent.fire();
}
})