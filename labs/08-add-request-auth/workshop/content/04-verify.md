Now that we've done all this work to add scopes to our API, let's have some fun verifying our work by making real requests against our running application.

1. Start the application.

   In one of the Terminal windows, start the app:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ```

1. Inspect the `READ_ONLY_TOKEN`.

   Let's take a look at the contents of the `READ_ONLY_TOKEN` environment variable, which we've provided for you.

   In the unused Terminal pane, decode the `READ_ONLY_TOKEN`:

   ```shell
   [~/exercises] $ jwt decode $READ_ONLY_TOKEN

   Token header
   ------------
   {
     "typ": "JWT",
     "alg": "RS256"
   }

   Token claims
   ------------
   {
     "aud": "cashcard-client",
     "exp": 1697861925,
     "iat": 1697825925,
     "iss": "https://issuer.example.org",
     "scope": [
       "cashcard:read"
     ],
     "sub": "sarah1"
   }
   ```

   As you can see, this token has been granted `cashcard:read` scope only.

   Let's fetch some cash cards with that token!

1. Make a read-only request.

   Use the `READ_ONLY_TOKEN` in the following command to requests cash cards from our API:

   ```shell
   [~/exercises] $ http :8080/cashcards "Authorization: Bearer $READ_ONLY_TOKEN"
   HTTP/1.1 200
   ...
   [
       {
           "amount": 123.45,
           "id": 99,
           "owner": "sarah1"
       },
       {
           "amount": 1.0,
           "id": 100,
           "owner": "sarah1"
       }
   ]
   ```

   You're able to get user `sarah1` cash cards, but what happens if you want to _add_ another card?

1. Try to write with the read-only token.

   This probably won't end well...

   ```shell
   [~/exercises] $ http :8080/cashcards amount=55.10 "Authorization: Bearer $READ_ONLY_TOKEN"
   HTTP/1.1 403
   ...
   WWW-Authenticate: Bearer error="insufficient_scope", error_description="The request requires higher privileges than provided by the access token.", error_uri="https://tools.ietf.org/html/rfc6750#section-3.1"
   ```

   Sure enough, we got an `insufficient_scope` error and the `403` status code.

   Also, take a moment to look at the nasty stack-trace in the `bootRun` Terminal pane.

   ```shell
   ...
   2023-10-20T18:49:08.866Z TRACE 4874 --- [nio-8080-exec-3] o.s.s.w.a.ExceptionTranslationFilter     : Sending JwtAuthenticationToken [Principal=org.springframework.security.oauth2.jwt.Jwt@bd3c1568, Credentials=[PROTECTED], Authenticated=true, Details=WebAuthenticationDetails [RemoteIpAddress=0:0:0:0:0:0:0:1, SessionId=null], Granted Authorities=[SCOPE_cashcard:read]] to access denied handler since access is denied

   org.springframework.security.access.AccessDeniedException: Access Denied
        at org.springframework.security.web.access.intercept.AuthorizationFilter.doFilter(AuthorizationFilter.java:98) ~[spring-security-web-6.1.0.jar:6.1.0]
   ...
   ```

   There's certainly a lot of complaining about access being denied in that stack trace!

   I bet you wish we had a token that lets us _write_ to our API, right?

   Well, today's your lucky day, my friend!

1. Review the `READ_WRITE_TOKEN`.

   Check out the `READ_WRITE_TOKEN`:

   ```shell
   [~/exercises] $ jwt decode $READ_WRITE_TOKEN

   Token header
   ------------
   {
     "typ": "JWT",
     "alg": "RS256"
   }

   Token claims
   ------------
   {
     "aud": "cashcard-client",
     "exp": 1697861925,
     "iat": 1697825925,
     "iss": "https://issuer.example.org",
     "scope": [
       "cashcard:read",
       "cashcard:write"
     ],
     "sub": "sarah1"
   }
   ```

   Nice! This token has the `cashcard:read` and `cashcard:write` scopes. Let's use them.

1. Create a new cash card.

   Now you can try to add a new cash card and see the results:

   ```shell
   [~/exercises] $ http :8080/cashcards amount=55.10 "Authorization: Bearer $READ_WRITE_TOKEN"
   HTTP/1.1 201
   ...
   Location: http://localhost:8080/cashcards/1
   ...
   {
   "amount": 55.1,
   "id": 1,
   "owner": "sarah1"
   }
   ```

   You should be able to see the `201` status code and the `Location` header.

   It seems like it worked!

   Let's verify this with a `GET` using the same token:

   ```shell
   [~/exercises] $ http :8080/cashcards "Authorization: Bearer $READ_WRITE_TOKEN"
   HTTP/1.1 200
   ...
   [
       {
           "amount": 55.1,
           "id": 1,
           "owner": "sarah1"
       },
       {
           "amount": 123.45,
           "id": 99,
           "owner": "sarah1"
       },
       {
           "amount": 1.0,
           "id": 100,
           "owner": "sarah1"
       }
   ]
   ```

   And then there were three!

Good job! Our read and write scopes look like they're fully functional.
