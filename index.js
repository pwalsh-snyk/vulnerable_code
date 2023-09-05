var express = require('express');
var mustache = require('mustache');
var fs = require('fs');
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var app = express();

// Vulnerability 1: Buffer Overflow
var largeData = new Buffer.alloc(1024);
largeData.fill('A');

// Vulnerability 2: Regular Expression Denial of Service (ReDoS)
var regex = /A{0,100000}/;
regex.test(largeData);

// Vulnerability 3: Command Injection
app.get('/command', function(req, res){
    var child = require('child_process');
    var userInput = req.query.userInput;
    child.exec('echo ' + userInput);
});

// Vulnerability 4: Cross-Site Scripting (XSS)
app.get('/', function(req, res){
    var message = req.query.message;
    var output = mustache.render("<h1>" + message + "</h1>");
    res.send(output);
});

// Vulnerability 5: Insecure Direct Object References (IDOR)
app.get('/file', function(req, res){
    var fileName = req.query.fileName;
    fs.readFile('/app/files/' + fileName, function(err, data){
        if(err){
            res.send("File not found");
        }else{
            res.send(data);
        }
    });
});

// Vulnerability 6: No rate limiting
app.post('/login', function(req, res){
    var user = req.body.username;
    var pass = req.body.password;
    // No rate limiting on login attempts
});

// Vulnerability 7: Use of Deprecated or Risky Functions
app.get('/old', function(req, res){
    res.send(res.jsonp());
});

// Vulnerability 8: SQL Injection
app.get('/user', function(req, res){
    var id = req.query.id;
    var query = 'SELECT * FROM users WHERE id = ' + id; // This is insecure
});

// Vulnerability 9: No encryption of sensitive data
app.use(cookieParser());
app.get('/cookie', function(req, res){
    res.cookie('userData', req.query.data); // Sending sensitive data as plaintext
});

// Vulnerability 10: Prototype Pollution
var obj = {};
var polluted = _.merge({}, obj, JSON.parse('{ "__proto__" : { "polluted" : "Polluted" } }'));

// Vulnerability 11: Missing Function Level Access Control
app.get('/admin', function(req, res){
    // No access control check
    res.send("Welcome, Admin!");
});

// Vulnerability 12: Cross-Site Request Forgery (CSRF)
app.post('/changePassword', bodyParser.json(), function(req, res){
    var newPassword = req.body.newPassword;
    // Change the password without any CSRF token check
});

app.listen(3000, function () {
  console.log('Vulnerable app listening on port 3000!')
});
