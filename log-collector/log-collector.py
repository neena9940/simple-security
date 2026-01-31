from flask import Flask, jsonify
import logging

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"service": "log-collector", "status": "running"})

@app.route('/collect', methods=['POST'])
def collect_log():
    return jsonify({"message": "Log collected"}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5006)