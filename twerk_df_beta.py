#dependencies:
#pip install pandas==1.3.0rc1
#pip install json2xml
#pip install lxml
#pip install xml.sax.saxutils
#pip install requests
#pip install json
#pip install jsonlines
#pip install json2xml
#pip install sax
#pip install pandas==1.3.0rc1


import requests
import json
from json2xml import json2xml
from json2xml.utils import readfromjson,readfromstring
import pandas as pd
import lxml
import lxml.etree as ET
from pandas.core.frame import DataFrame

def get (json, xsl):
  xml_data=json2xml.Json2xml(json).to_xml()
  parser = ET.HTMLParser(recover=True)
  dom = ET.fromstring(xml_data, parser)
  xslt = ET.parse(xsl)
  transform = ET.XSLT(xslt)
  newdom = transform(dom)
  et=ET.tostring(newdom, pretty_print=True)
  df=pd.read_xml(et, xpath=".//line",names=column_name_list)
  return df

def save_request(page, next_token,counter,df0):
    print('loading page: '+str(counter))
    templatefile="template.xsl"  
    req = requests.get(page+next_token, headers=headers) 
    req1 = req.json()
    #uncomment the next 3 lines to get preprocessed results
    #filename='raw_results'+str(counter)+'.json'  
    #with open(filename, 'w') as json_file:           
            #json.dump(req1, json_file)     
    try:
        n_token = req1['meta']['next_token']
    except:
        n_token = None
    df1 = get(req1, templatefile) 
    frames = [df0, df1]
    df = pd.concat(frames, ignore_index = True)
    if (n_token and (a=='' or (counter < int(a)))):                       
        df = save_request(page, '&next_token='+n_token, counter+1, df)
            
    return df

#insert your bearer token in the credentials.json file
with open('credentials.json') as f:
        data = json.load(f)
        token=data["Bearer Token"]


#main part
upit=str(input('Type search term here: ')+' ')
username=str(input('Type Twitter username to search or just press enter for none: '))
a=input("Type limit case number, or just press enter for no limit: ")

if len(username) == 0:
    page='https://api.twitter.com/2/tweets/search/recent?query='+upit+'&tweet.fields=conversation_id,id,author_id,created_at,in_reply_to_user_id,referenced_tweets,lang,public_metrics,geo&expansions=attachments.media_keys&media.fields=public_metrics,preview_image_url,url&max_results=100'
elif len(username) > 1:
    page='https://api.twitter.com/2/tweets/search/recent?query='+upit+'from:'+username+'&tweet.fields=conversation_id,id,author_id,in_reply_to_user_id,created_at,referenced_tweets,lang,public_metrics,geo&expansions=attachments.media_keys&media.fields=public_metrics,preview_image_url,url&max_results=100'

headers = {'Authorization': 'Bearer '+token}

column_name_list=['text','url','user_mentions','hashtags','conversation_id','id','in_reply_to_user_id','author_id','created_at','retweet_count','reply_count','like_count','quote_count','geo','lang','referenced_tweets']

#get dataframe        
mdf = save_request(page,'',0, None)
print('Success')
print(mdf)

#save results
mdf.to_csv('result.csv', encoding='utf-8')
result = mdf.to_json()
with open('result.json', 'w') as f:
    json.dump(result, f)
