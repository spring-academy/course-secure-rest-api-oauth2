##

It would be nice if the error response contained all errors, but how can we do that?

The answer is by using a custom authentication entry point.

Recall from a previous lesson that `AuthenticationEntryPoint` is the Spring Security component for addressing authentication failures.

Good news! We've provided an `AuthenticationEntryPoint` named `ProblemDetailsAuthenticationEntryPoint` for you. But, you'll still have to do a lot of (fun!) work to make it work for us.

1. Review `ProblemDetailsAuthenticationEntryPoint`.

   First, take a quick look at the entry point.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/ProblemDetailsAuthenticationEntryPoint.java
   text: "public void commence"
   description:
   ```

   ```java
   @Component
   public class ProblemDetailsAuthenticationEntryPoint implements AuthenticationEntryPoint {

       @Override
       public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException)
               throws IOException, ServletException {
       }
   }
   ```

   You'll see that it's a mostly-empty component with only one overridden method, `commence()`, and a bunch of `import` statements we'll need later.

   Let's make this thing more useful.

1. Set a response status.

   Let's start implementing our custom entry point with something simple: having it return a status code to `401`.

   ```java
   @Component
   public class ProblemDetailsAuthenticationEntryPoint implements AuthenticationEntryPoint {

       @Override
       public void commence(HttpServletRequest request, HttpServletResponse response,
                          AuthenticationException authException)
               throws IOException, ServletException {
               response.setStatus(401);
       }
   }
   ```

   Now authentication failures will have a status code of `401 UNAUTHORIZED`.

Next we'll wire up our entry point to be used with our Spring Security configuration.
