## How to start

![web01](//images.contentful.com/emmiduwd41v7/5YvIMIKtuoUmO6e0wOyi8G/b791be9a3e0715c9b257f62870da313c/web01.png)

### Realm Mobile Platform
* run Realm Mobile Platform Professional edition

### Node server
* add `realm-professional.tgz` file in `realm-question-server` directory.
* add realm dependency `"realm": "file:realm-1.0.0-enterprise.tgz"`
(refer to [Data Connector](https://realm.io/docs/realm-object-server/pe-ee/#data-connector) for detail)
* create credentials.js with below format
* `npm install`
* `DEBUG=app:* npm run serve`

```
'use strict';

module.exports = {
  user: 'example@example.com', 
  password: 'this-is-the-password', 
  server: 'http://127.0.0.1:9080',
  questserver: 'http://127.0.0.1:9080/qna-question-realm',
};

```
