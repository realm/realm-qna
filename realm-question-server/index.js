'use strict';

var express = require('express'),
  bodyParser = require('body-parser'),
  Realm = require('realm'),
  credentials = require('./credentials')

var app = express();

var user = credentials.user
var password = credentials.password
var SERVER_URL = credentials.server
var QUEST_SERVER_URL = credentials.questserver

var session = require('express-session')

let QuestionSchema = {
  name: 'Question',
  primaryKey: 'id',
  properties: {
    id: 'int',
    status: {type: 'bool', default: true},
    date: 'date',
    question: 'string',
    author: {type: 'User'},
    votes: {type: 'list', objectType: 'User'},
    voteCount: 'int',
    isAnswered: {type: 'bool', default: false},
  }
}
 
let UserSchema = {
  name: 'User',
  primaryKey: 'id',
  properties: {
    id: 'string'
  }
}

app.use('/static', express.static('static'))
app.use(bodyParser.urlencoded({extended: true}));
app.use(session({
  secret: 'realm questions',
  resave: false,
  saveUninitialized: false,
  cookie: {secure: false, maxAge: 24 * 60 * 60 * 1000}
}));

var handlebars = require('express-handlebars').create({
  helpers: {
    ifCond: function(v1, v2, options) {
      if(v1 === v2) {
        return options.fn(this);
      }
      return options.inverse(this);
    }
  },
  defaultLayout:'main'
});

app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');
var syncRealm;
var questions;

Realm.Sync.User.login(SERVER_URL, user, password, (error, user) => {

  if (!error) {
    syncRealm = new Realm({
      sync: {
        user: user,
        url: QUEST_SERVER_URL,
      },
      schema: [QuestionSchema, UserSchema]
    });
  } else {
    res.send(error.toString());
  }
});
    
app.get('/', function(req, res) {
  var sess = req.session;
  if (!sess.author) {
    sess.author = gennuid()
  }

  console.log("redering the index")
  questions = syncRealm.objects('Question').filtered('status = true').sorted([['isAnswered', false], ['voteCount', true]]);
  res.render('index', {currentUser: sess.author, questions: questions});

});

app.post('/', function(req, res) {
  console.log("post")
  
  let question = req.body['question'],
  qid = Number(req.body['qid']),
  vid = req.body['vid'],
  isVote = req.body['isVote'],
  date = new Date(),
  sess = req.session;

  console.log("question: " + question + " / qid: " + qid + " / vid: " + vid)
  
  if (vid) {
    let targetQuestion = syncRealm.objects('Question').filtered('id == ' + vid)[0]
    let votes = targetQuestion.votes
    
    var pred = 'id = "' + sess.author + '"'
    let voteUser =  syncRealm.objects('User').filtered(pred)
    if (voteUser.length == 0) {
      syncRealm.write(() => {
        console.log("author write")
        voteUser = syncRealm.create('User', {id: sess.author}, true)
        console.log("vote user")
        console.log(voteUser)
      })
    } else {
      voteUser = voteUser[0]
    }
    
    syncRealm.write(() => {
      for (var i = 0, user; user = votes[i]; i++) {
        if (user.id == voteUser.id) {
          votes.splice(i, 1)
          targetQuestion.voteCount--
        }
      }
      if (isVote == 'true') {
        votes.push(voteUser)
        targetQuestion.voteCount++
      }
    })
  } else if (question) {
    syncRealm.write(() => {
      console.log("id: " + qid + " / question: " + question)
      syncRealm.create('Question', {id: qid, question: question, date: date}, true)
    });
  } else if (qid){
    syncRealm.write(() => {
      console.log("delete" + " id: " + qid)
      syncRealm.create('Question', {id: qid, status: false, date: date}, true)
    })
  }

  questions = syncRealm.objects('Question').filtered('status = true').sorted([['isAnswered', false], ['voteCount', true]]);
  res.render('index', {currentUser: sess.author, questions: questions});
  
})

app.post('/write', function(req, res) {
  var sess = req.session;
  if (!sess.author) {
    sess.author = gennuid()
  }

  let question = req.body['question'],
  date = new Date(),
  questions = syncRealm.objects('Question').sorted('id', true)
  let id = (questions.length == 0 ? 0 : questions[0].id + 1)
  var pred = 'id = "' + sess.author + '"'
  let newAuthor =  syncRealm.objects('User').filtered(pred)
  if (newAuthor.length == 0) {
    syncRealm.write(() => {
      console.log("author write")
      newAuthor = syncRealm.create('User', {id: sess.author}, true)
    });
  } else {
    newAuthor = newAuthor[0]
  }
  syncRealm.write(() => {
    console.log("question write")
    console.log("id: " + id + " / author: " + newAuthor.id + " / question: " + question);
    syncRealm.create('Question', {id: id, question: question, author: newAuthor, date: date, voteCount: 0})
  });

  res.redirect('/')
});

app.listen(3000, function() {
  console.log("listening localhost:3000");
});

function gennuid() {
  return new Date().toLocaleTimeString() + Math.floor(Math.random() * 10000)
}
