import { LightningElement, api, wire,track } from 'lwc';
import getRecordByOppId from '@salesforce/apex/ExtendedOppRecordController.getRecordByOppId';

export default class CustomViewRecordComponentParent extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api fieldSetName;
    @api childRecId;

    opps;
    error;
    connectedCallback() {
    }
    
    @wire(getRecordByOppId, { oppId: '$recordId' })
    wiredOpps({ error, data }) {
        if (data) {
            this.childRecId = data.Id;
            this.error = undefined;
        } else if (error) {
            //this.error = error;
            if(error.body.exceptionType == 'System.QueryException'){// No records found
                this.childRecId = null;
            }
            
            console.error('Error retrieving opportunity:', error);
        }
    }


}