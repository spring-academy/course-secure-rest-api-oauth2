Let's see how this all looks when making requests against our API.

1. Start or restart the app.

   In one of the Terminal panes, start (or restart) the application.

   You can stop any currently running application by typing `CTRL+C` in that pane.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ...
   <==========---> 80% EXECUTING [1m 15s]
   > IDLE
   > :bootRun
   ```

1. Make the invalid request.

   We've done this before!

   In the unused Terminal pane, use our `INVALID_TOKEN` to trigger errors from our API.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ http :8080/cashcards "Authorization: Bearer $INVALID_TOKEN"
   HTTP/1.1 401
   WWW-Authenticate: Bearer error="invalid_token", error_description="An error occurred while attempting to decode the Jwt: Jwt expired at 2023-01-01T07:00:00Z", error_uri="https://tools.ietf.org/html/rfc6750#section-3.1"

   {"type":"https://tools.ietf.org/html/rfc6750#section-3.1","title":"An error occurred while attempting to decode the Jwt: Jwt expired at 2023-01-01T07:00:00Z","status":401,"errors":[{"errorCode":"invalid_token","description":"Jwt expired at 2023-01-01T07:00:00Z","uri":"https://tools.ietf.org/html/rfc6750#section-3.1"},{"errorCode":"invalid_token","description":"The aud claim is not valid","uri":"https://tools.ietf.org/html/rfc6750#section-3.1"}]}
   ```

   Nice! We can see all of the errors returned

   **Tip:** Pipe the request to `jq` to have the response JSON beautifully formatted:

   ```shell
   [~/exercises] $ http :8080/cashcards "Authorization: Bearer $INVALID_TOKEN" | jq
   {
     "type": "https://tools.ietf.org/html/rfc6750#section-3.1",
     "title": "Invalid Token",
     "status": 401,
     "errors": [
       {
         "errorCode": "invalid_token",
         "description": "Jwt expired at 2023-01-01T07:00:00Z",
         "uri": "https://tools.ietf.org/html/rfc6750#section-3.1"
       },
       {
         "errorCode": "invalid_token",
         "description": "The aud claim is not valid",
         "uri": "https://tools.ietf.org/html/rfc6750#section-3.1"
       }
     ]
   }
   ```

Congratulations! You successfully enhanced the way Spring Security is reporting errors!
