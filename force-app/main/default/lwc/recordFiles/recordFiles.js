import { LightningElement, api, wire } from 'lwc';
import getContentDocuments from '@salesforce/apex/HOT_RelatedFilesListController.getContentDocuments';
import getBaseDownloadUrl from '@salesforce/apex/HOT_RelatedFilesListController.getBaseDownloadUrl';
import { setDefaultValue } from 'c/componentHelperClass';

export default class recordFiles extends LightningElement {
    @api recordId;
    @api title;

    contentDocuments = [];
    isContentDocumentsEmpty = true;

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
            this.isContentDocumentsEmpty = this.contentDocuments.length === 0 ? true : false;
        } else {
            this.isContentDocumentsEmpty = true;
        }
    }
}
