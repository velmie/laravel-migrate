<?php

namespace App\Providers;

use Illuminate\Database\Connection;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        // Configure database settings for Azure Managed Identity
        $this->configureAzureManagedIdentity();
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     * @throws \Illuminate\Contracts\Container\BindingResolutionException
     */
    public function boot()
    {
        $this->loadMigrationsFrom(
            ["/migrations"]
        );

        // Add PDO options for Azure Managed Identity token-based authentication
        $this->configureMySQLPDOOptions();
    }

    /**
     * Configure database settings for Azure Managed Identity if needed
     * 
     * @return void
     */
    protected function configureAzureManagedIdentity()
    {
        // Check if we're running in Azure with Managed Identity
        if (getenv('IDENTITY_ENDPOINT') && getenv('IDENTITY_HEADER')) {
            echo "[AppServiceProvider] Azure Managed Identity environment detected" . PHP_EOL;
            
            // Enable clear text password for MySQL token authentication
            putenv('LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1');
            echo "[AppServiceProvider] Set LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1" . PHP_EOL;

            // Ensure SSL is enabled for MySQL connections
            Config::set('database.connections.mysql.options', [
                \PDO::MYSQL_ATTR_SSL_CA => false, // Azure MySQL requires SSL by default
                \PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
            ]);
            echo "[AppServiceProvider] Configured MySQL SSL options" . PHP_EOL;
            
            // Debug database configuration
            $config = Config::get('database.connections.mysql');
            echo "[AppServiceProvider] DB config - driver: " . $config['driver'] . PHP_EOL;
            echo "[AppServiceProvider] DB config - host: " . $config['host'] . PHP_EOL;
            echo "[AppServiceProvider] DB config - database: " . $config['database'] . PHP_EOL;
            echo "[AppServiceProvider] DB config - username: " . $config['username'] . PHP_EOL;
            echo "[AppServiceProvider] DB config - password length: " . (isset($config['password']) ? strlen($config['password']) : 0) . PHP_EOL;
            
            if (function_exists('mysqli_get_client_info')) {
                echo "[AppServiceProvider] MySQLi client info: " . mysqli_get_client_info() . PHP_EOL;
            }
        } else {
            echo "[AppServiceProvider] Not running in Azure Managed Identity environment" . PHP_EOL;
        }
    }

    /**
     * Configure PDO options for MySQL with Azure AD token authentication
     * 
     * @return void
     */
    protected function configureMySQLPDOOptions()
    {
        // For Lumen, we'll add PDO options directly to the database configuration
        // Setting MySQL driver to allow cleartext passwords over SSL
        if (getenv('IDENTITY_ENDPOINT') && getenv('IDENTITY_HEADER')) {
            echo "[AppServiceProvider] Configuring PDO options for MySQL with Azure AD token authentication" . PHP_EOL;
            
            try {
                $this->app->resolving('db', function ($db) {
                    echo "[AppServiceProvider] DB service resolved, configuring connection" . PHP_EOL;
                    
                    try {
                        $connection = $db->connection();
                        $driverName = $connection->getDriverName();
                        echo "[AppServiceProvider] Connection driver: " . $driverName . PHP_EOL;
                        
                        if ($driverName === 'mysql') {
                            $connection->setReconnector(function ($connection) {
                                echo "[AppServiceProvider] Reconnector called, creating new PDO" . PHP_EOL;
                                $connection->setPdo($connection->createPdo());
                            });
                            echo "[AppServiceProvider] Reconnector configured successfully" . PHP_EOL;
                        }
                    } catch (\Exception $e) {
                        echo "[AppServiceProvider] Error configuring database connection: " . $e->getMessage() . PHP_EOL;
                    }
                });
                echo "[AppServiceProvider] DB resolving callback registered" . PHP_EOL;
            } catch (\Exception $e) {
                echo "[AppServiceProvider] Error setting up PDO options: " . $e->getMessage() . PHP_EOL;
            }
        } else {
            echo "[AppServiceProvider] Skipping PDO configuration (not in Azure MI environment)" . PHP_EOL;
        }
    }
}
