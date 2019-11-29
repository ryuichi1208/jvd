#!/usr/local/bin/python3
# -*- coding: utf-8 -*-

import datetime
import json
import os
import random
import requests
import sys
import typing
import urllib.request

from subprocess import check_output
from flask import Flask, jsonify, Response, render_template, request, abort
from flask_httpauth import HTTPBasicAuth, HTTPDigestAuth

from linebot import LineBotApi, WebhookHandler
from linebot.exceptions import InvalidSignatureError
from linebot.models import MessageEvent, TextMessage, TextSendMessage

app = Flask(__name__)
app.config["JSON_AS_ASCII"] = False
app.config["SECRET_KEY"] = str(random.randint(10, 100))

def test_func():
    return 0

def exec_api(url: str, header: typing.Union[dict, None]):
    try:
        data = requests.get(url, headers=header).json()
    except Exception:
        data = {}
    return data


@app.route("/")
def get_vim_tag(latest_flg=False):
    url = "https://api.github.com/repos/vim/vim/tags"
    header = {"Accept": "application/vnd.github.v3+json"}
    result = ""

    for tag in exec_api(url, header):
        result += tag["name"] + "\n"
        if latest_flg:
            url_latest = f"{url}/releases/{tag['name']}"
            return exec_api(url_latest, header)
    else:
        return result


if __name__ == "__main__":
    host = str(os.environ.get("FLASK_HOST", "0.0.0.0"))
    port = int(os.environ.get("FLASK_PORT", 5000))
    debug = bool(os.environ.get("FLASL_DEBUG_MODE", True))

    app.run(host=host, port=port, debug=debug)
