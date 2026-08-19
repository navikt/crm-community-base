import { LightningElement, api } from "lwc";
import { setDefaultValue } from "c/componentHelperClass";

// Skjermleseren varsles først når brukeren tar en pause, ellers avbrytes
// opplesingen på hvert tastetrykk.
const COUNTER_ANNOUNCE_DELAY = 1000;

export default class Textarea extends LightningElement {
  @api name = "textarea";
  @api label = "";
  @api value;
  @api description;
  @api form;
  @api helptextContent = "";
  @api helptextHovertext;
  @api errorText;
  @api labelSize;
  @api errorSize;
  @api autofocus = false;
  @api disabled = false;
  @api readonly = false;
  @api placeholder = "";
  @api maxLength;
  @api showCounter = false; // opt-in; requires maxLength
  @api softLimit = false;
  @api id = "textareaid";
  @api rows;
  @api cols;
  @api mobileStyle;
  @api desktopStyle;
  @api counterLeftText = "tegn igjen";
  @api counterTooMuchText = "tegn for mye";
  setValue;
  charCount = 0;
  srCounterText = "";
  counterAnnounceTimeout;

  isLabel = false;
  haslabel() {
    this.isLabel = this.label !== "" && this.label !== undefined;
  }

  connectedCallback() {
    this.setValue = this.value;
    this.charCount = this.value ? this.value.length : 0;
    this.srCounterText = this.isCounterVisible ? this.counterText : "";
    this.haslabel();
  }

  disconnectedCallback() {
    clearTimeout(this.counterAnnounceTimeout);
  }

  get descriptionId() {
    return this.description ? `${this.setDefaultId}-description` : "";
  }

  get miscStyle() {
    let toReturn;
    if (this.cols === undefined) {
      toReturn = "width: 100%; ";
    }
    if (this.rows === undefined) {
      toReturn += "height: 114px; ";
    }
    return toReturn;
  }

  get setDefaultId() {
    return setDefaultValue(this.id, "textarea");
  }

  get labelFontSize() {
    return "font-size: " + setDefaultValue(this.labelSize, "1.125rem") + ";";
  }

  get errorFontSize() {
    return (
      "font-size: " +
      setDefaultValue(this.errorSize, "1.125rem") +
      ";" +
      " margin-top: 8px;"
    );
  }

  get isHelpText() {
    return this.helptextContent !== "" && this.helptextContent !== undefined
      ? true
      : false;
  }

  // Call this when value is needed
  @api getValue() {
    return this.template.querySelector("textarea").value;
  }

  @api setTextValue(val) {
    this.template.querySelector("textarea").value = val;
    this.sendValueOnChange();
  }

  showError = false;
  updateShowErrorTextValue() {
    this.showError =
      this.errorText !== undefined &&
      this.errorText !== "" &&
      !this.disabled &&
      (this.template.querySelector("textarea").value === undefined ||
        this.template.querySelector("textarea").value === "" ||
        this.template.querySelector("textarea").value === null);
    if (this.showError) {
      this.template
        .querySelector(".navds-form-field")
        .classList.add("navds-textarea--error");
      this.template.querySelector("textarea").focus();
    } else {
      this.template
        .querySelector(".navds-form-field")
        .classList.remove("navds-textarea--error");
    }
    return this.showError;
  }

  // Sends value on change
  sendValueOnChange() {
    let textareaValue = this.template.querySelector("textarea").value;
    this.charCount = textareaValue ? textareaValue.length : 0;
    this.scheduleCounterAnnouncement();
    const selectedEvent = new CustomEvent("getvalueontextareachange", {
      detail: textareaValue,
    });
    if (this.showError) {
      this.setValue = this.template.querySelector("textarea").value;
      this.updateShowErrorTextValue();
    }
    this.dispatchEvent(selectedEvent);
  }

  @api
  validationHandler() {
    return this.updateShowErrorTextValue();
  }

  get setDefaultStyle() {
    let style = this.desktopStyle;
    if (window.screen.width < 576) {
      style = this.mobileStyle;
    }
    return setDefaultValue(style, "");
  }

  get isCounterVisible() {
    return this.showCounter && Number(this.maxLength) > 0;
  }

  get charsRemaining() {
    return Number(this.maxLength) - this.charCount;
  }

  get counterText() {
    const remaining = this.charsRemaining;
    return remaining < 0
      ? `${Math.abs(remaining)} ${this.counterTooMuchText}`
      : `${remaining} ${this.counterLeftText}`;
  }

  get counterClass() {
    return this.charsRemaining < 0
      ? "navds-textarea__counter navds-body-short navds-textarea__counter--error"
      : "navds-textarea__counter navds-body-short";
  }

  get maxLengthAttribute() {
    return this.softLimit ? undefined : this.maxLength; // soft limit => no hard block
  }

  get counterId() {
    return `${this.setDefaultId}-counter`;
  }

  // Leses opp når feltet får fokus, slik at brukeren kjenner grensen på forhånd.
  get describedByIds() {
    const ids = [
      this.descriptionId,
      this.isCounterVisible ? this.counterId : "",
    ].filter(Boolean);
    return ids.length ? ids.join(" ") : undefined;
  }

  scheduleCounterAnnouncement() {
    if (!this.isCounterVisible) {
      return;
    }
    clearTimeout(this.counterAnnounceTimeout);
    this.counterAnnounceTimeout = setTimeout(() => {
      this.srCounterText = this.counterText;
    }, COUNTER_ANNOUNCE_DELAY);
  }
}
