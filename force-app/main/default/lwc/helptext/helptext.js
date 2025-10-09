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
  buttonRef;

  helptextFocus(event) {
    this.buttonRef = event.currentTarget;

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

    requestAnimationFrame(async () => {
      this.setHelptextPostition();

      await Promise.resolve();

      requestAnimationFrame(() => {
        popup.setAttribute("tabindex", "0");
        popup.focus();
      });
    });
  }

  helptextBlur(event) {
    const popup = this.template.querySelector('.helptextPopup');
    const backdrop = this.template.querySelector('.helptextBackdrop');

    if (event && popup.contains(event.relatedTarget)) {
      return;
    }

    popup.classList.add('helptextPopup--hidden');
    backdrop.classList.add('helptextPopup--hidden');
    this.ariaExpanded = false;
    this.textToShow = '';

    if (this.buttonRef && typeof this.buttonRef.focus === 'function') {
      this.buttonRef.focus();
    }
    this.buttonRef = null;
  }

  handleKeydown(event) {
    if (event.key === 'Escape' || event.key === 'Esc' || event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      this.helptextBlur(event);
    }
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