import { LightningElement, api, wire } from 'lwc';
import getContentDocuments from '@salesforce/apex/RecordFilesController.getContentDocuments';
import getBaseDownloadUrl from '@salesforce/apex/RecordFilesController.getBaseDownloadUrl';
import { setDefaultValue } from 'c/componentHelperClass';
export default class hot_recordFiles extends LightningElement {
    @api recordId;
    @api title;
    @api files = [];
    isContentDocumentsEmpty = false;
    contentDocuments = [];

    get contentDocumentsArray() {
        this.isContentDocumentsEmpty = this.contentDocuments.length === 0 && this.recordId !== undefined ? true : false;
        return this.recordId === undefined ? this.files : this.contentDocuments;
    }

    get defaultTitle() {
        return setDefaultValue(this.title, 'Vedlegg');
    }

    @wire(getContentDocuments, { recordId: '$recordId' })
    async wiredgetContentDocuments(result) {
        if (result.data) {
            const url = await getBaseDownloadUrl();
            this.contentDocuments = result.data.map((item) => ({
                ...item,
                downloadLink: url + item.Id
            }));
            this.isContentDocumentsEmpty =
                this.contentDocuments.length === 0 && this.recordId !== undefined ? true : false;
        }
    }
}
