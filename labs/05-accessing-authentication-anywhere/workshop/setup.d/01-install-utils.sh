#!/bin/bash
set +e

# Mint a new JWT
(
    arch=$(uname -i)

    if [ "$arch" == 'aarch64' ]; then
        # Apple Silicon. Use a default in the lab.
        # Test using your own jwt cli on your Mac.
        TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzYXJhaDEiLCJhdWQiOiJodHRwczovL2Nhc2hjYXJkLmV4YW1wbGUub3JnIiwiaXNzIjoiaHR0cHM6Ly9pc3N1ZXIuZXhhbXBsZS5vcmciLCJleHAiOjE3MTYyMzkwMjIsImlhdCI6MTUxNjIzOTAyMiwic2NwIjpbImNhc2hjYXJkOnJlYWQiLCJjYXNoY2FyZDp3cml0ZSJdfQ.nTqi8wxNt1FyDFmzl7CeolJ2aWhkxHY4cShGD8uWWp1etmqRZ4qZVCsoo2tHiPHMLY0ZvJKy7mNKRg5AWXAO2Ij1yqt6eO7x587IsFRH6Wy_5RqVO4BBszJUiEiWPVeD6LzBk7pOage2lA7e_UCT_Jf30l15NHvq3oj84N2Hm_9XwwUmfMU91WhVezPsvEZ32IkOxTht8N0cUCv4ENMLdOXpJovBNCcLd-ITgqs9R4zIN9t-YI3blYFJnWTgxMpfooNNryBn9M06BB40krvHioeS9KFKYMIuMpIN3-Ny4rRKFpYGgdetWxmo1bfTXBZ3vR-RPIJK_Sxs2MmzxeLTKg"
    else
        # Make sure this dir is there
        mkdir -p /home/eduk8s/bin/

        # Download and install the JWT tool
        curl -L -o - https://github.com/mike-engel/jwt-cli/releases/download/6.0.0/jwt-linux.tar.gz | tar -xz -C /home/eduk8s/bin

        # Mint a new token
        TOKEN=$(
            jwt encode --aud "https://cashcard.example.org" \
            --secret @/home/eduk8s/exercises/src/main/resources/authz.pem \
            --iss "https://issuer.example.org" \
            --alg RS256 \
            --exp=+36000S \
            --sub "sarah1" \
            '{"scope":["cashcard:read","cashcard:write"]}'
        )
    fi

    # Make the JWT available in Terminal sessions
    echo "export TOKEN=$TOKEN" >> ~/.bash_profile
)