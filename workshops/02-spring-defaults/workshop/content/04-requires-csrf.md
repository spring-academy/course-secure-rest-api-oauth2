All of our tests are passing except one: `shouldCreateANewCashCard`, which is a `POST` test that creates a new `CashCard`. This is because Spring Security does not authorize `POST`s without a CSRF token.

You can add this in the `MockMvc` declaration using one of Spring Security's `MockMvc` `RequestPostProcessor`s, namely `csrf()`.

To fix the test with proper CSRF support, import the static helper method and add the CSRF token to the request:

First, import the static helper method

```java
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
...
void shouldCreateANewCashCard() throws Exception {
  String location = this.mvc.perform(post("/cashcards")
      .with(csrf())
   ...
```

Now, run your tests again, and they should all pass!

Next, we'll run the application, and see Spring Security's defaults in action.
