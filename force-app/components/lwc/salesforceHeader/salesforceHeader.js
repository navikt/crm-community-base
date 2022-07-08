import { LightningElement } from 'lwc';

export default class SalesforceHeader extends LightningElement {
    static renderMode = 'light'; // the default is 'shadow'

    // console.log("Heisann");
    // console.log(this);

    // renderedCallback() {
    query(event) {
        const troll = document.createElement('div');
        troll.className = 'decorator-header';
        let div = this.template.querySelector('.insElement');
        console.log(troll);
        console.log(div);
        div.appendChild(troll);

        let b = document.createElement('div');
        b.id = 'decorator-env';
        b.className = 'decorator-env';
        b.setAttribute('data-src', 'https://www.nav.no/dekoratoren/env?context=arbeidsgiver');
        div.append(b);
        const script = document.createElement('script');
        script.setAttribute('type', 'text/javascript');
        script.setAttribute('async', 'true');
        script.setAttribute('src', 'https://www.nav.no/dekoratoren/client.js');
        div.appendChild(script);
    }
}
