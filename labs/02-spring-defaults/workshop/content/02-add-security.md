The only configuration you'll do in this lab is to add Spring Security to the classpath.

1. Add Spring Security.

   Go to the `build.gradle` file and add the following to the `dependencies` section:

   ```editor:open-file
   file: ~/exercises/build.gradle
   ```

   ```gradle
   dependencies {
     ...
     implementation 'org.springframework.boot:spring-boot-starter-security'
     ...
   }
   ```

   This adds Spring Security as well as Spring Boot's related autoconfiguration to the classpath.

   **_Tip:_** When you edit `build.gradle` the Editor will ask you if you want to synchronize the Java classpath. Select "Always" and the project will automatically rebuild with the new Spring Security dependency. Nice!

   ![Always synchronize the Java classpath](images/synchronize-classpath.png "Always synchronize the Java classpath")

1. Run the tests and observe the errors.

   Now that Spring Security is added, let's try running the unit tests.

   In the Terminal:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```bash
   [~/exercises] $ ./gradlew test
   ```

   You can see that they fail with errors like the following:

   ```shell
   CashCardApplicationTests > shouldReturnACashCardWhenDataIsSaved() FAILED
       java.lang.AssertionError: Status expected:<200> but was:<401>
           ...

   CashCardApplicationTests > shouldCreateANewCashCard() FAILED
       java.lang.AssertionError: Status expected:<201> but was:<403>
           ...

   CashCardApplicationTests > shouldReturnAllCashCardsWhenListIsRequested() FAILED
       java.lang.AssertionError: Status expected:<200> but was:<401>
           ...
   ```

Why is everything failing just because we added a dependency?

That's _secure by default_ in action!
