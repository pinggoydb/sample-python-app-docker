import time

import redis
from flask import Flask, render_template, request, flash

app = Flask(__name__)
app.secret_key = "&uo+!8&luu7vq4k)w+wb8y2&8*9q#9(*(+d3c2)8p#0!6(yj+$"
# cache = redis.Redis(host='redis', port=6379)

# def get_hit_count():
#     retries = 5
#     while True:
#         try:
#             return cache.incr('hits')
#         except redis.exceptions.ConnectionError as exc:
#             if retries == 0:
#                 raise exc
#             retries -= 1
#             time.sleep(0.5)

# @app.route('/')
# def hello():
#     count = get_hit_count()
#     return f'<h1>Hello World! I have been seen {count} times.</h1>\n'

@app.route('/')
def index():
    flash("what's your name?")
    return render_template("index.html")

@app.route('/greet', methods=["POST", "GET"])
def greet():
    flash("Hi " +str(request.form['name_input']) + ", great to see you!")
    return render_template("index.html")