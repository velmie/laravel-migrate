# Laravel migrations (based on Lumen)

### Based on
* [Laravel migrations](https://laravel.com/docs/8.x/migrations) -  v8

## Usage

### Standard Mode (Password Authentication)
```
docker run -v "/your/path/to/migrations:/migrations" \
  -e "DB_HOST=host" \
  -e "DB_PORT=3306" \
  -e "DB_DATABASE=example" \
  -e "DB_USERNAME=root" \
  -e "DB_PASSWORD=secret" \
  --rm velmie/laravel-migrate:1.1.0
```

### Azure Managed Identity Authentication
When running in Azure Container Apps with a System-assigned or User-assigned Managed Identity, you can use Azure AD token-based authentication:

```
docker run -v "/your/path/to/migrations:/migrations" \
  -e "DB_HOST=your-server.mysql.database.azure.com" \
  -e "DB_PORT=3306" \
  -e "DB_DATABASE=example" \
  -e "DB_USERNAME=your-aad-user@your-server" \
  --rm velmie/laravel-migrate:1.1.0
```

Note: When running in Azure Container Apps with Managed Identity enabled, the container will automatically detect the environment and use Azure AD token-based authentication without the need for a password.

#### Prerequisites for Azure Managed Identity:
1. Your Azure Container App must have System-assigned or User-assigned Managed Identity enabled
2. The Managed Identity must have appropriate permissions in Azure Database for MySQL
3. Azure AD authentication must be enabled on your MySQL server
4. An Azure AD database user must be created for your Managed Identity

## Options

* ```-v``` Bind mount a volume
    * ```-v "/your/path/to/migrations:/migrations"```
* ```-e``` Set environment variables
    * ```-e "DB_HOST=host"``` Specify DB host
    * ```-e "DB_PORT=3306"``` Specify DB port
    * ```-e "DB_DATABASE=example"``` Specify DB name
    * ```-e "DB_USERNAME=root"``` Specify DB username
    * ```-e "DB_PASSWORD=secret"``` Specify DB password (not needed with Azure Managed Identity)
* ```velmie/laravel-migrate:1.1.0``` Docker image to use
* ```--rm``` Automatically remove the container when it exits

### Database Connection
By default, it uses mysql connection. You may also specify connection by adding `-e "DB_CONNECTION=mysql"`

### Localhost
If you need to run migrations on your host machine then simply add `--network="host"` and specify `-e "DB_HOST=127.0.0.1"`.
Note that exactly "127.0.0.1" not "localhost" (otherwise it may try to connect via socket file). 
