You'll notice that now we have three Terminal panes.

```dashboard:open-dashboard
name: Terminal
```

This is because we'll be running several things at once:

1. An Authorization Server
1. Our Family Cash Card API
1. `http` requests to issue a JWT
1. `http` requests to fetch Cash Cards from our API _with_ that newly-minted JWT

As we noted, our application will validate against an actual running Authorization Server.

But what happens if there isn't an Authorization Server running?

1. Start the API with no Authorization Server running.

   We require an Authorization Server running on port `9000` for our API to validate incoming JWTs.

   Let's see what happens when we start our API _without_ the Authorization Server running:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ...
   > IDLE
   > :bootRun
   ```

   Looks like nothing out of the ordinary happened!

   Let's try to fetch Cash Cards and see what happens.

1. Make request without the Authorization Server running.

   Our application started just fine.

   What happens when we try to request Cash Cards from our API using our favorite technique of submitting a pre-generated JWT?

   Let's give it a try with the `LOCAL_TOKEN` we've provided:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ http -A bearer -a $LOCAL_TOKEN :8080/cashcards

   HTTP/1.1 401
   ...
   ```

   Looks like we're getting a `401` error.

   Take a look at the Terminal pane running our application with `bootRun`.

   That's a big stack trace!

   If you scroll through, you'll find quite a few errors about the Authentication Server not running on `localhost:9000`, finally resulting in an `Access Denied` error.

   ```shell
   org.springframework.security.oauth2.jwt.JwtDecoderInitializationException: Failed to lazily resolve the supplied JwtDecoder instance
     ...
     Caused by: java.lang.IllegalArgumentException: Unable to resolve the Configuration with the provided Issuer of "http://localhost:9000"
     ...
     Caused by: org.springframework.web.client.ResourceAccessException: I/O error on GET request for "http://localhost:9000/.well-known/openid-configuration": Connection refused
     ...
     Caused by: java.net.ConnectException: Connection refused
     ...
   org.springframework.security.access.AccessDeniedException: Access Denied
   ...
   ```

   In particular, take a look at this error:

   ```shell
   Failed to lazily resolve the supplied JwtDecoder instance
   ```

   _"lazily resolve"_ means that Spring Security attempted to use the Authentication Server when needed -- that is, _lazily_, -- which was when we made our request to `/cashcards`

Looks like we need our Authorization Server running after all!
