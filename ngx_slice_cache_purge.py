#!/usr/bin/python3
# ngx_slice_cache_purge.py
# Purge all the slices from a cached file
# Assumes $slice = 10m (10485760 bytes)
import hashlib
import requests
import sys
from math import ceil

uri = "/uri/of/request/file/example.txt"
# real URL of file. needed to calculate total file size
url = "http://www.example.com{}".format(storage, uri)

total_size = requests.get(url,stream=True)
total_size = int(total_size.headers['Content-length'])
byte_range = 10485760

slices = ceil(total_size/byte_range)

for i in range(0,slices):.
    final_part = slices-1
    if(i == final_part):
        byte_range_request = "bytes={}-{}".format(i*byte_range, (total_size-1))
        cache_key = (uri+byte_range_request).encode("utf-8")
        cache_key = hashlib.md5(cache_key).hexdigest()
        print("rm -f {}/{}/{}".format(cache_key[-1], cache_key[-3]+cache_key[-2], cache_key))
    else:
        byte_range_request = "bytes={}-{}".format(i*byte_range, ((i+1)*byte_range)-1)
        cache_key = (uri+byte_range_request).encode("utf-8")
        cache_key = hashlib.md5(cache_key).hexdigest()
        print("rm -f {}/{}/{}".format(cache_key[-1], cache_key[-3]+cache_key[-2], cache_key))
