We'll need to do the following in order to successfully make API requests to our application:

1. Start our API
1. Start our Authorization Server
1. Request a JWT from our Authorization Server
1. Use that newly minted JWT as the `bearer` token in our requests

We've already started our API. Now let's start Authorization Server, which we've provided for you as a Docker image.

1. Start the Authorization Server Docker image.

   In an unused Terminal pane, fetch and run the Docker image that contains our Authorization Server.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ docker run --rm --name sso -p 9000:9000 ghcr.io/spring-academy/course-secure-rest-api-oauth2-code/sso:latest
   ```

   Take a look at the output.

   You'll see that the command fetches and starts the Docker image, but then what?

   ```
   Unable to find image 'ghcr.io/spring-academy/course-secure-rest-api-oauth2-code/sso:latest' locally
   latest: Pulling from spring-academy/course-secure-rest-api-oauth2-code/sso
   43f89b94cd7d: Pulling fs layer
   767d15f3fb93: Pull complete
   ...
        .   ____          _            __ _ _
    /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
   ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
    \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
     '  |____| .__|_| |_|_| |_\__, | / / / /
    =========|_|==============|___/=/_/_/_/
    :: Spring Boot ::                (v3.1.3)

   2023-11-07T15:51:06.443Z  INFO 1 --- [           main] com.example.sso.SsoApplication           : Starting SsoApplication v0.0.1-SNAPSHOT using Java 17.0.9 with PID 1 (/application/BOOT-INF/classes started by root in /application)
   ...
   2023-11-07T15:51:07.713Z  INFO 1 --- [           main] com.example.sso.SsoApplication           : Started SsoApplication in 1.571 seconds (process running for 1.798)
   ```

   Look at that, it's a Spring Boot application, too!

   It's true: We've written our own Authorization Server using Spring Boot.

   Now let's use it.

1. Review the token-request parameters.

   We'll request a JWT from the Authorization Server using `http` and will need to send several important parameters needed to mint a valid JWT.

   Take a look at the sample request below. Don't run it -- it'll fail badly.

   ```shell
   http -a <client_id>:<client_secret> --form <auth_server_endpoint> grant_type=<the_grant_type> scope=<scopes>
   ```

   What are all of those parameters for?

   - **`client_id`**: This is a public identifier for the client application. It's used by the authorization server to verify the identity of the client application and determine whether it's authorized to access protected resources. We will use a value of **_`cashcard-client`_**.
   - **`client_secret`**: This is a private value that is known only to the client application and the authorization server. It's used to verify the authenticity of the client application and to ensure that it's authorized to request access to protected resources. We'll use a value of **_`secret`_**.
   - **`auth_server_endpoint`**: The Authorization Server endpoint to retrieve the token. We'll use **_`:9000/oauth2/token`_**.
   - **`grant_type`**: This is a parameter in OAuth 2.0 to specify the type of authorization request being made. This grant type is used by client apps to obtain an access token without requiring any user interaction. We'll use use **_`client_credentials`_**.
   - **`scope`**: The scopes we've defined and used earlier in this course. We'll use **_`cashcard:read`_**.

   Now that we have that bit of context we can run the following command to mint a valid JWT.

1. Request a token.

   Let's fill in our required parameters and request a token:

   ```shell
   [~/exercises] $ http -a cashcard-client:secret --form :9000/oauth2/token grant_type=client_credentials scope=cashcard:read

   HTTP/1.1 200
   ...
   {
       "access_token": "eyJraWQiOiJhOEJVNk9uQW1kNkRNQnI4OXliZGJ2VGJOVHVjYmNlcEFNOWhsZzB0ekRJIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJzYXJhaDEiLCJhdWQiOiJjYXNoY2FyZC1jbGllbnQiLCJuYmYiOjE2OTkzMTIxODUsInNjb3BlIjpbImNhc2hjYXJkOnJlYWQiXSwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo5MDAwIiwiZXhwIjoxNjk5MzEyNDg1LCJpYXQiOjE2OTkzMTIxODV9.BKNRmZdDYhd0umVURrvYFZG16BoEe0qZdv-JoOrxqCjbIAMjcKYKhAaF560IG2OHzp8BYCnz0Zh_rZNqu6m4Hf3CjArToOI2tq_lWpqaeN1V49ZHMLoVnxnLtu3GOAYQymz9dImNcaJa6ijpC-qDtGd0uxrrQCAFl1fnoTUir6mCQY4lcDOZ9Ly2mLB-3iMsataRwfRWWoYGVXXDeYhBmw6PzNSbxdbZOBc6sy0YW3YZC9c8w-HQLFS4Ry2oODxmOUJr_-fXMCpqW0dtWE7hwnwyYWTod4uq74jKMhYeKAYH-xrj9sYJJOmZXVcAmdGKjmkZJbDoOdpkRNrxQn0nBA",
       "expires_in": 299,
       "scope": "cashcard:read",
       "token_type": "Bearer"
   }
   ```

   So what's in that token? Let's decode it and find out.

1. Decode the new token.

   Let's take a look at this JWT.

   Copy the value at `access_token:` and decode it. Remember that your token will be different, so be sure to copy it from your Terminal pane.

   ```shell
   [~/exercises] $ jwt decode eyJra...<snip>...n0nBA
   ...
   Token claims
   ------------
   {
     "aud": "cashcard-client",
     "exp": 1699312485,
     "iat": 1699312185,
     "iss": "http://localhost:9000",
     "nbf": 1699312185,
     "scope": [
       "cashcard:read"
     ],
     "sub": "sarah1"
   }
   ```

   That looks familiar! That's one valid looking token.

   We're going to use this token later, so for convenience, export it as `REQUESTED_TOKEN`. Again, be sure to copy the token from your Terminal pane.

   ```shell
   [~/exercises] $ export REQUESTED_TOKEN=eyJra...<snip>...n0nBA
   ```

   Now, let's use it!

1. Use the token in a request.

   Let's fetch those cash cards!

   We've done this many times before, just with a JWT minted differently.

   Be sure to use the `REQUESTED_TOKEN` you just requested and exported.

   ```shell
   [~/exercises] $ http -A bearer -a $REQUESTED_TOKEN :8080/cashcards

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

   And there they are! Our good friend `sarah1`'s two cash cards.

We did it! We've authenticated using a real Authentication Server.
