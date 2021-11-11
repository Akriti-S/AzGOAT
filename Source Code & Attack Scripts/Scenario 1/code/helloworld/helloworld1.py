from flask import Flask
from flask import request
app = Flask(__name__)

@app.route('/', methods=['GET'])
def test_ssrf():
	error=None
	if request.method=='GET':
		url = request.args.get('url','')
		if url:
			response= request.get(url)
			return(response.text)
		else:
			error="please enter url"
			return(error)

