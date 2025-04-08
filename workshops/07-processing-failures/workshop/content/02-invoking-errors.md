Let's start our API and make requests using our invalid token to learn what happens.

1. Start the application.

   Just as we've done many times in previous labs, let's start the app with the `bootRun` command in one of the Terminal panes:

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

1. Invoke an authorization failure.

   Okay, now we're ready to break some stuff!

   Use the other Terminal pane to request the `/cashcards` endpoint with the invalid JWT as follows:

   ```shell
   [~/exercises] $ http :8080/cashcards "Authorization: Bearer $INVALID_TOKEN"
   ```

   You should see an error that looks something like this:

   ```shell
   HTTP/1.1 401
   ...
   WWW-Authenticate: Bearer error="invalid_token", error_description="An error occurred while attempting to decode the Jwt: Jwt expired at 2023-01-01T07:00:00Z", error_uri="https://tools.ietf.org/html/rfc6750#section-3.1"
   ```

   Boom! That broke.

   While you're at it, take a look at the stack trace in the `bootRun` Terminal pane:

   ```shell
   ...
   org.springframework.security.oauth2.server.resource.InvalidBearerTokenException: An error occurred while attempting to decode the Jwt: Jwt expired at 2023-01-01T07:00:00Z
   ...
   Caused by: org.springframework.security.oauth2.jwt.JwtValidationException: An error occurred while attempting to decode the Jwt: Jwt expired at 2023-01-01T07:00:00Z
   ...
   ```

Notice what's there... and what's _not_ there.

The error tells us that the token is expired, but _not_ that the audience is invalid.

Why not have both?
