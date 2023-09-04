import os
import pickle
import yaml
from flask import Flask, request
from urllib.parse import urlparse

app = Flask(__name__)

# Vulnerability 1: Command Injection
@app.route('/command')
def command():
    os.system(request.args.get('cmd', ''))
    return '', 200

# Vulnerability 2: Arbitrary File Write
@app.route('/writefile')
def write_file():
    with open(request.args.get('filename', ''), 'w') as f:
        f.write(request.args.get('content', ''))
    return '', 200

# Vulnerability 3: Insecure Deserialization
@app.route('/deserialize')
def deserialize():
    pickle.loads(request.args.get('pickle', b''))
    return '', 200

# Vulnerability 4: YAML Deserialization
@app.route('/yaml')
def yaml_deserialize():
    yaml.load(request.args.get('yaml', ''), Loader=yaml.FullLoader)
    return '', 200

# Vulnerability 5: Arbitrary File Read
@app.route('/readfile')
def read_file():
    with open(request.args.get('filename', '')) as f:
        return f.read()

# Vulnerability 6: SQL Injection
@app.route('/sql')
def sql():
    # This is a placeholder. You'd need a real SQL connection and cursor for this to actually run.
    cursor.execute("SELECT * FROM users WHERE username = '%s'" % request.args.get('username', ''))
    return '', 200

# Vulnerability 7: SSRF
@app.route('/ssrf')
def ssrf():
    import requests
    requests.get(request.args.get('url', ''))
    return '', 200

# Vulnerability 8: URL Redirection
@app.route('/redirect')
def redirect():
    from flask import redirect
    return redirect(request.args.get('url', ''), 302)

# Vulnerability 9: Missing Input Validation
@app.route('/no_validation')
def no_validation():
    return 'Hello, ' + request.args.get('name', '')

# Vulnerability 10: Use of Assert Statement
@app.route('/assert')
def assert_usage():
    assert request.args.get('isAdmin', '') == 'true', "You must be an admin!"
    return '', 200

if __name__ == "__main__":
    app.run(debug=True)
