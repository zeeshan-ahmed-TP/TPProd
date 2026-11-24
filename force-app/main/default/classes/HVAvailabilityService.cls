@RestResource(urlMapping='/HVAvailabilityService/*')
global with sharing class HVAvailabilityService {
    
    @HttpGet
    global static AvailabilityResponseWrapper checkAvailability() {
        RestRequest req = RestContext.request;
        AvailabilityResponseWrapper response = new AvailabilityResponseWrapper();
		System.debug('Method called');
        System.debug('Params: ' + req.params);
        try {
            
            String areaCode = req.params.get('areaCode');
            String reqType = 'HV';
            String query = 'Name=' + EncodingUtil.urlEncode(areaCode, 'UTF-8')
                + '&Type=' + EncodingUtil.urlEncode(reqType, 'UTF-8');
			System.debug('Query: ' + query);
            HttpRequest httpReq = new HttpRequest();
            String endpoint = Label.ML_HV_URL + 'Services/ItemMaster/Search?' + query;
            System.debug('Endpoint: '+ endpoint);
            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('GET');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('x-ml-timestamp', Datetime.now().formatGMT('yyyyMMddHHmmss'));
            Blob inputBlob = Blob.valueOf('TopProducer ' + Label.HV_Access_Key + ' x-ml-timestamp:'+Datetime.now().formatGMT('yyyyMMddHHmmss'));
            Blob hashBlob = Crypto.generateDigest('MD5', inputBlob);
            
            // Convert to hexadecimal string
            String md5Hash = EncodingUtil.convertToHex(hashBlob);
            httpReq.setHeader('ml-auth','client=TopProducer&systemaccesskey=' + Label.HV_Access_Key + '&signature=' + md5Hash);
            httpReq.setTimeout(20000);

            Http http = new Http();
            HttpResponse httpResp = http.send(httpReq);

            if (httpResp.getStatusCode() == 200) {
                BackendResponse result = (BackendResponse) JSON.deserialize(
                    httpResp.getBody(), BackendResponse.class);

                response.success = true;

                if (result.Items != null && !result.Items.isEmpty()) {
                    // If more than one item can come back for a single product/area
                    // request, decide here how to pick one (first match, highest
                    // quantity, sum them, etc.) — using the first item for now.
                    BackendItem item = result.Items[0];

                    response.available         = item.Quantity != null && item.Quantity > 0;
                    response.availableQuantity = item.Quantity;
                    response.unitPrice         = item.Cost;
                    response.ItemId             = item.ItemId;
                    response.ItemName           = item.ItemName;
                    response.message            = response.available
                        ? 'Available' : 'Item returned with zero quantity';
                    response.ItemDescription = item.ItemDescription;
                    response.radius  = item.radius;
                } else {
                    response.available = false;
                    response.message   = 'No matching item returned for this product/area';
                }
            } else {
                response.success = false;
                response.message = 'Backend returned HTTP ' + httpResp.getStatusCode();
            }
        } catch (Exception e) {
            response.success = false;
            response.message = 'Availability check error: ' + e.getMessage();
        }

        return response;
    }

    global class AvailabilityRequestWrapper {
        public String lineId;
        public String reqType;
        public String areaCode;
        public Decimal requestedQuantity;
    }

    // Shape returned by the backend
    global class BackendResponse {
        public List<BackendItem> Items;
    }

    global class BackendItem {
        public Long ItemId;
        public String ItemName;
        public String ItemDescription;
        public String ItemType;
        public Decimal Quantity;
        public Decimal Cost;
        public long radius;
    }

    // Shape sent back to the QCP
    global class AvailabilityResponseWrapper {
        public Boolean success;
        public Boolean available;
        public Decimal availableQuantity;
        public String ItemDescription;
        public Decimal unitPrice;
        public Long ItemId;
        public String ItemName;
        public String message;
        public long radius;
    }
}