import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class GenerateReceipt extends NavigationMixin(LightningElement) {
    _recordId;
    hasNavigated = false;

    @api
    set recordId(value) {
        this._recordId = value;

        if (value && !this.hasNavigated) {
            this.hasNavigated = true;
            this.openInNewTab();
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get recordId() {
        return this._recordId;
    }

    openInNewTab() {

        const baseUrl = window.location.origin; 
        const vfUrl = `${baseUrl}/apex/GenerateReceiptVF?id=${this.recordId}`;

        const win = window.open(vfUrl, '_blank', 'noopener,noreferrer');

    }
}