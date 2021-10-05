import { LightningElement, api, wire } from 'lwc';
import getContentDocuments from '@salesforce/apex/RecordFilesController.getContentDocuments';
import getBaseDownloadUrl from '@salesforce/apex/RecordFilesController.getBaseDownloadUrl';
import { setDefaultValue } from 'c/componentHelperClass';
export default class recordFiles extends LightningElement {
    @api recordId;
    @api title;
    @api files = [];
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

    @wire(getContentDocuments, { recordId: '$recordId' })
    async wiredgetContentDocuments(result) {
        if (result.data) {
            const url = await createBaseUrlLink();
            this.contentDocuments = result.data.map((item) => ({
                ...item,
                downloadLink: url + item.Id
            }));
            this.isContentDocumentsEmpty = this.contentDocuments.length === 0 && this.files.length === 0 ? true : false;
        }
    }
}
