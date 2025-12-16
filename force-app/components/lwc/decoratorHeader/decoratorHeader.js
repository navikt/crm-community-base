/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable @locker/locker/distorted-element-inner-html-setter */
/* eslint-disable @lwc/lwc/no-document-query */
import { LightningElement, api } from "lwc";

const envLinks = {
  Prod: "https://www.nav.no/dekoratoren",
  Dev: "https://dekoratoren.ekstern.dev.nav.no/",
};

export default class DecoratorHeader extends LightningElement {
  static renderMode = "light"; // the default is 'shadow'
  @api env;
  @api context;

  connectedCallback() {
    this.fetchHeaderAndFooter();
  }

  //Available parameter key value pairs can be viewed at https://github.com/navikt/nav-dekoratoren#parametere
  changeParameter(key, value) {
    window.postMessage(
      {
        source: "decoratorClient",
        event: "params",
        payload: { [key]: value },
      },
      window.location.origin,
    );
  }

  fetchHeaderAndFooter() {
    const URL = envLinks[this.env] + "?context=" + this.context?.toLowerCase();
    // eslint-disable-next-line @locker/locker/distorted-window-fetch, compat/compat
    fetch(URL)
      .then((res) => {
        return res.text();
      })
      .then((html) => {
        let parser = new DOMParser();
        let doc = parser.parseFromString(html, "text/html");
        // Header
        const headerInjection = document.querySelector("#header-injection");
        if (headerInjection) {
          const header = doc.getElementById("header-withmenu")?.innerHTML;
          headerInjection.innerHTML = header;
        }

        // Footer
        const footerInjection = document.querySelector("#footer-injection");
        if (footerInjection) {
          const footer = doc.getElementById("footer-withmenu")?.innerHTML;
          footerInjection.innerHTML = footer;
        }

        // Style
        const styleInjection = document.querySelector("#style-injection");
        if (styleInjection) {
          const style = doc.getElementById("styles")?.innerHTML;
          styleInjection.innerHTML = style;
        }

        // Script
        const scriptInjection = document.querySelector("#script-injection");
        if (scriptInjection) {
          const scriptContainer = doc.getElementById("scripts");

          const scriptElement = scriptContainer.getElementsByTagName("script");
          const scriptGroupElement = document.createDocumentFragment();
          for (let scripter of scriptElement) {
            if (scripter.id === "__DECORATOR_DATA__") {
              const decoratorData = JSON.parse(scripter.innerHTML ?? '');
              decoratorData.headAssets = decoratorData.headAssets.filter((asset) => {
                  return asset.attribs.rel !== 'manifest';
              });
              window.__DECORATOR_DATA__ = decoratorData;
              continue;
            }
            if (scripter.type == null || scripter.type === "") continue;
            const script = document.createElement("script");
            this.setAttributeIfExists(script, scripter, "type");
            this.setAttributeIfExists(script, scripter, "id");
            this.setAttributeIfExists(script, scripter, "async");
            this.setAttributeIfExists(script, scripter, "src");
            this.setAttributeIfExists(script, scripter, "fetchpriority");
            script.innerHTML = scripter.innerHTML;
            scriptGroupElement.appendChild(script);
          }
          scriptInjection.appendChild(scriptGroupElement);
        }
      });
  }

  setAttributeIfExists(script, scripter, tag) {
    if (scripter[tag] != null && scripter[tag] !== "")
      // eslint-disable-next-line @locker/locker/distorted-element-set-attribute
      script.setAttribute(tag, scripter[tag]);
  }
}
