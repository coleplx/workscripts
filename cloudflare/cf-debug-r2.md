Cloudflare-hosted domain: vanilla-kinsta.aliancaproject.com
CNAME target: vanillabasic-5o3mm.hosting.kinsta.page

**1. Gray-clouded (DNS only) - OK**
Request:
```
root@ads:/etc/nginx/conf.d# curl -sILX GET https://vanilla-kinsta.aliancaproject.com/index.html
HTTP/2 200 
(...)
cf-ray: 80b3a52a2c700788-IAD
cf-cache-status: DYNAMIC
cache-tag: 08c71164-7c2e-4c9e-98f0-ca72d0d309f4
ki-edge: v=2.1.2;mv=2.2.3
```

Instant Logs:
```
200: OK - Workers Subrequest
GET https://r2-static-xxxxxxxxxxxxxxxxxxxxxxxx.kinsta.page/vanillabasic-5o3mm/index.html
"ClientRequestHost": "r2-static-xxxxxxxxxxxxxxxxxxxxxxxx.kinsta.page",
"ClientRequestPath": "/vanillabasic-5o3mm/index.html",
"ClientRequestProtocol": "HTTP/1.1",
"ClientRequestScheme": "https",
"ClientRequestSource": "edgeWorkerFetch",
"ClientRequestURI": "/vanillabasic-5o3mm/index.html?ki-deployid=5958ed55-5a0f-4785-8d6a-f31d22b738cc",
"ClientRequestUserAgent": "curl/7.81.0",
"ClientSSLCipher": "NONE",
"ClientSSLProtocol": "none",
"EdgeCFConnectingO2O": false,
"EdgeColoCode": "IAD",
"ParentRayID": "80b3a52a2c700788",
"RayID": "80b3a52b853d0788",
```


**2. Orange-clouded (Proxied)**
Request:
```
root@ads:/etc/nginx/conf.d# curl -sILX GET https://vanilla-kinsta.aliancaproject.com/index.html
HTTP/2 500 
(...)
cf-ray: 80b3b0b88b128266-IAD
cf-cache-status: DYNAMIC
ki-edge: v=2.1.2;mv=2.2.3
cf-apo-via: origin,host (???? why?)
ki-edge-o2o: yes
```

Instant Logs:
```
403: Forbidden
GET https://r2-static-xxxxxxxxxxxxxxxxxxxxxxxx.kinsta.page/vanillabasic-5o3mm/index.html
"ClientRequestHost": "r2-static-xxxxxxxxxxxxxxxxxxxxxxxx.kinsta.page",
"ClientRequestPath": "/vanillabasic-5o3mm/index.html",
"ClientRequestProtocol": "HTTP/1.1",
"ClientRequestScheme": "https",
"ClientRequestSource": "edgeWorkerFetch",
"ClientRequestURI": "/vanillabasic-5o3mm/index.html?ki-deployid=5958ed55-5a0f-4785-8d6a-f31d22b738cc",
"ClientRequestUserAgent": "curl/7.81.0",
"ClientSSLCipher": "NONE",
"ClientSSLProtocol": "none",
"EdgeCFConnectingO2O": true,
"EdgeColoCode": "IAD",
"EdgeResponseStatus": 403,
"ParentRayID": "80b3b0b8a3b38266",
"RayID": "80b3b0b9d73f82ab",
```
