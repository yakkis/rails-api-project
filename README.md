# Ruby on Rails reference API project

A simple Ruby on Rails (RoR) reference project which implements an API for a single-player bowling game.

Project features:

- Ruby on Rails project
  - Configured for API only
- SQLite database
  - A single file database good for simple projects
- Docker containerization
  - With docker-compose.yml to facilitate application management

## Deprecation warnings

Ruby 2.7 causes deprecation warnings, for example:

```
/usr/local/bundle/gems/activemodel-6.0.2.1/lib/active_model/type/integer.rb:13: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
```

These are caused by Rails dependencies which are not yet updated to avoid Ruby 2.7 deprecations. However, these are just warnings, so they can be ignored for now.

## Setup

### Prerequisites

To run this project you need the following:
- Git
- Docker
- Docker Compose

### Fetch the project

To download the project repository, do the following:

```
# Clone the Git repository
$ git clone git@github.com:yakkis/rails-api-project.git
```

### Build and run the project

To build and run the project, use the following commands:

```
# Build the project
$ docker-compose build

# Run the project
$ docker-compose up

# Stop and remove containers
$ docker-compose down
```

The following steps are require when running the project for the first time:

#### Rails master.key and credentials.yml.enc

Rails requires the files 'master.key' and 'credentials.yml.enc' to be present, but those have been removed from the repository due to security concerns. These files can be created by opening them for editing, which causes Rails to recreate them if they are missing.

```
# Create a new master.key and credentials files (first time only)
# This command opens `vi` editor showing the content of the credentials file
# Just save the file and exit
$ docker-compose exec -e EDITOR="vi" api rails credentials:edit
```

#### Database initialization

To initialize a database from the `schema.rb` for the current environment ('development' by default), do the following:

```
# Set up a database (first time only)
$ docker-compose exec api rails db:setup
```

### Authentication

The API implements a JWT authentication to prevent unauthorized access. To use the API, generate a bearer token using Rails secret_key_base. For example:

```
# Open Rails console
$ docker-compose exec api rails console

...

# Generate a JWT token
[1] pry(main)> JWT.encode({}, Rails.application.secret_key_base, 'HS256')
=> "eyJhBeciOijIUzI5NiJ9.e33.QJb8I85Zzenf-OU-2Uv_bpQp8NI2yKjFAJ_x5NbHaAw"
```

Then add the token to a request header, for example:

```
$ curl -X POST --header "Authorization: Bearer eyJhBeciOijIUzI5NiJ9.e33.QJb8I85Zzenf-OU-2Uv_bpQp8NI2yKjFAJ_x5NbHaAw" localhost:3000/api/games
```

## API documentation

The file `swagger.yaml` in the project root contains API documentation. It can be viewed by going to `https://editor.swagger.io/` and copying the file content to the Swagger editor.

## Testing

Running individual tests inside a running Docker container:

```
# Run linting
$ docker-compose exec -e RAILS_ENV=test api rubocop

# Run Brakeman static analysis tool
$ docker-compose exec -e RAILS_ENV=test api brakeman -Az5 -i .brakeman.ignore

# Run tests
$ docker-compose exec -e RAILS_ENV=test api rspec
```

Running all tests using the project's Docker image:

```
# Run the shell script in the project's root
$ ./test.sh
```
