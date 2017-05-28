## How to start
### Node server
* create credentials.js with below format
* `npm install`
* `DEBUG=app:* npm run serve`

```
'use strict';

module.exports = {
  user: 'example@example.com', 
  password: 'this-is-the-password', 
  server: 'http://127.0.0.1:9080',
  questserver: 'http://127.0.0.1:9080',,,,
};

```
