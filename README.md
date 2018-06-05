# local-drone

## Basic usage

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
TIME_ZONE=your_continent/your_region   # e.g. Asia/Tokyo
MYSQL_ROOT_PASSWORD=any_string_root_password
MYSQL_DATABASE=any_string_database_name
MYSQL_USER=any_string_user_name
MYSQL_PASSWORD=any_string_user_password
GDRIVE_ACCOUNT=your_mail_address@gmail.com
GDRIVE_SYNC_DST_DIR=/any_string_directory/any_string_subdirectory/
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

## Usage of the container to backup database

### How to change the time to backup

Backup is run by crond. If want to change the default time to run, edit crontab_root file and restart the container.

```
$ cat ./drone-db-backup/crontab_root
0 2 * * * /opt/script/backup.sh
$ vi ./drone-db-backup/crontab_root
$ docker-compose restart drone-db-backup
```

### How to restore data from backup file

Remove container and database data. Then, restart local-drone.

```
$ docker-compose down --rmi all
$ rm -r ./_data/drone-db/
$ docker-compose up -d
```

Decompress the backup file, and restore it to database.

```
$ docker-compose exec drone-db-backup gzip -dk /var/backup/dump.sql_YYYYMMDD_HHMISS.gz
$ docker-compose exec drone-db-backup sh -c \
  'mysql --host=drone-db \
  --user=any_string_user_name \
  --password=any_string_user_password \
  any_string_database_name \
  < /var/backup/dump.sql_YYYYMMDD_HHMISS'
```

Access to drone-server. If the server doesn't work well, try following.

- Logout from drone.
- Inactivate the repository in repositories list, and activate again.

### How to upload the backup file to google drive.

GDrive(https://github.com/prasmussen/gdrive) access your Google Account. Authentication is needed to send the backup file to google drive.

1. Execute the command described below to get the url for authentication.
2. Access to the displayed url with browser.
3. Select the same account set to GDRIVE_ACCOUNT in .env file.
4. Copy verification code, and enter it into the console.

```
$ docker-compose exec drone-db-backup gdrive-linux-x64 about
Authentication needed
Go to the following url in your browser:
https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=...

Enter verification code: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
User: ..., your_mail_address@gmail.com
Used: ... GB
Free: ... GB
Total: ... GB
Max upload size: ... TB
$
```

#### How to change the account

If want to change the account to upload, execute following commands.

1. Change GDRIVE_ACCOUNT to the another acount in .env file.
2. Reload environment variables in the container. (/root/.gdrive/ directory that save the data to upload is cleared concomitantly with recreating the container.)
3. Authenticate again with the another acount.

```
$ vi .env   # Change GDRIVE_ACCOUNT
$ docker-compose up -d
$ docker-compose exec drone-db-backup gdrive-linux-x64 about
```

### How to disable backup

If don't need backup, execute following command when run local-drone.

```
$ docker-compose up -d --scale drone-db-backup=0
```
