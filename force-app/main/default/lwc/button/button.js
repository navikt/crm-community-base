import { LightningElement, api } from "lwc";
import {
  setDefaultValue,
  convertStringToBoolean,
} from "c/componentHelperClass";

// https://navikt.github.io/Designsystemet/?path=/story/ds-react-button--all
export default class Button extends LightningElement {
  @api id;
  @api name;
  @api autofocus;
  @api disabled;
  @api type; // Button, Submit, Reset
  @api value;
  @api title;
  @api buttonStyling; // Primary, Secondary, Tertiary, Danger
  @api buttonLabel;
  @api ariaLabel;
  @api desktopStyle;
  @api mobileStyle;
  @api isLoading; // "true" | "false"

  get buttonClass() {
    let buttonStyle = this.buttonStyling
      ? this.buttonStyling.toLowerCase()
      : "primary";

    if (
      buttonStyle !== "primary" &&
      buttonStyle !== "secondary" &&
      buttonStyle !== "tertiary" &&
      buttonStyle !== "danger"
    ) {
      buttonStyle = "primary"; // Set primary as default if invalid argument
    }

    let classes =
      "navds-button navds-button--" + buttonStyle + " navds-body-short";

    if (this.isLoadingActive) {
      classes += " navds-button--loading";
    }

    return classes;
  }

  handleClick(event) {
    const eventToSend = new CustomEvent("buttonclick", {
      detail: event.target.value,
      bubbles: true,
      composed: true,
    });
    this.dispatchEvent(eventToSend);
  }

  @api focusButton() {
    const btn = this.template.querySelector("button");
    if (btn && !this.isLoadingActive) {
      btn.focus();
    }
  }

  get ariaLabelValue() {
    return this.ariaLabel === undefined ? this.buttonLabel : this.ariaLabel;
  }

  get setDefaultId() {
    return setDefaultValue(this.id, "button");
  }

  get setDefaultName() {
    return setDefaultValue(this.name, "button");
  }

  get setDefaultAutofocus() {
    return convertStringToBoolean(this.autofocus);
  }

  get setDefaultDisabled() {
    const baseDisabled = convertStringToBoolean(this.disabled);
    return baseDisabled || this.isLoadingActive;
  }

  get setDefaultValue() {
    return setDefaultValue(this.value, "defaultValue");
  }

  get setDefaultType() {
    return setDefaultValue(this.type, "button");
  }

  get setDefaultStyle() {
    let style = this.desktopStyle;
    if (window.screen.width < 576) {
      style = this.mobileStyle;
    }
    return setDefaultValue(style, "");
  }

  get isLoadingActive() {
    return convertStringToBoolean(this.isLoading);
  }
}
