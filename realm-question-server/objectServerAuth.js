////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

'use strict';

const credentials = require('./credentials.js');
const Realm = require('realm');

module.exports = () => {
  const username = credentials.user;
  const password = credentials.password;
  const serverUrl = credentials.server;
  const questServerUrl = credentials.questserver;
  const eventServerUrl = credentials.eventserver;

  const QuestionSchema = {
    name: 'Question',
    primaryKey: 'id',
    properties: {
      id: 'int',
      status: { type: 'bool', default: true },
      date: 'date',
      question: 'string',
      author: { type: 'User' },
      votes: { type: 'list', objectType: 'User' },
      voteCount: 'int',
      isAnswered: { type: 'bool', default: false },
    },
  };

  const UserSchema = {
    name: 'User',
    primaryKey: 'id',
    properties: {
      id: 'string',
    },
  };

  const EventSchema = {
    name: 'Event',
    primaryKey: 'id',
    properties: {
      id: 'string',
      status: 'bool',
      date: 'date',
      name: 'string',
    },
  };

  function checkEventRealm(user, targetPath) {
    let eventRealm = new Realm({
      sync: {
        user,
        url: eventServerUrl,
      },
      schema: [EventSchema],
    });

    const events = eventRealm.objects('Event').filtered('status = true');

    for (var i in events) {
      const eventPath = events[i].id;
      if (eventPath === targetPath) {
        return true;
      }
    }

    return false;
  }

  function getQuestionRealm(user, eventNumber) {
    return new Realm({
      sync: {
        user,
        url: questServerUrl + eventNumber,
      },
      schema: [QuestionSchema, UserSchema],
    });
  }

  return (req, res, next) => {
    const eventPath = req.path.split('/');
    if (eventPath.length > 1 && eventPath[1] !== '' && eventPath[1] !== 'favicon.ico') {
      console.log('--------' + eventPath[1]);
      var isValidPath;
      if (Realm.Sync.User.current) {
        isValidPath = checkEventRealm(Realm.Sync.User.current, eventPath[1]);
      } else {
        Realm.Sync.User.login(serverUrl, username, password, (error, user) => {
          if (!error) {
            isValidPath = checkEventRealm(user, eventPath[1]);
          } else {
            res.status(500).send(error.toString());
          }
        });
      }

      if (isValidPath) {
        req.syncRealm = getQuestionRealm(Realm.Sync.User.current, eventPath[1]);
        next();
      } else {
        res.status(500).send('No such a event! Please access with event path e.g. hostname/path');
      }
    } else {
      res.send('Welcome to Realm QnA. Please add event path e.g. hostname/path');
    }
  };
};
