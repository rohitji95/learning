import { LightningElement, api, wire,track } from 'lwc';
//import getFieldSetFields from '@salesforce/apex/CustomViewRecordController.getFieldSetFields';
//import saveRecord from '@salesforce/apex/CustomViewRecordController.saveRecord';
//import OPP_FIELD from '@salesforce/schema/Child_Opportunity__c.Opportunity__c';


export default class CustomViewRecordComponent extends LightningElement {
    
    @api recordId;
    //@api objectApiNameUi='Child_Opportunity__c';
    //@api fieldSetName;
    @api oppId;
   // @api childRecId;

    //@track fieldList = [];
    //@track formData = {};
    //error;
    //loading = true;


    /*connectedCallback() {
        console.log('fetching field set  with oppId *******'+this.oppId);
        console.log('record id..',this.recordId);
        this.hasRecordId = false;
        if(this.recordId){
            this.hasRecordId = true;
        }
        //console.log(this.objectApiNameUi);
        // console.log(this.fieldSetName);
        if(!this.recordId){
            this.loadFieldSet();
        }


        //this.defaultValues  = {
        //    [OPP_FIELD.fieldApiName]: this.oppId
        //};
    }*/

    /*loadFieldSet() {
        getFieldSetFields({
            objectName: this.objectApiNameUi,
            fieldSetName: this.fieldSetName
        })
        .then((result) => {
            this.fieldList = result;
            this.loading = false;

            console.log(result);
        })
        .catch((error) => {
            this.error = error;
            this.loading = false;
        });
    }*/

    /*handleChange(event) {
        const { name, value } = event.target;
        this.formData[name] = value;
    }*/

    handleSubmit(event) {
        
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Opportunity__c = this.oppId; // modify a field
        this.template.querySelector('lightning-record-form').submit(fields);

    }
    handleSuccess(event) {
        const evt = new CustomEvent('formsubmit', {
        detail: event.detail.id
        });
        this.dispatchEvent(evt);
    }


    /*handleError(event) {
        console.error('Error saving record', event.detail);
    }*/

}