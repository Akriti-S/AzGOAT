from flask import Flask, render_template
from flask import request
#from requests import *
import requests
#import urllib3
app = Flask(__name__)

@app.route('/')
def ssrf():
	return render_template('ssrf.html')
@app.route('/test_ssrf',methods=['POST'])
def test_ssrf():
	error=None
	if request.method=='POST':
		url = request.form['url']
		if url:
			headers = {'Metadata': 'true'}
			resp = requests.get(url, headers=headers)
			return(resp.text)
		else:
			error="please enter url"
			return(error)

