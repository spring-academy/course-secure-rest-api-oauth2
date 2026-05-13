Next, you'll change your request to an authenticated one to see the difference in behavior.

The default user is `user`. The default password is regenerated at startup time.

Let's locate and use this generated password in an HTTP Basic Auth request to our running application.

1. Locate the generated password.

   To find the password, look for something similar to the following in the Terminal running the application with `bootRun`.

   Note that the password you see will be different.

   ```bash
   Using generated security password: 6cc833e4-8be5-44a6-b005-54e19c8e3201
   ```

   The UUID is the password that we need. Highlight and copy it.

1. Query the app with HTTP Basic Auth.

   Now, you can request the `/cashcards` resource with the user name "user" and the password that you copied. It should look something like this:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```bash
   [~/exercises] $ http -a user:6cc833e4-... :8080/cashcards
   ```

   The response should be the data that you saw in the previous lab. It will look something like this:

   ```bash
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
   	},
   	{
       	"amount": 150.0,
       	"id": 101,
       	"owner": "esuez5"
   	}
   ]
   ```

1. Query a bad endpoint.

   Next, try and request a non-existent endpoint.

   What do you think the response will be?

   ```bash
   [~/exercises] $ http -a user:6cc833e4-... :8080/non-existent-endpoint
   ```

   Instead of a `401`, you should now see a `404`:

   ```bash
   HTTP/1.1 404
   ...
   {
       "error": "Not Found",
       "path": "/non-existent-endpoint",
       "status": 404,
       "timestamp": "..."
   }
   ```

   It makes sense from a security perspective to show a `404` now since this is a known user.
