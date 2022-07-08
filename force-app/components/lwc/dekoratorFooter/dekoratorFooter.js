import { LightningElement, wire } from 'lwc';
export default class DekoratorFooter extends LightningElement {
    connectedCallback() {
        fetch('https://www.nav.no/dekoratoren/?context=privatperson&shareScreen=false')
            .then((res) => {
                return res.text();
            })
            .then((html) => {
                //Funger perfekt (så vidt jeg kan se)
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');
                let test = doc.querySelector('#footer-withmenu');
                const troll = test.querySelector('#decorator-footer');
                troll.className = 'decorator-footer';
                let div = this.template.querySelector('.dekFooter');
                div.appendChild(troll);
                console.log('footer');
            });
    }
}
