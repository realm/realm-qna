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
    author: {type: 'User'},
    votes: {type: 'list', objectType: 'User'},
    isAnswered: {type: 'bool', default: false},
  }
};

let UserSchema = {
  name: 'User',
  primaryKey: 'id',
  properties: {
    id: 'string'
  }
}

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
        schema: [QuestionSchema, UserSchema]
      });

      let questions = syncRealm.objects('Question').filtered('status = true').sorted('id', true);
      res.render('index', {currentUser: sess.author, questions: questions});
    } else {
      res.send(error.toString());
    }
  });
});

app.post('/', function(req, res) {
  console.log("post")
  
  Realm.Sync.User.login(SERVER_URL, user, password, (error, user) => {
    if (!error) {
      let syncRealm = new Realm({
        sync: {
          user: user,
          url: 'realm://127.0.0.1:9080/~/question-realm',
        },
        schema: [QuestionSchema, UserSchema]
      });

      let question = req.body['question'],
      qid = Number(req.body['qid']),
      vid = req.body['vid'],
      isVote = req.body['isVote'],
      timestamp = new Date(),
      sess = req.session;
  
      console.log("question: " + question + "qid: " + qid + "vid: " + vid)
      
      if (vid) {
        let votes = syncRealm.objects('Question').filtered('id == ' + vid)[0].votes
        
        var pred = 'id = "' + sess.author + '"'
        let voteUser =  syncRealm.objects('User').filtered(pred)
        if (voteUser.length == 0) {
          syncRealm.write(() => {
            console.log("author write")
            voteUser = syncRealm.create('User', {id: sess.author}, true)
          })
        } else {
          voteUser = voteUser[0]
        }
        
        syncRealm.write(() => {
          for (var i = 0, user; user = votes[i]; i++) {
            if (user.id == voteUser.id) {
              votes.splice(i, 1)
            }
          }
          if (isVote == 'true') {
            votes.push(voteUser)
          }
        })
      } else if (question) {
        syncRealm.write(() => {
          console.log("id: " + qid + "question: " + question)
          syncRealm.create('Question', {id: qid, question: question, timestamp: timestamp}, true)
        });
      } else if (qid){
        syncRealm.write(() => {
          console.log("delete" + "id: " + qid)
          syncRealm.create('Question', {id: qid, status: false, timestamp: timestamp}, true)
        })
      }
    }
  })

  res.sendFile(__dirname + "/write-complete.html");
})

// app.put('/', function(req, res) {
//   
//   console.log("put")
//   Realm.Sync.User.login(SERVER_URL, user, password, (error, user) => {
//     if (!error) {
//       let syncRealm = new Realm({
//         sync: {
//           user: user,
//           url: 'realm://127.0.0.1:9080/~/question-realm',
//         },
//         schema: [QuestionSchema, UserSchema]
//       });
// 
//       let qid = req.body['qid'],
//       uid = req.body['uid'];
//       console.log("qid: " + qid + "uid: " + uid)
//       
//       if (qid && uid) {
//         let votes = syncRealm.objects('Question').filtered('id = "' + qid + '"')[0].votes;
//         console.log("vote: " + votes)
//       }
//     }
//   });
//   
//   res.sendFile(__dirname + "/write-complete.html");
// });

app.get('/write', function(req, res) {
  res.sendFile(__dirname + "/write.html");
});

app.post('/write', function(req, res) {
  Realm.Sync.User.login(SERVER_URL, user, password, (error, user) => {
    if (!error) {
      var sess = req.session;
      if (!sess.author) {
        sess.author = gennuid()
      }

      let syncRealm = new Realm({
        sync: {
          user: user,
          url: 'realm://127.0.0.1:9080/~/question-realm',
        },
        schema: [QuestionSchema, UserSchema]
      });

      let question = req.body['question'],
      timestamp = new Date(),
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
        console.log("id: " + id + " author: " + newAuthor.id + "question: " + question);
        syncRealm.create('Question', {id: id, question: question, author: newAuthor, timestamp: timestamp})
      });
    }
  });

  res.sendFile(__dirname + "/write-complete.html");
});

app.listen(3000, function() {
  console.log("listening localhost:3000");
});

function gennuid() {
  return new Date().toLocaleTimeString() + Math.floor(Math.random() * 10000)
}
