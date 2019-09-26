import hashlib
import sys
from math import ceil
import httplib


def access(r):
        url = str(r.var['request_uri'])[1:]
        uri = ""
        for i in url.split('?')[0].split('/')[3:]:
                uri += "/{}".format(i)

        conn = httplib.HTTPConnection("127.0.0.1", 9898)
        conn.request('GET', url)
        resp = conn.getresponse()
        content = [item for item in resp.getheaders() if item[0] == 'content-length']

        total_size = int(content[0][1])
        byte_range = 10485760
        slices = int(ceil(total_size/byte_range))

        command = ""
        for i in range(0,slices):
                final_part = slices-1
                if(i == final_part):
                        byte_range_request = "bytes={}-{}".format(i*byte_range, (total_size-1))
                        cache_key = (uri+byte_range_request).encode("utf-8")
                        cache_key = hashlib.md5(cache_key).hexdigest()
                        command += "rm -f {}/{}/{}".format(cache_key[-1], cache_key[-3]+cache_key[-2], cache_key)
                else:   
                        byte_range_request = "bytes={}-{}".format(i*byte_range, ((i+1)*byte_range)-1)
                        cache_key = (uri+byte_range_request).encode("utf-8")
                        cache_key = hashlib.md5(cache_key).hexdigest()
                        command += "rm -f {}/{}/{}\n".format(cache_key[-1], cache_key[-3]+cache_key[-2], cache_key)

        with open("teste2.txt", "w") as f:
                f.write(str(command))
