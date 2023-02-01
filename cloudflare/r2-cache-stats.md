**Bucket:** bucket-example1.kinsta.page
**Bucket region:** Probably SA ~ Brazil

Requests were executed one after the other, never at the same time.
I never purged the cache after each test.

DCs tested: LHR, IAD, ORD, EWR, SEA, GRU, OSL, DME, HEL, TLV

Awesome cache hit ratio performance: OSL, DME, HEL, TLV
Good performance: SEA
"Bad" performance: GRU, EWR, LHR, IAD, ORD


**1 - Brazil (GRU)**
5 MISS/EXPIRED in 20 requests
```
[coleplx@fedora cloudflare_worker_page]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: EXPIRED
CF-RAY: 792b1b55b89051b3-GRU
cf-cache-status: HIT
cf-ray: 792b1b5f890751fe-GRU
CF-Cache-Status: EXPIRED
CF-RAY: 792b1b66ca6ca5f8-GRU
CF-Cache-Status: EXPIRED
CF-RAY: 792b1b703f2a02ea-GRU
CF-Cache-Status: EXPIRED
CF-RAY: 792b1b796e43a673-GRU
CF-Cache-Status: EXPIRED
CF-RAY: 792b1b845b5b1b17-GRU
CF-Cache-Status: HIT
```
(...) Following requests all returned HIT

**2 - Norway**
1 MISS in 20 requests
```
root@centos:~# for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b1ce3582c0b61-OSL
CF-Cache-Status: HIT
CF-RAY: 792b1cedbc3ab52d-OSL
```
(...) Following requests all returned HIT

**3 - Germany**
2 MISS in 20 requests (2 DCs served the request)
```
[cole@centos-2gb-hel1-1 .ssh]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b28eb7a709d84-DME
CF-Cache-Status: MISS
CF-RAY: 792b28f9789dd912-HEL
CF-Cache-Status: HIT
CF-RAY: 792b2904d9d1d96f-HEL
CF-Cache-Status: HIT
```

**4 - Israel**
1 MISS in 20 requests
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b2d2f7939e3e7-TLV
CF-Cache-Status: HIT
CF-RAY: 792b2d43c9c4e3cf-TLV
```

**5 - TOP DCS**
**EWR**
4 MISS in 20 requests
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b539199238c81-EWR
CF-Cache-Status: MISS
CF-RAY: 792b539ccf13c328-EWR
CF-Cache-Status: HIT
CF-RAY: 792b53a87dbbc32a-EWR
CF-Cache-Status: HIT
CF-RAY: 792b53b279508c93-EWR
CF-Cache-Status: HIT
CF-RAY: 792b53bc6e728c1b-EWR
CF-Cache-Status: MISS
CF-RAY: 792b53c70f4f9e05-EWR
CF-Cache-Status: HIT
CF-RAY: 792b53d19b248c0f-EWR
CF-Cache-Status: HIT
CF-RAY: 792b53dbdd4d8cbd-EWR
CF-Cache-Status: HIT
CF-RAY: 792b53e62b3d19df-EWR
CF-Cache-Status: HIT
CF-RAY: 792b53f02a8678d5-EWR
CF-Cache-Status: MISS
CF-RAY: 792b53fa6ea31778-EWR
```

**LHR**
5 MISS/EXPIRED in 20 requests
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b5b9a9ffc7708-LHR
CF-Cache-Status: MISS
CF-RAY: 792b5ba92b5471f3-LHR
CF-Cache-Status: MISS
CF-RAY: 792b5bb61f2df40b-LHR
CF-Cache-Status: MISS
CF-RAY: 792b5bc46a052508-LHR
CF-Cache-Status: HIT
CF-RAY: 792b5bd2cc4771c2-LHR
CF-Cache-Status: HIT
CF-RAY: 792b5bde1f25769d-LHR
CF-Cache-Status: HIT
CF-RAY: 792b5be97ffb770e-LHR
CF-Cache-Status: MISS
CF-RAY: 792b5bf4ea117501-LHR
CF-Cache-Status: MISS
CF-RAY: 792b5c02fd37dcd7-LHR
CF-Cache-Status: HIT
```

**IAD**
7 MISS/EXPIRED in 20 requests
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b68d6b8f18250-IAD
CF-Cache-Status: MISS
CF-RAY: 792b68e1fdad05de-IAD
CF-Cache-Status: MISS
CF-RAY: 792b68ecdc5e5776-IAD
CF-Cache-Status: HIT
CF-RAY: 792b68f82dd37fb7-IAD
CF-Cache-Status: MISS
CF-RAY: 792b69025f58173c-IAD
CF-Cache-Status: HIT
CF-RAY: 792b69140fc28244-IAD
CF-Cache-Status: MISS
CF-RAY: 792b691e7ee13985-IAD
CF-Cache-Status: HIT
CF-RAY: 792b69298fc882cc-IAD
CF-Cache-Status: MISS
CF-RAY: 792b6933ace1208a-IAD
CF-Cache-Status: HIT
CF-RAY: 792b693ecf8b823c-IAD
CF-Cache-Status: MISS
CF-RAY: 792b69492a270573-IAD
CF-Cache-Status: HIT
CF-RAY: 792b69549e1b05b6-IAD
CF-Cache-Status: HIT
CF-RAY: 792b695eca3c3894-IAD
CF-Cache-Status: HIT
CF-RAY: 792b69691d1482da-IAD
CF-Cache-Status: HIT
CF-RAY: 792b69737921801d-IAD
CF-Cache-Status: MISS
CF-RAY: 792b697dfb1c1773-IAD
CF-Cache-Status: HIT
CF-RAY: 792b6989a90c2430-IAD
```

**ORD**
5 MISS/EXPIRED in 20 requests
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b6b6d487c22d5-ORD
CF-Cache-Status: MISS
CF-RAY: 792b6b78bb8261d4-ORD
CF-Cache-Status: MISS
CF-RAY: 792b6b8458e0e26b-ORD
CF-Cache-Status: MISS
CF-RAY: 792b6b8fcb642d0d-ORD
CF-Cache-Status: MISS
CF-RAY: 792b6b9b6e2f2a45-ORD
CF-Cache-Status: HIT
```

**SEA**
2 MISS/EXPIRED in 20 requests
```
[coleplx@fedora cloudflare]$ for i in {1..20}; do curl -sILX GET https://bucket-example1.kinsta.page/demo-application-b44zl/image.jpg | grep -Ei '^cf-cache-status|cf-ray'; sleep 1; done
CF-Cache-Status: MISS
CF-RAY: 792b71e9cf41c392-SEA
CF-Cache-Status: MISS
CF-RAY: 792b71f80f802760-SEA
CF-Cache-Status: HIT
CF-RAY: 792b72064edeeb63-SEA
```