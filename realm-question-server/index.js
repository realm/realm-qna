//
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

'use strict';

const bodyParser = require('body-parser');
const debug = require('debug');
const express = require('express');
const expressHandlebars = require('express-handlebars');
const objectServerAuth = require('./objectServerAuth');
const session = require('express-session');

const app = express();
const log = debug('app:log');

app.use('/static', express.static('static'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(objectServerAuth());
app.use(session({
  secret: 'realm questions',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 24 * 60 * 60 * 1000 },
}));

const handlebars = expressHandlebars.create({
  helpers: {
    ifCond(v1, v2, options) {
      if (v1 === v2) {
        return options.fn(this);
      }
      return options.inverse(this);
    },
  },
  defaultLayout: 'main',
});

app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');

function genUuid() {
  return new Date().toLocaleTimeString() + Math.floor(Math.random() * 10000);
}

app.get('/', (req, res) => {
  res.send('Welcome to Realm QnA. Please add event path e.g. hostname/path');
});

app.get('/:eventSlug', (req, res) => {
  const sess = req.session;
  if (!sess.author) {
    sess.author = genUuid();
  }

  log('redering the index');
  const questions = req.syncRealm.objects('Question').filtered('status = true').sorted([['isAnswered', false], ['voteCount', true]]);
  res.render('index', { eventSlug: req.params.eventSlug, currentUser: sess.author, questions });
});

app.post('/:eventSlug', (req, res) => {
  log('post');

  const mode = req.body.mode;
  const question = req.body.question;
  const id = Number(req.body.id);
  const isVote = req.body.isVote;
  const date = new Date();
  const sess = req.session;
  if (!sess.author) {
    sess.author = genUuid();
  }

  log(`mode: ${mode} / question: ${question} / id: ${id}`);

  if (mode === 'vote') {
    const targetQuestion = req.syncRealm.objects('Question').filtered(`id == ${id}`)[0];
    if (targetQuestion) {
      const votes = targetQuestion.votes;
      const isOwned = `id = "'${sess.author}"`;
      const voteUsers = req.syncRealm.objects('User').filtered(isOwned);
      let voteUser;
      if (voteUsers.length === 0) {
        req.syncRealm.write(() => {
          log('author write');
          voteUser = req.syncRealm.create('User', { id: sess.author }, true);
          log(`vote user: ${voteUser}`);
          log(voteUser);
        });
      } else {
        voteUser = voteUsers[0];
      }

      req.syncRealm.write(() => {
        let done = false;
        Object.keys(votes).forEach((i) => {
          if (done) {
            return;
          }
          const user = votes[i];
          log(`user: ${user}`);
          log(`voteUser: ${voteUser}`);
          if (user.id === voteUser.id) {
            votes.splice(i, 1);
            targetQuestion.voteCount -= 1;
            done = true;
          }
        });
        if (isVote === 'true') {
          votes.push(voteUser);
          targetQuestion.voteCount += 1;
        }
      });
    }
  } else if (mode === 'write' || mode === 'edit') {
    log(`id: ${id} / question: ${question}`);
    req.syncRealm.write(() => {
      req.syncRealm.create('Question', { id, question, date }, true);
    });
  } else if (mode === 'remove') {
    log(`delete id: ${id}`);
    req.syncRealm.write(() => {
      req.syncRealm.create('Question', { id, status: false, date }, true);
    });
  }

  const questions = req.syncRealm.objects('Question').filtered('status = true').sorted([['isAnswered', false], ['voteCount', true]]);
  res.render('index', { eventSlug: req.params.eventSlug, currentUser: sess.author, questions });
});

app.post('/:eventSlug/write', (req, res) => {
  const sess = req.session;
  if (!sess.author) {
    sess.author = genUuid();
  }

  const question = req.body.question;
  const date = new Date();
  const questions = req.syncRealm.objects('Question').sorted('id', true);
  const id = questions.length === 0 ? 0 : questions[0].id + 1;
  const isOwned = `id = "${sess.author}"`;
  const newAuthors = req.syncRealm.objects('User').filtered(isOwned);
  let newAuthor;
  if (newAuthors.length === 0) {
    req.syncRealm.write(() => {
      log('author write');
      newAuthor = req.syncRealm.create('User', { id: sess.author }, true);
    });
  } else {
    newAuthor = newAuthors[0];
  }
  req.syncRealm.write(() => {
    log('question write');
    log(`id: ${id} / author: ${newAuthor.id} question: ${question}`);
    req.syncRealm.create('Question', { id, question, author: newAuthor, date, voteCount: 0 });
  });

  res.redirect(`/${req.params.eventSlug}`);
});

app.listen(80, () => {
  log('listening localhost:80');
});
