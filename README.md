# Realm QnA

## Overview

![overview](/graphics/overview.png)

Realm QnA is a sample application for question and answer management for events. Users can ask questions anonymously on web page, and managers can answer those questions. The data is synchronized in realtime with Realm Mobile Platform Professional edition.

### How to use

#### Admin

1. Run iOS application
2. Login with valid user credential
3. Create event with unique {path}
4. Manage specific event in the event detail page

#### Users

1. Connect to "hostname/{path}" : use {path} created by admin
2. User is automatically identified by session

### QnA Manager app

![manager01](/graphics/manager.png)

Managers can create event with specific path, and edit event name. After create an event, users can create questions. Managers can answer, delete and vote questions.

### QnA web page

![web01](/graphics/web.png)

After a manager creates an event with specific path, users can access the event QnA page with `yourserver/path`.

Users are automatically identified with session cookies. Users can create, edit, delete and vote questions.

# Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](https://realm.io/conduct/). By participating, you are expected to uphold this code. Please report unacceptable behavior to [info@realm.io](mailto:info@realm.io).

# License

The source code for RealmTasks is licensed under the [Apache License 2.0](LICENSE).
![analytics](https://ga-beacon.appspot.com/UA-50247013-2/realm-qna/README?pixel)
