from flask import Flask
import requests
app = Flask(__name__)
url = "http://metadata.google.internal/computeMetadata/v1/instance/region"

@app.route('/')
def hello_ekipa():

    region = requests.get(url)
    return '<h1>{}</h2>'.format(region)
    


if __name__ == "__main__":
    app.run(debug=True)