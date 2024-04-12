# CSYE7125 - Advanced Cloud Computing
## webapp
Simple stateless web application that performs the following actions:
## Endpoint URL
```javascript
// 1. Route to check if the server is healthy
GET /healthz
```
``
Returns 200 OK - Server is up and healthy
``
##
```javascript
// 2. GET route to retrieve specific http-check details
GET /v1/http-check/{id}
```
``
Returns 200 OK
``
``
Returns 404 Not Found
``
##
```javascript
// 3. GET route to retrieve all the http-checks
GET /v1/http-check
```
``
Returns 200 OK
``
##
```javascript
// 4. POST route to create a new http-check
POST /v1/http-check
```
``
Returns 201 Created
``
``
Returns 400 Bad Request
``
##
```javascript
// 5. PUT route to update a http-check
PUT /v1/http-check/{id}
```
``
Returns 204 No Content
``
``
Returns 400 Bad Request
``
##
```javascript
// 6. DELETE route to delete a http-check
DELETE /v1/http-check/{id}
```
``
Returns 204 No Content
``
``
Returns 404 Not Found
``
### Sample JSON Request for POST and PUT calls
```json
{
  "name": "string",
  "uri": "string",
  "is_paused": true,
  "num_retries": 5,
  "uptime_sla": 100,
  "response_time_sla": 100,
  "use_ssl": true,
  "response_status_code": 0,
  "check_interval_in_seconds": 86400
}
```

### Sample JSON Response for POST calls
```json
{
  "id": "d290f1ee-6c54-4b01-90e6-d701748f0851",
  "name": "string",
  "uri": "string",
  "is_paused": true,
  "num_retries": 5,
  "uptime_sla": 100,
  "response_time_sla": 100,
  "use_ssl": true,
  "response_status_code": 0,
  "check_interval_in_seconds": 86400,
  "check_created": "2016-08-29T09:12:33.001Z",
  "check_updated": "2016-08-29T09:12:33.001Z"
}
```