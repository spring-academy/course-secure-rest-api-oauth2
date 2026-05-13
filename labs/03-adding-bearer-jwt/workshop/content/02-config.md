Transforming our application into a OAuth 2.0 Resource Server is as simple as adding the correct Spring Boot dependency.

Let's go for it!

1. Add the dependency.

   First, you will need to include the appropriate Spring Boot Starter dependency.

   In the `build.gradle` file, add the following to the `dependencies { ... }` section:

   ```editor:open-file
   file: ~/exercises/build.gradle
   ```

   ```gradle
   dependencies {
    ...
    implementation 'org.springframework.boot:spring-boot-starter-oauth2-resource-server'
   }
   ```

   This brings in Spring Boot's autoconfiguration and it also adds Spring Security's Resource Server and JWT modules

   **_Tip:_** When you edit `build.gradle` the Editor will ask you if you want to synchronize the Java classpath. Select "Always" and the project will automatically rebuild with the new Spring Security dependency. Nice!

   ![Always synchronize the Java classpath](images/synchronize-classpath.png "Always synchronize the Java classpath")

1. Configure the resource server.

   Then, you will need to indicate how your REST API (now an OAuth 2.0 Resource Server!) is going to verify JWT signatures.

   Typically, these signatures are verified with a public key, so one has been provided for you. Note that in a future lab, you'll connect to an authorization server that provides a set of public keys from a remote endpoint.

   In the `application.yml` file, reference the provided public key like so:

   ```editor:open-file
   file: ~/exercises/src/main/resources/application.yml
   ```

   ```yaml
   spring:
     security:
       oauth2:
         resourceserver:
           jwt:
             public-key-location: classpath:authz.pub
   ```

   This activates Spring Boot's resource server autoconfiguration.

   When you present your REST API with a JWT, Spring Security will use this public key to verify its signature.

1. Verify the tests still pass.

   Now, run the unit tests.

   Run the tests in one of the Terminal panes:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```bash
   [~/exercises] $ ./gradlew test
   ```

   Because we haven't used any protocol-specific test support yet, Spring Security has correctly adapted and the tests will still pass.
