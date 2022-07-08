import { LightningElement } from 'lwc';
// import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
// import TestDek from '@salesforce/resourceUrl/TestDek';
// import TestDek from '@salesforce/resourceUrl/testDek';

export default class GlobalDekorator extends LightningElement {
    connectedCallback() {
        // loadStyle(this, TestDekStyle);
        fetch(
            'https://dekoratoren.ekstern.dev.nav.no/?context=privatperson&breadcrumbs=[{%22title%22:%22Privatperson%22,%22url%22:%22https://www.nav.no%22}]'
        )
            .then((res) => {
                console.log('Ponk');
                return res.text();
            })
            .then((html) => {
                console.log('Start');
                //Funger perfekt (så vidt jeg kan se)
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');
                let test = doc.querySelector('#header-withmenu');
                let a = doc.querySelector('#decorator-env');
                a.className = 'decorator-env';
                const troll = test.querySelector('#decorator-header');
                troll.className = 'decorator-header';
                let div = this.template.querySelector('.testDiv');
                div.appendChild(troll);
                div.appendChild(a);
                // let testScript = doc.querySelector('#scripts');
                // const truls = testScript.querySelector('#decorator-env');
                // truls.className = 'test';
                // div.appendChild(truls);
                console.log('Lastet');

                // <script async="true" src="https://dekoratoren.ekstern.dev.nav.no/client.js"></script>;
                // const e = document.createElement('script');
                // e.async = true;
                // e.src = 'https://dekoratoren.ekstern.dev.nav.no/client.js';
                // div.appendChild(e);

                console.log('Geir');
                // loadScript(this, TestDek)
                //     .then((res) => {
                //         console.log('Hei');
                //         console.log(res);
                //     })
                //     .catch((r) => {
                //         console.log('Hade');
                //         console.log(r);
                //     });
            })
            .catch((e) => {
                console.log('Karn');
                console.log(e);
            });
    }

    godtTest() {
        console.log('Godt test med mange trank');
    }
}

// Lagt til <link rel="stylesheet" href="https://www.nav.no/dekoratoren/css/client.css" /> for styling
