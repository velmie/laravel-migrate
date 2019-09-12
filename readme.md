# Laravel migrations (based on Lumen)

### Usage
`docker run -v "/your/path/to/migrations:/migrations" -e "DB_HOST=host" -e "DB_PORT=3306" -e "DB_DATABASE=example" -e "DB_USERNAME=root" -e "DB_PASSWORD=secret" --rm a1xp/laravel-migrate`

By default it uses mysql connection. You may also specify connection by adding `-e "DB_CONNECTION=mysql"`

### Localhost
If you need to run migrations on your host machine then simply add `--network="host"` and specify `-e "DB_HOST=127.0.0.1"`.
Note that exactly "127.0.0.1" not "localhost" (otherwise it may try to connect via socket file). 
