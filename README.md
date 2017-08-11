## Overview

![overview](https://images.contentful.com/emmiduwd41v7/3OA5V3IeFOkacuauCims8a/213930f48fe70f7ec806e107f81a19f9/qna-overview.png)

Realm QnA is a sample application for question and answer management for events. Users can ask questions anonymously on web page, and managers can answer those questions. The data is synchronized in realtime with Realm Mobile Platform Professional edition.

### How to use

#### Admin

1. Run iOS application
2. Login with valid user credential
3. Create event with unique {path}
4. Manage specific event in the event detail page

#### Users

1. Connect hostname/{path} : use same path with #3 above
2. User is automatically identified by session

### QnA Manager app

![manager06](http://images.contentful.com/emmiduwd41v7/2uxWKdSItCW8KSCCoAuq0a/22813c4b8a365b2a78544ff70d699456/manager06.PNG)

Managers can create event with specific path, and edit event name. After create an event, users can create questions. Managers can answer, delete and vote questions.

### QnA web page

![web02](http://images.contentful.com/emmiduwd41v7/3qmz30yn9mu0QcwE8aQ2aa/ec0264c1c657c23d03f8001101bb5583/web02.png)

After a manager creates an event with specific path, users can access the event QnA page with `yourserver/path`.

Users are automatically identified with session cookies. Users can create, edit, delete and vote questions.

![web01](http://images.contentful.com/emmiduwd41v7/5YvIMIKtuoUmO6e0wOyi8G/b791be9a3e0715c9b257f62870da313c/web01.png)

![analytics](https://ga-beacon.appspot.com/UA-50247013-2/realm-qna/README?pixel)
