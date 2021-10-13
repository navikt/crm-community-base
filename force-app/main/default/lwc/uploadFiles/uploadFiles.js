import { LightningElement, api } from 'lwc';
import uploadFile from '@salesforce/apex/UploadFilesController.uploadFile';
import { setDefaultValue } from 'c/componentHelperClass';
export default class uploadFiles extends LightningElement {
    @api recordId;
    @api mobileStyle;
    @api desktopStyle;

    acceptedFileFormats =
        '[.pdf, .png, .svg, .jpg, .jpeg, .jpe, .jif, .gif, .tif, .tiff, .bmp, .doc, .docx, .doc, .odt, .xls, .xlsx, .ods, .ppt, pptx, .txt, .rtf]';

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }

    get mobileStyleForLabels() {
        return window.screen.width < 576 ? 'display: flex; flex-direction: column; text-align: center' : '';
    }

    isDrop = false;
    dropHandler(event) {
        event.preventDefault();
        this.isDrop = true;
        this.onFileUpload(event);
    }

    dragOverHandler(event) {
        event.preventDefault();
    }

    // Reset value of file input path so that same file can be uploaded again if deleting file and re-uploading
    resetFileValue() {
        this.template.querySelector('[data-id="file-input"]').value = null;
    }

    onFileDelete(event) {
        const index = event.currentTarget.dataset.index;
        if (this.fileData.length < index) {
            return;
        }
        this.fileData.splice(index, 1);
        this.sendFileDataLength();
        this.boolSwitch();
        this.setCheckboxContent();
        this.showOrHideCheckbox();
    }

    showModal() {
        this.template.querySelector('c-alertdialog').showModal();
    }

    focusCheckbox() {
        this.template.querySelector('c-checkbox').focusCheckbox();
    }

    clearCheckboxValue() {
        this.template.querySelector('c-checkbox').clearCheckboxValue();
    }

    setButtonStyleOnFocus() {
        let inputEle = this.template.querySelector('[data-id="file-input"]');
        if (this.template.activeElement === inputEle) {
            document.documentElement.style.setProperty('--outline', 'none');
            document.documentElement.style.setProperty('--boxShadow', '0 0 0 3px #00347d');
        } else {
            document.documentElement.style.setProperty('--outline', 'none');
            document.documentElement.style.setProperty('--boxShadow', 'none');
        }
    }

    checkboxContent;
    setCheckboxContent() {
        this.checkboxContent =
            this.fileData.length > 1
                ? 'Dokumentene som er lagt ved gir bakgrunnsinformasjon om mitt innmeldte behov for tolk. Informasjonen er nødvendig for at behovet skal bli forsvarlig dekket. Jeg er klar over at vedleggene vil bli delt med tolken(e) som blir tildelt oppdraget.'
                : 'Dokumentet som er lagt ved gir bakgrunnsinformasjon om mitt innmeldte behov for tolk. Informasjonen er nødvendig for at behovet skal bli forsvarlig dekket. Jeg er klar over at vedlegget vil bli delt med tolken(e) som blir tildelt oppdraget.';
    }

    showOrHideCheckbox() {
        if (this.fileData.length === 0) {
            this.template.querySelector('.checkboxClass').classList.add('hidden');
            this.clearCheckboxValue();
        } else {
            this.template.querySelector('.checkboxClass').classList.remove('hidden');
            this.focusCheckbox();
        }
    }

    checkboxValue = false;
    handleCheckboxValue(event) {
        this.checkboxValue = event.detail;
        this.getCheckboxValue();
        this.template.querySelector('c-checkbox').validationHandler(''); // Clear validation when clicking checkbox. Only validate on Submit.
    }

    getCheckboxValue() {
        const selectedEvent = new CustomEvent('getcheckboxvalue', {
            detail: this.checkboxValue
        });
        this.dispatchEvent(selectedEvent);
    }

    @api
    validateCheckbox() {
        if (!this.checkboxValue) {
            this.template
                .querySelector('c-checkbox')
                .validationHandler(
                    'For å legge til vedlegg må du gi samtykke til at formidler og tolk kan se vedleggene som lastes opp'
                );
        }
    }

    fileButtonLabel;
    onFileFocus(event) {
        this.fileButtonLabel = '';
        const index = event.currentTarget.dataset.index;
        this.fileButtonLabel = 'Slett vedlegg ' + this.fileData[index].filename;
    }

    // Make boolean value change and set it to true to show new files added
    boolSwitch() {
        this.filesChanged = false;
        this.filesChanged = true;
    }

    filesChanged = false; // If true -> shows new files added in list
    modalContent;
    fileData = [];
    async onFileUpload(event) {
        try {
            const result = this.isDrop
                ? await Promise.all([...event.dataTransfer.files].map((item) => this.readFile(item)))
                : await Promise.all([...event.target.files].map((item) => this.readFile(item)));
            result.forEach((item) => {
                // Only push new files
                if (this.fileData.findIndex((storedItem) => storedItem.base64 === item.base64) === -1) {
                    this.fileData.push(item);
                    this.boolSwitch();
                }
            });
            this.resetFileValue();
            this.setCheckboxContent();
            this.showOrHideCheckbox();
            this.sendFileDataLength();
        } catch (err) {
            this.fileData = [];
            this.modalContent = 'Filen(e) kunne ikke lastes opp. Feilmelding: ' + err;
            this.showModal();
            this.clearFileData();
        }
        this.isDrop = false;
    }

    readFile(file) {
        return new Promise((resolve) => {
            const reader = new FileReader();
            reader.onload = () => {
                resolve({
                    filename: file.name,
                    base64: reader.result.split(',')[1],
                    recordId: this.recordId
                });
            };
            reader.readAsDataURL(file);
        });
    }

    @api
    clearFileData() {
        this.fileData = [];
        this.resetFileValue();
        this.showOrHideCheckbox();
        this.sendFileDataLength();
    }

    sendFileDataLength() {
        const selectedEvent = new CustomEvent('filedatalength', {
            detail: this.fileData.length
        });
        this.dispatchEvent(selectedEvent);
    }

    uploadComplete() {
        this.dispatchEvent(new CustomEvent('uploadcomplete'));
    }

    @api
    handleFileUpload() {
        if (this.fileData.length === 0) {
            return;
        }
        if (this.checkboxValue) {
            const filesToUpload = {};
            this.fileData.forEach((item) => {
                const { base64, filename } = item;
                filesToUpload[base64] = filename;
            });
            uploadFile({ files: filesToUpload, recordId: this.recordId });
            // Consider adding spinner/loader here and also adding then+catch and do logic below in that
            this.uploadComplete();
            this.fileData = [];
            this.sendFileDataLength();
        }
    }
}