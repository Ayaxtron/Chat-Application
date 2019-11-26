    const express = require('express');
    const bodyParser = require('body-parser');
    const Pusher = require('pusher');
    const app = express();

    let users = {};
    let currentUser = {};

    let pusher = new Pusher({
        appId: '906423',
        key: '498515b00c8bf453e7d1',
        secret: '16e6f288a40ba95d02df',
        cluster: 'us2'
    });

    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({
        extended: false
    }));

    //Route creates a nuew user
    app.post('/users', (req, res) => {
      const name = req.body.name;
      const matchedUsers = Object.keys(users).filter(id => users[id].name === name);

      if (matchedUsers.length === 0) {
        const id = generate_random_id();
        users[id] = currentUser = { id, name };
      } else {
        currentUser = users[matchedUsers[0]];
      }

      res.json({ currentUser, users });
    });

    //Route Authenticates the user
      app.post('/pusher/auth/presence', (req, res) => {
      let socketId = req.body.socket_id;
      let channel = req.body.channel_name;

      let presenceData = {
        user_id: currentUser.id,
        user_info: { name: currentUser.name }
      };

      let auth = pusher.authenticate(socketId, channel, presenceData);

      res.send(auth);
    });

    //Literally generates a random ID to the user
    function generate_random_id() {
      let s4 = () => (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
      return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
    }
    
    //Default Route
    app.get('/', (req, res) => res.send('It works!'));
    
    app.listen(process.env.PORT || 5000);