from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"service": "log-collector", "status": "running"})

@app.route('/collect', methods=['POST'])
def collect_log():
    return jsonify({"message": "Log collected"}), 201

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5006))
    app.run(host='0.0.0.0', port=port)