# app.py
import datetime
from flask import Flask
import time

app = Flask(__name__)

print("Budget Tracker service started.")
print(f"Current time: {datetime.datetime.now()}")

while True:
    #Имитатор:D
    time.sleep(30)
