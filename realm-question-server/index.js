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
  const sess = req.session;
  if (!sess.author) {
    sess.author = genUuid();
  }

  log('redering the index');
  const questions = req.syncRealm.objects('Question').filtered('status = true').sorted([['isAnswered', false], ['voteCount', true]]);
  res.render('index', { currentUser: sess.author, questions });
});

app.post('/', (req, res) => {
  log('post');

  const question = req.body.question;
  const qid = Number(req.body.qid);
  const vid = req.body.vid;
  const isVote = req.body.isVote;
  const date = new Date();
  const sess = req.session;
  if (!sess.author) {
    sess.author = genUuid();
  }

  log(`question: ${question} / qid: ${qid} / vid: ${vid}`);

  if (vid) {
    const targetQuestion = req.syncRealm.objects('Question').filtered(`id == ${vid}`)[0];
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
      voteUser = voteUser[0];
    }

    req.syncRealm.write(() => {
      Object.keys(votes).forEach((i) => {
        const user = votes[i];
        if (user.id === voteUser.id) {
          votes.splice(i, 1);
          targetQuestion.voteCount -= 1;
        }
      });
      if (isVote === 'true') {
        votes.push(voteUser);
        targetQuestion.voteCount += 1;
      }
    });
  } else if (question) {
    req.syncRealm.write(() => {
      log(`id: ${qid} / question: ${question}`);
      req.syncRealm.create('Question', { id: qid, question, date }, true);
    });
  } else if (qid) {
    req.syncRealm.write(() => {
      log(`delete id: ${qid}`);
      req.syncRealm.create('Question', { id: qid, status: false, date }, true);
    });
  }

  const questions = req.syncRealm.objects('Question').filtered('status = true').sorted([['isAnswered', false], ['voteCount', true]]);
  res.render('index', { currentUser: sess.author, questions });
});

app.post('/write', (req, res) => {
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

  res.redirect('/');
});

app.listen(3000, () => {
  log('listening localhost:3000');
});
