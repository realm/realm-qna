'use strict';

var express = require('express'),
  bodyParser = require('body-parser'),
  Realm = require('realm'),
  credentials = require('./credentials');

var app = express();

var user = credentials.user;
var password = credentials.password;
var SERVER_URL = credentials.server;

var session = require('express-session');

let QuestionSchema = {
  name: 'Question',
  primaryKey: 'id',
  properties: {
    id: 'int',
    status: {type: 'bool', default: true},
    timestamp: 'date',
    question: 'string',
    author: 'string',
    vote: {type: 'int', default: 0},
    isAnswered: {type: 'bool', default: false},
  }
};

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

app.get('/', function(req, res) {
  var sess = req.session;
  if (!sess.author) {
    sess.author = gennuid()
  }

  Realm.Sync.User.login(SERVER_URL, user, password, (error, user) => {
    var syncRealm;

    if (!error) {
      var syncRealm = new Realm({
        sync: {
          user: user,
          url: 'realm://127.0.0.1:9080/~/question-realm',
        },
        schema: [QuestionSchema]
      });

      let questions = syncRealm.objects('Question').sorted('id', true);
      res.render('index', {currentUser: sess.author, questions: questions});
    } else {
      res.send(error.toString());
    }
  });
});

app.get('/write', function(req, res) {
  res.sendFile(__dirname + "/write.html");
});

app.post('/write', function(req, res) {
  Realm.Sync.User.login(SERVER_URL, user, password, (error, user) => {
    if (!error) {
      var syncRealm = new Realm({
        sync: {
          user: user,
          url: 'realm://127.0.0.1:9080/~/question-realm',
        },
        schema: [QuestionSchema]
      });

      let question = req.body['question'],
      author = req.body['author'],
      timestamp = new Date(),
      questions = syncRealm.objects('Question').sorted('id', true);
      let id = (questions.length == 0 ? 0 : questions[0].id + 1);

      var sess = req.session;
      if (!sess.author) {
        sess.author = gennuid()
      }

      console.log("id:" + id + " author: " + sess.author + "question: " + question);

      syncRealm.write(() => {
        syncRealm.create('Question', {id: id, question: question, author: sess.author, timestamp: timestamp});
      });
    }
  });

  res.sendFile(__dirname + "/write-complete.html");
});

app.listen(3000, function() {
  console.log("Go!");
});

function gennuid() {
  return new Date().toLocaleTimeString() + Math.floor(Math.random() * 10000)
}

// handlebars.registerHelper('ifCond', function (v1, operator, v2, options) {
//     switch (operator) {
//         case '==':
//             return (v1 == v2) ? options.fn(this) : options.inverse(this);
//         case '===':
//             return (v1 === v2) ? options.fn(this) : options.inverse(this);
//         case '!=':
//             return (v1 != v2) ? options.fn(this) : options.inverse(this);
//         case '!==':
//             return (v1 !== v2) ? options.fn(this) : options.inverse(this);
//         case '<':
//             return (v1 < v2) ? options.fn(this) : options.inverse(this);
//         case '<=':
//             return (v1 <= v2) ? options.fn(this) : options.inverse(this);
//         case '>':
//             return (v1 > v2) ? options.fn(this) : options.inverse(this);
//         case '>=':
//             return (v1 >= v2) ? options.fn(this) : options.inverse(this);
//         case '&&':
//             return (v1 && v2) ? options.fn(this) : options.inverse(this);
//         case '||':
//             return (v1 || v2) ? options.fn(this) : options.inverse(this);
//         default:
//             return options.inverse(this);
//     }
// });
