import { LightningElement } from 'lwc';

export default class SalesforceHeader extends LightningElement {
    static renderMode = 'light'; // the default is 'shadow'

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
        fetch('https://www.nav.no/dekoratoren?context=privatperson&chatbot=true')
            .then((res) => {
                return res.text();
            })
            .then((html) => {
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');
                const header = doc.getElementById('header-withmenu')?.innerHTML;
                const footer = doc.getElementById('footer-withmenu')?.innerHTML;
                const style = doc.getElementById('styles')?.innerHTML;
                const headerInjection = document.querySelector('#header-injection');
                const footerInjection = document.querySelector('#footer-injection');
                const styleInjection = document.querySelector('#style-injection');
                headerInjection.innerHTML = header;
                footerInjection.innerHTML = footer;
                styleInjection.innerHTML = style;
                const testScript = doc.getElementById('scripts');
                const env = doc.querySelector('#decorator-env');
                const scriptInjection = document.querySelector('#script-injection');
                scriptInjection.appendChild(env);
                const testScript2 = testScript.getElementsByTagName('script');
                const script = document.createElement('script');
                script.setAttribute('type', 'text/javascript');
                script.setAttribute('async', 'true');
                script.setAttribute('src', testScript2[0].src);
                scriptInjection.appendChild(script);
            });
    }
}
