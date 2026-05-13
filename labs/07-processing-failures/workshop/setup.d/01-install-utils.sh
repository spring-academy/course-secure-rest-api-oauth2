#!/bin/bash
set +e

# Mint a new JWT
(
    arch=$(uname -i)

    # Make sure this dir is there
    mkdir -p /home/eduk8s/bin/

    if [ "$arch" == 'aarch64' ]; then
        # Apple Silicon. Use a default in the lab.
        # Test using your own jwt cli on your Mac.

        curl -L -o jwt https://github.com/spring-academy/spring-academy-tools/releases/download/6.0.0/jwt
        chmod +x jwt
        mv jwt /home/eduk8s/bin/
    else

        # Download and install the JWT tool
        curl -L -o - https://github.com/mike-engel/jwt-cli/releases/download/6.0.0/jwt-linux.tar.gz | tar -xz -C /home/eduk8s/bin
    fi

    INVALID_TOKEN=$(
        jwt encode --aud "https://wrong.example.org" \
        --secret @/home/eduk8s/exercises/src/main/resources/authz.pem \
        --iss "https://issuer.example.org" \
        --alg RS256 \
        --exp=1672556400 \
        --no-iat \
        --sub "sarah1" \
        '{"scope":["cashcard:read"]}'
    )

    # Make the JWT available in Terminal sessions
    echo "export INVALID_TOKEN=$INVALID_TOKEN" >> ~/.bash_profile
)