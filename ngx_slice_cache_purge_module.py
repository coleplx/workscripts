import hashlib
import sys
import os
from math import ceil
import httplib


cache_dir = "/var/nginx/cache"
byte_range = 10485760

def access(r):
        url = str(r.var['request_uri'])[1:]
        uri = ""
        # discard query string
        for i in url.split('?')[0].split('/')[3:]:
                uri += "/{}".format(i)
        # request the headers from the cache itself. its faster and easier.
        conn = httplib.HTTPConnection("127.0.0.1", 9898)
        conn.request('GET', url)
        resp = conn.getresponse()
        content = [item for item in resp.getheaders() if item[0] == 'content-length']

        total_size = int(content[0][1])
        slices = int(ceil(total_size/byte_range))

        command = ""
        for i in range(0,slices):
                final_part = slices-1
                if(i == final_part):
                        byte_range_request = "bytes={}-{}".format(i*byte_range, (total_size-1))
                        cache_key = (uri+byte_range_request).encode("utf-8")
                        cache_key = hashlib.md5(cache_key).hexdigest()
                        cache_file = "{}/{}/{}/{}".format(cache_dir,cache_key[-1], cache_key[-3]+cache_key[-2], cache_key)
                        exec_command = "rm -f {}".format(cache_file)
                        os.system(exec_command)
                else:   
                        byte_range_request = "bytes={}-{}".format(i*byte_range, ((i+1)*byte_range)-1)
                        cache_key = (uri+byte_range_request).encode("utf-8")
                        cache_key = hashlib.md5(cache_key).hexdigest()
                        cache_file = "{}/{}/{}/{}".format(cache_dir,cache_key[-1], cache_key[-3]+cache_key[-2], cache_key)
                        exec_command = "rm -f {}".format(cache_file)
                        os.system(exec_command)

