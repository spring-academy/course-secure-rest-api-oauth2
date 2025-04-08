In the next few steps, you'll be taking a look at the Spring Security logs to verify functionality, so first, you'll need to tell Spring Boot to show you more logging information for Spring Security.

1. Update the logging level.

   Turn on more verbose logging for Spring security by adding the following to your `application.yml` file

   ```editor:open-file
   file: ~/exercises/src/main/resources/application.yml
   ```

   ```yaml
   logging:
     level:
       org.springframework.security: TRACE
   ```

1. Start the application.

   In one of the Terminal panes, run the application:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```bash
   [~/exercises] $ ./gradlew bootRun
   ```

   In the logs, note that a default user is _no longer being created_ and a password is _no longer being generated_. Meaning, **you should _not_ see anything like the following**:

   ```bash
   Using generated security password: 9ce7162c-51ca-478d-8025-5e7ba7a31afc

   This generated password is for development use only. Your security configuration must be updated before running your application in production.
   ```

1. Verify the authentication method.

   Using the other Terminal pane, verify that Bearer Authentication is activated by trying to request the `/cashcards` endpoint like so:

   ```bash
   [~/exercises] http :8080/cashcards
   ```

   We expect this request to fail with a `401` error at this point, but the response contains some very interesting information.

   Notice the value of the `WWW-Authenticate` header. It should look like this:

   ```bash
   WWW-Authenticate: Bearer
   ```

   Remember that when you had the REST API configured for HTTP Basic, this would have responded with `WWW-Authenticate: Basic` as a header. This new value indicates to clients that your REST API is expecting a bearer token instead.

   **_Note:_** There isn't a `WWW-Authenticate` scheme to indicate that your REST API specifically understands JWTs. We'll handle JWTs in the code.

We've updated the authentication scheme, but all of our requests fail due to being unauthenticated. Let's fix that next.
