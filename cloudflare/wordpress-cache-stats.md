**Site:** iowatest.kinsta.cloud
**Site region:** Iowa - uscentral

Requests were executed one after the other, never at the same time.
Smart Tiered Caching Topology is enabled.
I never purged the cache after each test.

We are using Fetch and Cache API at the same time.
We first cache the asset using Fetch and a lower TTL (600s), and then we cache it locally with Cache API.
If there is a `cache.match` in the Cache API, we return it immediately and eventually the asset cached by Fetch expires.
To better understand where the asset is coming from, we will check two headers: `cf-cache-status` and `ki-cache-api`.

DCs tested: LHR, IAD, ORD, EWR, SEA, GRU, OSL, DME, HEL, TLV

**1 - Brazil**  
Fetch: 1 MISS in 20 requests  
Cache API: 4 MISS in 20 requests  
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://iowatest.kinsta.cloud/wp-content/uploads/2022/12/41043f36-83b4-33e8-a9cd-99e16c9aa250.jpg | grep -Ei '^cf-cache-status|cf-ray|ki-cache-api'; sleep 1; done
cf-ray: 792b7ecaf99ba68e-GRU
cf-cache-status: MISS
ki-cache-api: MISS
cf-ray: 792b7ed78bb01a90-GRU
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792b7ee36f6da496-GRU
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792b7eed3bb5a4b6-GRU
cf-cache-status: HIT
ki-cache-api: HIT
cf-ray: 792b7ef4ac5d0135-GRU
cf-cache-status: HIT
ki-cache-api: MISS
```

**2 - Norway**  
Fetch: Always HIT  
Cache API: 1 MISS in 20 requests  
```
root@centos:~# for i in {1..20}; do curl -sILX GET https://iowatest.kinsta.cloud/wp-content/uploads/2022/12/41043f36-83b4-33e8-a9cd-99e16c9aa250.jpg | grep -Ei '^cf-cache-status|cf-ray|ki-cache-api'; sleep 1; done
cf-ray: 792b88123f8fb500-OSL
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792b881d5e86b50b-OSL
cf-cache-status: HIT
ki-cache-api: HIT
```

**3 - Germany**  
Fetch: Always HIT  
Cache API: 2 MISS in 20 requests (2 datacenters)  
```
[cole@centos-2gb-hel1-1 .ssh]$ for i in {1..20}; do curl -sILX GET https://iowatest.kinsta.cloud/wp-content/uploads/2022/12/41043f36-83b4-33e8-a9cd-99e16c9aa250.jpg | grep -Ei '^cf-cache-status|cf-ray|ki-cache-api'; sleep 1; done
CF-Ray: 792b8a8f595f005f-DME
CF-Cache-Status: HIT
ki-cache-api: MISS
CF-Ray: 792b8a9b9ed63769-HEL
CF-Cache-Status: HIT
ki-cache-api: MISS
CF-Ray: 792b8aa7fe2d3a95-DME
CF-Cache-Status: HIT
ki-cache-api: HIT
```

**4 - Israel**  
Fetch: Always HIT  
Cache API: 1 MISS in 20 requests  
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://iowatest.kinsta.cloud/wp-content/uploads/2022/12/41043f36-83b4-33e8-a9cd-99e16c9aa250.jpg | grep -Ei '^cf-cache-status|cf-ray|ki-cache-api'; sleep 1; done
cf-ray: 792b8c2dedafe3df-TLV
cf-cache-status: HIT
ki-cache-api: MISS
cf-ray: 792b8c400c4fe3ed-TLV
cf-cache-status: HIT
ki-cache-api: HIT
```

LHR, IAD, ORD, EWR, SEA all had similar results.  
Fetch always returned HIT, even for the first request, thanks to Smart Tiered Topology  
Cache API had the same hit ratio as orange-clouded R2.  