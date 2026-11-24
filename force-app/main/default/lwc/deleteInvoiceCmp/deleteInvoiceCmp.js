import { LightningElement, api, wire } from 'lwc';
import deleteInvoice from '@salesforce/apex/BillingTriggersController.deleteInvoice';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from "lightning/navigation";

export default class DeleteInvoiceCmp extends NavigationMixin(LightningElement) {
@api recordId;

handeBtnClick(){

	deleteInvoice({recordId: this.recordId})
	.then((result) => {
		this.result = result;
		console.log('Result: ' + result);
		if(result === 'Successfull'){
			const evt = new ShowToastEvent({
				title: 'Success',
				message: 'Invoice is successfully Deleted',
				variant: 'success',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
			navigateToInvoiceHome();
		}else{
			const evt = new ShowToastEvent({
				title: 'Error',
				message: result,
				variant: 'error',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}
		this.dispatchEvent(new CloseActionScreenEvent());
	})
	.catch((error) => {
		this.error = error;
			console.log('Error: ' + JSON.stringify(error));
			this.dispatchEvent(new CloseActionScreenEvent());
	});
}

closeAction() {
	this.dispatchEvent(new CloseActionScreenEvent());
}

navigateToInvoiceHome() {
    // Navigate to the Case object home page.
	console.log('Method Called');
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "blng__Invoice__c",
        actionName: "list",
      },
	  state: {
        // 'filterName' is a property on the page 'state'
        // and identifies the target list view.
        // It may also be an 18 character list view id.
        filterName: "Recent", // or by 18 char '00BT0000002TONQMA4'
      },
    });
  }
}