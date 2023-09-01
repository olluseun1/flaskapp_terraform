import json
import requests
from flask import Flask, Response


app = Flask(__name__)

@app.route('/hello', methods=['GET'])
def hello():
    return Response("{hello world}", mimetype='application/json')
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int("3000"), debug=True)
