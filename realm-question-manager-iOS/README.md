## How to start

![manager04](http://images.contentful.com/emmiduwd41v7/5dYA1OxsRiA2MUOumy2w0/6d142311c3d252ada4297a4509f03144/manager04.PNG) 

* run `pod install` in terminal
* double click `RealmQnA.xsworkspace` file
* update `syncHost` with your server address in `Constans.swift` file
* build and run

## app detail

### login
* use appropriate username / password for login

![login](/graphics/login.gif)

### add event
* tab Add Event button

![eventlist](/graphics/eventlist.png)

* provide `name` and `path`

![create_event](/graphics/create_event)

* tap create button
* after creating an event, web users can access Realm QnA page with `yourserver/path`

### edit event name
* move to event detail to tab target event cell

![edit_event](/graphics/edit_event.png)

* tab Edit Name button
* provide new event name

![edit_event_detail](/graphics/edit_event_detail.png)

* tab ok button
* note: you can't edit event path

### manage questions
* questions are sorted by three criteria - isAnswers / isFavorite / vote numbers
* swipe left a question cell to answer or to delete
* thumb up button is for vote and heart button is for favorite

![manager](/graphics/manager.png)
