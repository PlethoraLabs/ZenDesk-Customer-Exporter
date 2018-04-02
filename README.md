# ZenDesk-Customer-Exporter
Export a list of Customer from ZenDesk using Node.JS

## Description

If you don't have a Professional or Enterprise plan on ZenDesk, you can export a list of your customers using this script.

*Prerequisites:*

[Node.js](https://nodejs.org/en/) installed
```
$ npm install
```
## Usage:

```
Syntax: ZENDESK_USER=<USERNAME> ZENDESK_TOKEN=<TOKEN> ZENDESK_DOMAIN=<SUBDOMAIN> node zendesk.js
```

For **myfirm**.zendesk.com:

```
$ npm install
$ ZENDESK_USER=myusername@gmail.com ZENDESK_TOKEN=1234567890 ZENDESK_DOMAIN=myfirm node zendesk.js
```
