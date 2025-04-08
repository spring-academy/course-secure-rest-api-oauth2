Just like you did in the previous lab, try requesting the `/cashcards` endpoint in the Terminal like so using HTTPie's `http` command.

1. Start the application.

   Please start the application in one of the Terminal panes:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```bash
   [~/exercises] $ ./gradlew bootRun
   ```

1. Query the app.

   In the other Terminal pane, use the `http` command to request all Cash Cards from the running application:

   ```bash
   [~/exercises] $ http :8080/cashcards
   ```

   This time, instead of seeing the cash card data in the response, you see an error like the following:

   ```bash
   [~/exercises] $ http :8080/cashcards
   HTTP/1.1 401
   Cache-Control: no-cache, no-store, max-age=0, must-revalidate
   ...
   ```

   This is because Spring Security defaults require authentication automatically for every request in your Spring Boot application.

   **_Note:_** As we learned in the accompanying lesson, Spring Security uses REST conventions when responding to security failures: `401` for authentication errors, `403` for authorization errors.

   To further emphasize this, now try a non-existent endpoint like so:

   ```bash
   [~/exercises] $ http :8080/non-existent-endpoint
   HTTP/1.1 401
   Cache-Control: no-cache, no-store, max-age=0, must-revalidate
   ...
   ```

   In this case, you should also see a `401`. Even though you might have expected a `404`, it's better defensively to not share this information with the public.

1. Inspect the headers

   In the lesson we learned that Spring Security "Responds With Secure Headers for All Requests". We can see this principle in action in our testing here.

   In that above responses, notice the headers:

   ```bash
   ...
   Cache-Control: no-cache, no-store, max-age=0, must-revalidate
   ...
   X-Content-Type-Options: nosniff
   X-Frame-Options: DENY
   ```

   Spring Security automatically configures your application to respond with best-practice settings for cache control and content-type fuzzing. Also not shown here is strict transport security defense, which appears on HTTPS responses.
