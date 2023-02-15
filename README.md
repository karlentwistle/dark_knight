# Dark Knight

The Dark Knight automatically restarts your Heroku dynos if they start swapping to disk [R14 - Memory Quota Exceeded in Ruby (MRI)](https://devcenter.heroku.com/articles/ruby-memory-use).

Once a Heroku dyno starts swapping to disk, it becomes comparatively slow and unresponsive, so taking it out of formation is the best course of action.

> He's a silent guardian, a watchful protector. A dark knight.

~ Jonathan Nolan, The Dark Knight

## Setup

### Deploying the Dark Knight

To deploy the service:

    $ git clone https://github.com/karlentwistle/dark_knight.git
    $ heroku create <your_dark_knight_app_name>
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

## Future enhancements

- Slack notifications
- Restart threshold (So a dyno could be restarted when x% of RAM is being used)
- Backoff factor (So you can configure intervals between restarts for a dyno type)
