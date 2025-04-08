Data authorization is not included with the default Spring Security dependency.

We'll need to add the `spring-security-data` dependency to get everything working.

Let's do that now.

1. Add the `spring-security-data` dependency.

   So, in the `build.gradle` file make sure you have this dependency added:

   ```editor:select-matching-text
   file: ~/exercises/build.gradle
   text: "dependencies"
   description:
   ```

   ```groovy
   dependencies {
       ...
       implementation 'org.springframework.security:spring-security-data'
       ...
   }
   ```

   It's important to note that you didn't get alerted of a missing dependency or any other error at compile time.

   That's because the evaluation of `:#{authentication.name}` happens when Spring Data is trying to evaluate the statement at _runtime_.

   So, are we all good now?

1. Run the tests.

   Now, when we run the tests, they all pass!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldReturnAllCashCardsWhenListIsRequested() PASSED
   ...
   BUILD SUCCESSFUL in 4s
   ```

Awesome! We've successfully used data authorization to simplify our repository code.
