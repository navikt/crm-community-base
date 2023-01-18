import fetch from 'node-fetch';
import fs from 'fs';
import builder from 'xmlbuilder';

//script-src is experience specific
//There is currently no example of any media-src
const allowedCsp = ['style-src', 'font-src', 'img-src', 'frame-src', 'connect-src', 'media-src'];

const ignoredAreas = ["'unsafe-inline'", "'unsafe-eval'", 'data:'];

const xmlTabMap = [
    { name: 'isApplicableToConnectSrc', property: 'connect-src' },
    { name: 'isApplicableToFontSrc', property: 'font-src' },
    { name: 'isApplicableToFrameSrc', property: 'frame-src' },
    { name: 'isApplicableToImgSrc', property: 'img-src' },
    { name: 'isApplicableToMediaSrc', property: 'media-src' },
    { name: 'isApplicableToStyleSrc', property: 'style-src' }
];

fetch('https://www.nav.no/dekoratoren/api/csp')
    .then((resp) => resp.json())
    .then((initState) => {
        const formatted = {};
        for (const property in initState) {
            if (!allowedCsp.includes(property)) continue;
            initState[property].forEach((item) => {
                if (ignoredAreas.includes(item)) return;
                formatted[item] = formatted[item] ? [...formatted[item], property] : [property];
            });
        }
        return formatted;
    })
    .then((cspList) => {
        for (const item in cspList) {
            let name = item.replace(/[ \-&/\\#,+()$~%.'":?<>{}]/g, '_');
            name = name.replace(/\*/g, 'star');
            var doc = builder
                .create('CspTrustedSite', { version: '1.0', encoding: 'UTF-8' })
                .att('xmlns', 'http://soap.sforce.com/2006/04/metadata')
                .ele('context', null, 'Communities')
                .up()
                .ele('endpointUrl', null, item)
                .up()
                .ele('isActive', null, 'true')
                .up();
            xmlTabMap.forEach((xmlTab) => {
                doc.ele(xmlTab.name, null, cspList[item].includes(xmlTab.property)).up();
            });
            const final = doc.end({ pretty: true });
            const path = 'force-app/main/default/cspTrustedSites/';
            const fileName = path + name + '.cspTrustedSite-meta.xml';
            fs.writeFile(fileName, final, function (err) {
                if (err) throw err;
                console.log('Saved!');
            });
        }
    });
