from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_ekipa():
    return '<h1>Hello Ekipa2</h2>'


if __name__ == "__main__":
    app.run(debug=True)