We don't get method security entirely for free. First, we need to enable it.

In the `CashCardApplication` add the `@EnableMethodSecurity` annotation at the class level.

It should look like this:

```editor:select-matching-text
file: ~/exercises/src/main/java/example/cashcard/CashCardApplication.java
text: "@SpringBootApplication"
description:
```

```java
@EnableMethodSecurity
@SpringBootApplication
public class CashCardApplication { ... }
```

Be sure to add the new required `import` statement:

```java
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
```

Ok, that was easy.

Now let's go fix the controller endpoint.
