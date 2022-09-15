from flask import Flask
import requests
app = Flask(__name__)
url = "http://metadata.google.internal/computeMetadata/v1/instance/region"

@app.route('/')
def hello_ekipa():

    headers = {  
    "Metadata-Flavor": "Google",
    }
    region = requests.get(url, headers=headers)
    return region
    


if __name__ == "__main__":
    app.run(debug=True)