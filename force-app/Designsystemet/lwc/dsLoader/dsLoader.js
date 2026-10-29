import { LightningElement, api } from "lwc";

export default class DsLoader extends LightningElement {
  @api size = "medium";
  @api title = "Venter...";
  @api variant = "neutral";
  @api color = "neutral";
  @api transparent = false;

  get loaderClass() {
    return (
      `aksel-loader aksel-loader--${this.size} aksel-loader--${this.variant}` +
      (this.transparent ? " aksel-loader--transparent" : "")
    );
  }

  @api
  focus() {
    this.template.querySelector("svg")?.focus();
  }
}
