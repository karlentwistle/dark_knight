# Dark Knight

## Todo

- Write README
- Add deploy to Heroku button

## Setup

### Deploying the Dark Knight

To deploy the drain:

    $ git clone https://github.com/karlentwistle/dark_knight.git
    $ heroku apps create
    $ heroku buildpacks:add heroku/ruby
    $ heroku config:set APP_ID_OR_NAME=<ID_OR_NAME_OF_HEROKU_APP_BEING_MONITORED>
    $ heroku config:set DRAIN_PASSWORD=<YOUR_DRAIN_PASSWORD>
    $ heroku config:set AUTH_TOKEN=<HEROKU_API_AUTHENTICATION_TOKEN>
    $ heroku config:set DYNO_TYPES=web,worker
    $ heroku config:set RACK_ENV=production
    $ git push heroku main

### Instrumenting an App

To instrument an app:

    $ heroku labs:enable log-runtime-metrics --app <ID_OR_NAME_OF_HEROKU_APP_BEING_MONITORED>
    $ heroku drains:add https://user:<YOUR_DRAIN_PASSWORD>@<YOUR_DARK_KNIGHT_APP>.herokuapp.com/logs --app <ID_OR_NAME_OF_HEROKU_APP_BEING_MONITORED>

### Configuration

The following is the full list of ENV configuration options:

| ENV name | Description | Example | Default | Required |
|---|---|---|---|---|
| `DRAIN_PASSWORD` | [HTTPS drain password](https://devcenter.heroku.com/articles/log-drains#https-drains)  | `password` | N/A |✅ |
| `APP_ID_OR_NAME` | ID or name of Heroku app being monitored | `whatismyip` | N/A | ✅ |
| `AUTH_TOKEN` | [Heroku API authentication token](https://devcenter.heroku.com/articles/platform-api-quickstart#authentication) | `cf0e05d9-4eca-4948-a012-b91fe9704bab` | N/A | ✅ |
| `DYNO_TYPES` | Dynos to restart when swapping (R14) | `web,worker` | `web` | ❌ |
