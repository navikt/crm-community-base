import { LightningElement, api } from 'lwc';

const envLinks = { Prod: 'https://www.nav.no/dekoratoren', Dev: 'https://dekoratoren.ekstern.dev.nav.no/' };

export default class DecoratorHeader extends LightningElement {
    static renderMode = 'light'; // the default is 'shadow'
    @api env;
    @api context;

    connectedCallback() {
        this.fetchHeaderAndFooter();
    }

    //Available parameter key value pairs can be viewed at https://github.com/navikt/nav-dekoratoren#parametere
    changeParameter(key, value) {
        window.postMessage(
            {
                source: 'decoratorClient',
                event: 'params',
                payload: { [key]: value }
            },
            window.location.origin
        );
    }

    fetchHeaderAndFooter() {
        const URL = envLinks[this.env] + '?context=' + this.context?.toLowerCase();
        fetch(URL)
            .then((res) => {
                return res.text();
            })
            .then((html) => {
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');
                // Header
                const headerInjection = document.querySelector('#header-injection');
                if (headerInjection) {
                    const header = doc.getElementById('header-withmenu')?.innerHTML;
                    headerInjection.innerHTML = header;
                }

                // Footer
                const footerInjection = document.querySelector('#footer-injection');
                if (footerInjection) {
                    const footer = doc.getElementById('footer-withmenu')?.innerHTML;
                    footerInjection.innerHTML = footer;
                }

                // Style
                const styleInjection = document.querySelector('#style-injection');
                if (styleInjection) {
                    const style = doc.getElementById('styles')?.innerHTML;
                    styleInjection.innerHTML = style;
                }

                // Script
                const scriptInjection = document.querySelector('#script-injection');
                if (scriptInjection) {
                    const scriptContainer = doc.getElementById('scripts');

                    const envElement = doc.querySelector('#decorator-env');
                    scriptInjection.appendChild(envElement);

                    const scriptElement = scriptContainer.getElementsByTagName('script');
                    const script = document.createElement('script');
                    script.setAttribute('type', 'text/javascript');
                    script.setAttribute('async', 'true');
                    script.setAttribute('src', scriptElement[0].src);
                    scriptInjection.appendChild(script);
                }
            });
    }
}
