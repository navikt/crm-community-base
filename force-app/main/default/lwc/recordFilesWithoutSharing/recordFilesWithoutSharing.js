import { LightningElement, api, wire } from 'lwc';
import getContentDocuments from '@salesforce/apex/RecordFilesControllerWithoutSharing.getContentDocuments';
import getBaseDownloadUrl from '@salesforce/apex/RecordFilesControllerWithoutSharing.getBaseDownloadUrl';
import { setDefaultValue } from 'c/componentHelperClass';
export default class recordFilesWithoutSharing extends LightningElement {
    @api recordId;
    @api title;
    @api files = [];
    @api isGetAll;
    contentDocuments = [];
    isContentDocumentsEmpty = false;

    get contentDocumentsArray() {
        return this.recordId === undefined ? this.files : this.contentDocuments;
    }

    get defaultTitle() {
        return setDefaultValue(this.title, 'Vedlegg');
    }

    renderedCallback() {
        this.isContentDocumentsEmpty = this.contentDocuments.length === 0 && this.files.length === 0 ? true : false;
    }

    @wire(getContentDocuments, { recordId: '$recordId', isGetAll: '$isGetAll' })
    async wiredgetContentDocuments(result) {
        if (result.data) {
            const url = await getBaseDownloadUrl();
            this.contentDocuments = result.data.map((item) => ({
                ...item,
                downloadLink: url + item.Id
            }));
            this.isContentDocumentsEmpty = this.contentDocuments.length === 0 && this.files.length === 0 ? true : false;
        }
    }
}