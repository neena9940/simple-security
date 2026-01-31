from flask import Flask, jsonify
import logging

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"service": "analyzer", "status": "running"})



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5007)