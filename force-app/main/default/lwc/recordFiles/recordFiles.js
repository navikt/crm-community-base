import { LightningElement, api, wire } from 'lwc';
import getContentDocuments from '@salesforce/apex/RecordFilesController.getContentDocuments';
import getBaseDownloadUrl from '@salesforce/apex/RecordFilesController.getBaseDownloadUrl';
import { setDefaultValue } from 'c/componentHelperClass';

export default class recordFiles extends LightningElement {
    @api contentDocuments = [];
    @api title;

    get defaultTitle() {
        return setDefaultValue(this.title, 'Vedlegg');
    }

    isContentDocumentsEmpty = true;
    renderedCallback() {
        this.isContentDocumentsEmpty = this.contentDocuments.length === 0 ? true : false;
    }
}
