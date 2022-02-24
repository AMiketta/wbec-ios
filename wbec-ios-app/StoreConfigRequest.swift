//
//  StoreConfigRequest.swift
//  wbec
//
//  Created by Andreas Miketta on 24.02.22.
//

import Foundation


//POST /edit HTTP/1.1
//Host: wbec
//Content-Length: 339
//User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36
//Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryd20nGv9szhkCfOyl
//Accept: */*
//Origin: http://wbec
//Referer: http://wbec/edit
//Accept-Encoding: gzip, deflate
//Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7
//Connection: keep-alive
//
//------WebKitFormBoundaryd20nGv9szhkCfOyl
//Content-Disposition: form-data; name="data"; filename="cfg.json"
//Content-Type: text/json
//
//{"cfgApSsid":"wbec","cfgApPass":"wbec1234","cfgCntWb":1,"cfgMqttIp":"","cfgPvCycleTime":15,"cfgPvActive":1,"cfgMqttLp":[], "cfgSolarEdgeIp": "192.168.178.68"}
//------WebKitFormBoundaryd20nGv9szhkCfOyl--
