from flask import Flask

app = Flask(__name__)

# activate hot reloading
app.debug = True

@app.route('/')
def index():
    return 'Hello, World!'

@app.route('/isalive')
def is_alive():
    return 'OK'

if __name__ == '__main__':
     app.run()