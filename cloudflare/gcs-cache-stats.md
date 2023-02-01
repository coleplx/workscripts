**Bucket:** gcstest.aliancaproject.com  
**Bucket region:** us-east1  

Requests were executed one after the other, never at the same time.  
I never purged the cache after each test.  

DCs tested: LHR, IAD, ORD, EWR, SEA, GRU, OSL, DME, HEL, TLV  

Awesome cache hit ratio performance: OSL, DME, HEL, TLV  
Good performance: SEA  
"Bad" performance: GRU, EWR, LHR, IAD, ORD  


**1 - Brazil (GRU)**  
Fetch: 1 MISS in 20 requests  
Cache API: 4 MISS in 20 requests  
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://gcstest.aliancaproject.com/image2.jpg  | grep -Ei '^cf-cache-status|cf-ray|ki-cache-api'; sleep 1; done
cf-ray: 792be4ba28faa640-GRU
cf-cache-status: EXPIRED
ki-cache-api: MISS
cf-ray: 792be4cc686700f6-GRU
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792be4dc0fee1aac-GRU
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792be4ec7a8002ec-GRU
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792be4f8bc001a9b-GRU
cf-cache-status: HIT
ki-cache-api: HIT
cf-ray: 792be5003c3ca4e3-GRU
cf-cache-status: HIT
ki-cache-api: HIT
```

**2 - Norway**  
Fetch: HIT on all requests.  
Cache API: 1 MISS in 20 requests  
```
root@centos:~# for i in {1..20}; do curl -sILX GET https://gcstest.aliancaproject.com/image2.jpg  | grep -Ei '^cf-cache-status|cf-ray|ki-cache-api'; sleep 1; done
cf-ray: 792be7869826fab4-OSL
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792be7922972b524-OSL
cf-cache-status: HIT
ki-cache-api: HIT
```
  
All other locations had the same requests, similar to wordpress-cache-stats.md