Now that we are a resource server, we need to provide a valid JSON Web Token with our requests. Let's do that now.

1. Inspect the `TOKEN`.

   Normally the JWT would come from a client application requesting authorization from an authorization server. Since those pieces aren't in place yet, please run the following command in the Terminal to inspect the JWT we have provided for you in an environment variable named `TOKEN`:

   ```bash
   [~/exercises] $ echo $TOKEN
   eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzYXJhaDEiLCJhdWQiOiJodHRwczovL2Nhc2hjYXJkLmV4YW1wbGUub3JnIiwiaXNzIjoiaHR0cHM6Ly9pc3N1ZXIuZXhhbXBsZS5vcmciLCJleHAiOjE3MTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMiwic2NwIjpbImNhc2hjYXJkOnJlYWQiLCJjYXNoY2FyZDp3cml0ZSJdfQ.nTqi8wxNt1FyDFmzl7CeolJ2aWhkxHY4cShGD8uWWp1etmqRZ4qZVCsoo2tHiPHMLY0ZvJKy7mNKRg5AWXAO2Ij1yqt6eO7x587IsFRH6Wy_5RqVO4BBszJUiEiWPVeD6LzBk7pOage2lA7e_UCT_Jf30l15NHvq3oj84N2Hm_9XwwUmfMU91WhVezPsvEZ32IkOxTht8N0cUCv4ENMLdOXpJovBNCcLd-ITgqs9R4zIN9t-YI3blYFJnWTgxMpfooNNryBn9M06BB40krvHioeS9KFKYMIuMpIN3-Ny4rRKFpYGgdetWxmo1bfTXBZ3vR-RPIJK_Sxs2MmzxeLTKg
   ```

   Well, that's obtuse!

   While impossible to see in this form, the JWT contains reasonable defaults _specifically for Cash Card owner **`sarah1`**_, and is signed with the private key in the project.

   Let's now look at the token in a more human readable form.

1. Decode the JWT.

   You can check out the reasonable defaults when you decode the JWT.

   Run the following command:

   ```bash
   [~/exercises] $ jwt decode $TOKEN
   ```

   This command will print out a result including claims like the following:

   ```json
   Token claims
   ------------
   {
     "aud": "https://cashcard.example.org",
     "exp": 1698799701,  // Timestamp 10 hours from now
     "iat": 1698763701,  // Timestamp when this lab started
     "iss": "https://issuer.example.org",
     "scope": [
       "cashcard:read",
       "cashcard:write"
     ],
     "sub": "sarah1"
   }
   ```

   As you can see, it has an `exp` claim that shows a timestamp in the future. For this course we have set the expiration far in the future, but stronger security policies would set this about an hour into the future.

   This JWT also has a `sub` claim that refers to the user principal (`sarah1`) that we'll connect with a little later.

   There are other claims in here, too, that we will care about a little later on, specifically `iss`, `aud`, and `scope`.

1. Query the application with the bearer token.

   Now, request the `/cashcards` endpoint, providing your token.

   Do you think the request will succeed or fail?

   ```bash
   [~/exercises] http :8080/cashcards "Authorization: Bearer $TOKEN"
   ```

   It worked! Your response should now include the set of Cash Cards in the database, as before:

   ```json
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

Take a minute to ponder why it's still showing `sarah1` and `esuez5`'s cards. Do you think if we minted a JWT with a different `sub` that it would show a different set of cards?
