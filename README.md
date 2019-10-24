# Introduction
This project contains a Kong and Konga ready to work with the addition of a customized plugging named ```kong-router```.

# Dockerized Kong and Konga

Summarized, this is a little project containing the following:

- In first instance we have a Kong docker image configured with a kong customized plugin (```kong-router```).

We will talk about the plugin later.

- The docker-compose.yml runs Kong and Konga and their databases ready to be used and with the plugin deployed on it and prepared also to be used.
 

## kong-router plugin for Kong

The kong router is a personalized plugin with the following functionality:

#### Description:

This plugin will allow us to redirect to a different upstream depending on a JWT token value.

If we have 2 APIS:

```curl -H 'Host: foo' http://127.0.0.1:8000/ -> https://foo.example.com```

```curl -H 'Host: bar' http://127.0.0.1:8000/ -> https://bar.example.com```

The behavior of this plugin (using a header and a JWT token containing in a configured claim the value 'foo' or 'bar') should be like this:

```curl -H 'Host: bar' -H 'Authorization: <JWT token with 'foo'>' http://127.0.0.1:8000/poc -> https://foo.example.com/poc```

```curl -H 'Host: foo' -H 'Authorization: <JWT token with 'bar'>' http://127.0.0.1:8000/poc -> https://bar.example.com/poc```

The plugin will obtain a ```JWT``` token from a header or a cookie (selectable by configuration).

From the previous token it will obtain a claim value (this claim name will be obtained from the plugin configuration).

With the obtained value, the target upstream in kong will be modified by a new one using an upstream prefix + the previous value obtained from the JWT token.


We will provide with this plugin a complete routing control based on the information contained in a JWT token.

Don't forget to create the upstreams you need in Kong previously.
 
#### Configuration:

| parameter     | default    | description |
| --------|---------|-------|
| upstream_name_prefix  | upstream   | The upstream prefix to be used for the target upstream.    |
| claim_where_the_upstream_name_is_located | .* | The claim in the ```JWT``` token to be used to recover the upstream name. It is a regular expression.    |
| continue_on_error  | false   | If this value is false and there is any error in the process, will return an error in other case it will continue.    |
| is_the_token_in_a_header_instead_of_a_cookie  | false   | A boolean value. It will set if the token comes from a header named "Authorization" or a cookie with the same name.    |


## Installation

If you need to recreate the image for kong personalized with the plugin changes you can launch the image creation with:

```docker build -t kong_plus_routing .```

When you have the image from the previous step you can run all the containers using the provided docker-compose:

```docker-compose up -d```

Be aware you are using as docker image name ```kong_plus_routing``` on this docker-compose. 

If you change the name when you generate the image the docker-compose will need to be changed obviously.




After the start process you can check if everything is working as expected in the logs of one of the containers, for example with:

```docker logs kong_kong_1```

or

```docker logs kong_kong-database_1```

#### Versions
| Version     | Date    | Description |
| --------|---------|-------|
| 1.0  | October-2019   | Initial version with the kong-router pluging.    |


## Author
Antonio Luis González Gómez 

