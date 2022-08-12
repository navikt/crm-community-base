import { LightningElement } from 'lwc';

export default class SalesforceHeader extends LightningElement {
    static renderMode = 'light'; // the default is 'shadow'

    // console.log("Heisann");
    // console.log(this);
    connectedCallback() {
        fetch(
            'http://localhost:8088/dekoratoren?context=privatperson&breadcrumbs=[{%22title%22:%22Privatperson%22,%22url%22:%22https://www.nav.no%22}]'
        )
            .then((res) => {
                console.log('Ponk');
                return res.text();
            })
            .then((html) => {
                console.log('Start');
                console.log(html);
                console.log(html.search('<script>'));
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');
                const header = doc.getElementById('header-withmenu')?.innerHTML;
                const footer = doc.getElementById('footer-withmenu')?.innerHTML;
                const headerInjection = document.querySelector('#header-injection');
                const footerInjection = document.querySelector('#footer-injection');
                headerInjection.innerHTML = header;
                footerInjection.innerHTML = footer;

                console.log('Heisann');
                console.log(doc);

                const env = doc.querySelector('#decorator-env');
                // console.log(scripts);
                const scriptInjection = document.querySelector('#script-injection');
                // const env = scripts.querySelector('#decorator-env');
                scriptInjection.appendChild(env);

                // const scriptCopy = scripts.getElementsByTagName('script')[0];
                const script = document.createElement('script');
                script.setAttribute('type', 'text/javascript');
                // script.setAttribute('async', scriptCopy.async);
                // script.setAttribute('src', scriptCopy.src);
                script.setAttribute('async', 'true');
                script.setAttribute('src', 'http://localhost:8088/dekoratoren/client.asdf.js');
                scriptInjection.appendChild(script);

                const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
                const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
                const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
                svg.appendChild(rect);
                svg.appendChild(circle);

                headerInjection.appendChild(svg);
                console.log('Yippi');
                console.log(svg);
                svg.setAttribute('height', '200');
                rect.setAttribute('height', '100%');
                circle.setAttribute('cx', '150');
                svg.setAttribute('width', '300');
                rect.setAttribute('width', '100%');
                rect.setAttribute('fill', 'black');
                circle.setAttribute('cy', '100');
                circle.setAttribute('r', '90');
                circle.setAttribute('fill', 'blue');
                svg.setAttribute('viewBox', '-250 -250 500 750');
                console.log(svg);
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
