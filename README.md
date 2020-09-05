# cachet
Basic API proxy that caches responses for a configurable window. Runs a thin Sinatra wrapper around the configured external API.

## Hosting
Configured to run on AWS Lambda with an associated DynamoDB table for caching. DynamoDB is used because more conventional memory-based key-value stores aren't available as managed services (and thus overbill for very low-use services). Sinatra Lambda config courtesy of https://github.com/aws-samples/serverless-sinatra-sample

## Configuration
Currently, this proxy assumes that the API key is passed in via a query parameter, which understandably is rarely the case for production APIs, but this is how the Boston MBTA API works, and that's what I wrote this for. Since the API key is readily available in plaintext and doesn't give access to any sensitive actions (e.g. things that would cost me money), I've put it in plaintext in this repository.

