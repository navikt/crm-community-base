import { LightningElement, api, wire } from 'lwc';
import getContentDocuments from '@salesforce/apex/RecordFilesController.getContentDocuments';
import getBaseDownloadUrl from '@salesforce/apex/RecordFilesController.getBaseDownloadUrl';
import { setDefaultValue } from 'c/componentHelperClass';

export default class recordFiles extends LightningElement {
    @api recordId;
    @api title;
    @api contentDocuments = [];
    contentDocumentsToShow = [];
    isContentDocumentsEmpty = true;

    get defaultTitle() {
        return setDefaultValue(this.title, 'Vedlegg');
    }

    @wire(getContentDocuments, { recordId: '$recordId' })
    async wiredgetContentDocuments(result) {
        if (result.data) {
            const url = await getBaseDownloadUrl();
            this.contentDocumentsToShow = result.data.map((item) => ({
                ...item,
                downloadLink: url + item.Id
            }));
            this.isContentDocumentsEmpty = this.contentDocumentsToShow.length === 0 ? true : false;
        } else {
            // User sent content documents via argument?
            this.contentDocumentsToShow = this.contentDocuments;
            this.isContentDocumentsEmpty = this.contentDocuments.length === 0 ? true : false;
        }
    }
}
