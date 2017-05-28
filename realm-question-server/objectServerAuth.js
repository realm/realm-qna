const credentials = require('./credentials.js');
const Realm = require('realm');

module.exports = () => {
  const username = credentials.user;
  const password = credentials.password;
  const SERVER_URL = credentials.server;
  const QUEST_SERVER_URL = credentials.questserver;

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
  }

  const UserSchema = {
    name: 'User',
    primaryKey: 'id',
    properties: {
      id: 'string',
    },
  };

  return (req, res, next) => {
    Realm.Sync.User.login(SERVER_URL, username, password, (error, user) => {
      if (!error) {
        req.syncRealm = new Realm({
          sync: {
            user,
            url: QUEST_SERVER_URL,
          },
          schema: [QuestionSchema, UserSchema],
        });
        next()
      } else {
        res.status(500).send(error.toString());
      }
    })
  };
}
