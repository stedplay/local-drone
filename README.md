# local-drone

## Usage

Read following after replace 'any_\*' and 'your_\*' to appropriate value.

### Create Github OAuth App

1. Access to https://github.com/settings/developers, and press [Register a new application].

2. Input following items, and press [Register application].

| Item name | Value |
| - | - |
| Application name | any_string_app_name |
| Homepage URL | https://any_string_subdomain.localtunnel.me |
| Application description | any_string_app_desc |
| Authorization callback URL | https://any_string_subdomain.localtunnel.me/authorize |

3. Copy 'Client ID' and 'Client Secret' of OAuth App to following .env file.

### Create .env

```
$ cat .env.template
DRONE_PORT=any_number_port
DRONE_ADMIN=your_github_username
DRONE_SECRET=any_string_secret
DRONE_GITHUB_CLIENT=your_oauth_app_client_id
DRONE_GITHUB_SECRET=your_oauth_app_client_secret
LOCALTUNNEL_PROTOCOL=https://
LOCALTUNNEL_SUBDOMAIN=any_string_subdomain
LOCALTUNNEL_DOMAIN=.localtunnel.me
$ cp .env.template .env
$ vi .env   # Edit variables to appropriate value.
```

### Run local-drone

```
$ docker-compose up -d
```

#### Check that localtunnel got the specified URL

```
$ docker-compose logs localtunnel
Attaching to localdrone_localtunnel_1
localtunnel_1   | your url is: https://any_string_subdomain.localtunnel.me
$
```

If it got an unexpected URL, do one of the following before run local-drone again.

- Wait for a while until it can get the specified URL again.
- Reset 'any_string_subdomain' to different string.
- Build localtunnel server by yourself. https://github.com/localtunnel/server
- Use ngrok instead of localtunnel. https://github.com/inconshreveable/ngrok

### Access to drone-server

1. Access to https://any_string_subdomain.localtunnel.me

2. Login to the Github account, and authorize the OAuth App.

3. Activate a repository in repositories list.

### `git push` .drone.yml

`git push` .drone.yml file to the activated repository. Then, drone builds the repository according to the file automatically.

The result of the build is shown in real-time in the GUI of drone-server.

#### Example .drone.yml:

```
pipeline:
  helloworld:
    image: alpine
    commands:
      - echo 'Hello World!'
      - cat /etc/os-release
      - ls -la
#     - Any command to install, build, test, lint, deploy, etc.
```

For details, refer to Usage Documentation. http://docs.drone.io/getting-started/
