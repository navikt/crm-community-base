import { LightningElement, api, wire, track } from 'lwc';
import getContentDocuments from '@salesforce/apex/RecordFilesControllerWithSharing.getContentDocuments';
import getBaseDownloadUrl from '@salesforce/apex/RecordFilesControllerWithSharing.getBaseDownloadUrl';
import deleteFilesOnRecord from '@salesforce/apex/RecordFilesControllerWithSharing.deleteFilesOnRecord';
import getOnlyMyContentDocuments from '@salesforce/apex/RecordFilesControllerWithSharing.getOnlyMyContentDocuments';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';
import { refreshApex } from '@salesforce/apex';
export default class recordFilesWithSharing extends LightningElement {
    @api recordId;
    @api title;
    @api files = [];
    @api isGetAll = false;
    @api isDeleteOption = false;
    @api deleteFileOnButtonClick = false;
    contentDocuments = [];
    myContentDocuments = [];
    isContentDocumentsEmpty = false;
    @track filesToShow = [];

    get contentDocumentsArray() {
        return this.recordId === undefined ? this.files : this.contentDocuments;
    }

    get defaultTitle() {
        return setDefaultValue(this.title, 'Vedlegg');
    }

    get isDelete() {
        return convertStringToBoolean(this.isDeleteOption);
    }

    renderedCallback() {
        this.hasFiles();
    }

    hasFiles() {
        this.isContentDocumentsEmpty = this.contentDocuments.length === 0 && this.files.length === 0 ? true : false;
    }

    fileButtonLabel;
    onFileFocus(event) {
        this.fileButtonLabel = '';
        const index = event.currentTarget.dataset.index;
        this.fileButtonLabel = 'Slett vedlegg ' + this.filesToShow[index].Title;
    }

    markFilesAvailableForDeletion() {
        this.filesToShow = [...this.contentDocumentsArray]; // Copy value to be able to set new attribute
        this.filesToShowLength = this.filesToShow.length > 0;
        this.filesToShow.forEach((item) => {
            this.myContentDocuments.forEach((myItem) => {
                if (item.Id === myItem) {
                    item.isDeletable = true;
                }
            });
        });
    }

    // Call this when submit/save is run to delete selected files
    // Should probably force a refresh when file is deleted so that the new list of files is shown
    @api deleteMarkedFiles() {
        if (this.filesToDelete.length > 0) {
            deleteFilesOnRecord({ files: this.filesToDelete });
        }
    }

    filesToDelete = [];
    filesToShowLength = false;
    onFileDelete(event) {
        const index = event.currentTarget.dataset.index;
        if (this.filesToShow.length < index) {
            return;
        }
        this.filesToDelete.push(this.filesToShow[index].Id);
        this.filesToShow.splice(index, 1);
        this.filesToShowLength = this.filesToShow.length > 0;
        if (this.deleteFileOnButtonClick) {
            this.deleteMarkedFiles();
        }
    }

    wiredGetContentDocumentsResult;
    @wire(getContentDocuments, { recordId: '$recordId', isGetAll: '$isGetAll' })
    async wiredgetContentDocuments(result) {
        this.wiredGetContentDocumentsResult = result;
        if (result.data) {
            const url = await getBaseDownloadUrl();
            this.contentDocuments = result.data.map((item) => ({
                ...item,
                downloadLink: url + item.Id
            }));
            this.hasFiles();
            let contentDocumentIds = [];
            this.contentDocuments.forEach((item) => {
                contentDocumentIds.push(item.Id);
            });
            getOnlyMyContentDocuments({ contentDocumentIds: contentDocumentIds }).then((res) => {
                this.myContentDocuments = res;
                this.markFilesAvailableForDeletion();
            });
        }
    }
    @api refreshContentDocuments() {
        refreshApex(this.wiredGetContentDocumentsResult);
    }
}
