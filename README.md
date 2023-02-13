# Dark Knight

## Todo

- Add ENV to control which process types to restart
  - Dont restart these types of dynos
- Write README
- Add deploy to Heroku button

## Configuration

The following is the full list of ENV configuration options:

| ENV name | Description | Example | Default | Required |
|---|---|---|---|---|
| `DRAIN_PASSWORD` | [HTTPS drain password](https://devcenter.heroku.com/articles/log-drains#https-drains)  | `password` | N/A |✅ |
| `APP_ID_OR_NAME` | ID or name of Heroku app being monitored | `whatismyip` | N/A | ✅ |
| `AUTH_TOKEN` | [Heroku API authentication token](https://devcenter.heroku.com/articles/platform-api-quickstart#authentication) | `cf0e05d9-4eca-4948-a012-b91fe9704bab` | N/A | ✅ |
| `DYNO_TYPES` | Dynos to restart when swapping (R14) | `web, worker` | `web` | ❌ |
