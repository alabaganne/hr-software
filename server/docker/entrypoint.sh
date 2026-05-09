#!/bin/bash

# Wait for database to be ready
echo "Waiting for database..."
while ! nc -z db 3306; do
  sleep 1
done
echo "Database is ready!"

# Generate application key if not exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
fi

# Generate JWT secret if not exists
php artisan jwt:secret --force

# Generate application key if not exists
php artisan key:generate --force

# Run database migrations
echo "Running migrations..."
php artisan migrate --force

# Seed database once. The legacy seeders are not idempotent.
if [ "$(php artisan tinker --execute="echo App\\Models\\User::count();" 2>/dev/null | tail -n 1)" = "0" ]; then
  echo "Seeding database..."
  php artisan db:seed --force
else
  echo "Database already seeded; skipping seed."
fi

# Clear/cache safe framework artifacts. This legacy app has a Closure route, so route:cache is invalid.
php artisan config:cache
php artisan route:clear
php artisan view:cache

# Ensure php-fpm/nginx can write logs/cache after root-run artisan bootstrapping.
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Start the main process
exec "$@"