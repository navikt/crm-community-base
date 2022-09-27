import { LightningElement } from 'lwc';

export default class SalesforceHeader extends LightningElement {
    static renderMode = 'light'; // the default is 'shadow'

    // console.log("Heisann");
    // console.log(this);
    connectedCallback() {
        fetch('https://www.dev.nav.no/dekoratoren?context=privatperson&chatbot=true')
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

                // console.log(scripts);
                const scriptInjection = document.querySelector('#script-injection');
                // const env = scripts.querySelector('#decorator-env');
                scriptInjection.appendChild(env);
                const testScript2 = testScript.getElementsByTagName('script');
                // const scriptCopy = scripts.getElementsByTagName('script')[0];
                const script = document.createElement('script');
                script.setAttribute('type', 'text/javascript');
                // script.setAttribute('async', scriptCopy.async);
                // script.setAttribute('src', scriptCopy.src);
                script.setAttribute('async', 'true');
                script.setAttribute('src', testScript2[0].src);
                const testParamChanges = () => {
                    console.log('Heisann det er meg');
                    window.postMessage(
                        {
                            source: 'decoratorClient',
                            event: 'params',
                            payload: { chatbotVisible: true }
                        },
                        window.location.origin
                    );
                };
                script.addEventListener('load', testParamChanges);
                scriptInjection.appendChild(script);
            });
    }

    renderedCallback() {
        // query(event) {
        console.log('Sup');
        // const troll = document.createElement('div');
        // troll.className = 'decorator-header';
        // let div = this.template.querySelector('.insElement');
        // let div = document.querySelector('.insElement');
        // div.appendChild(troll);

        // let b = document.createElement('div');
        // b.id = 'decorator-env';
        // b.className = 'decorator-env';
        // b.setAttribute('data-src', 'https://www.nav.no/dekoratoren/env?context=arbeidsgiver');
        // div.append(b);
        // eslint-disable-next-line @lwc/lwc/no-document-query
        // let div = document.querySelector('#decorator-env');
        // const script = document.createElement('script');
        // script.setAttribute('type', 'text/javascript');
        // script.setAttribute('async', 'true');
        // script.setAttribute('src', 'http://localhost:8088/dekoratoren/client.asdf.js');
        // div.appendChild(script);
    }
}
