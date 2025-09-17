import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class Helptext extends LightningElement {
  @api hoverText;
  @api text;
  @api desktopStyle;
  @api mobileStyle;

  defaultStyle = '';
  arrowStyle = '';

  get setDefaultStyle() {
    let style = this.desktopStyle;
    if (window.screen.width < 576) {
      style = this.mobileStyle;
    }
    return setDefaultValue(style, '');
  }

   textToShow = '';
  ariaExpanded = false;
  helptextFocus() {
    const popup = this.template.querySelector(".helptextPopup");
    const backdrop = this.template.querySelector(".helptextBackdrop");

    if (!popup.classList.contains("helptextPopup--hidden")) {
      this.helptextBlur();
      return;
    }

  
    popup.classList.remove("helptextPopup--hidden");
    backdrop.classList.remove("helptextPopup--hidden");
    this.ariaExpanded = true;
    this.textToShow = this.text;
    requestAnimationFrame(() => this.setHelptextPostition());
  }

  helptextBlur() {
    const popup = this.template.querySelector('.helptextPopup');
    const backdrop = this.template.querySelector('.helptextBackdrop');
    popup.classList.add('helptextPopup--hidden');
    backdrop.classList.add('helptextPopup--hidden');
    this.ariaExpanded = false;
    this.textToShow = '';
  }

  get defaultHoverText() {
    return setDefaultValue(this.hoverText, 'Hjelpeknapp');
  }

  setHelptextPostition() {
    if (window.screen.width < 576) {
    const element = this.template.querySelector('.helptextButton');
    const popup = this.template.querySelector('.helptextPopup');
    const arrow = this.template.querySelector('.helptextArrow');
    if (!element || !popup || !arrow) return;

    const rect = element.getBoundingClientRect();
    const vw = Math.max(
      document.documentElement.clientWidth,
      window.innerWidth || 0,
    );
    const vh = Math.max(
      document.documentElement.clientHeight,
      window.innerHeight || 0,
    );
    const margin = 8;
    const gap = 8;

    const popW = Math.min(popup.offsetWidth || 0, vw - margin * 2);
    const popH = Math.min(popup.offsetHeight || 0, vh - margin * 2);

    let x = rect.left + rect.width / 2 - popW / 2;
    x = Math.max(margin, Math.min(x, vw - popW - margin));

    const aboveY = rect.top - popH - gap;
    const belowY = rect.bottom + gap;
    const canAbove = aboveY >= margin;
    const canBelow = belowY + popH <= vh - margin;

    let y, arrowEdge;
    if (canAbove || !canBelow) {
      y = Math.max(margin, aboveY);
      arrowEdge = "bottom";
    } else {
      y = Math.min(vh - popH - margin, belowY);
      arrowEdge = "top";
    }

    this.defaultStyle = `left:${Math.round(x)}px; top:${Math.round(y)}px; right:auto; bottom:auto; transform:none; position:fixed;`;

    const arrowHalf = 7;
    let arrowX = rect.left + rect.width / 2 - x - arrowHalf;
    arrowX = Math.max(12, Math.min(arrowX, popW - 12));
    const vert =
      arrowEdge === "bottom"
        ? "bottom:-7px; top:auto;"
        : "top:-7px; bottom:auto;";
    this.arrowStyle = `left:${Math.round(arrowX)}px; right:auto; ${vert}`;
  }
}
}