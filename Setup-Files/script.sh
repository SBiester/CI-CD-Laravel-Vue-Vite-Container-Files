#!/bin/sh
# Startskript für Container
FOLDER="/var/www/frontend"

# Nur initial einrichten, wenn Ordner leer ist
if [ -z "$(ls -A "$FOLDER")" ]; then
    # Templatefiles kopieren
    git clone git@github.com:SBiester/CI-CD-Laravel-Vue-Vite-DevTemplate.git "$FOLDER"

    cd "$FOLDER"
    # Laravel Projekt initialisieren
    composer install --no-interaction --prefer-dist
    composer require dcblogdev/laravel-microsoft-graph laravel/socialite socialiteproviders/microsoft-azure

    # App-Key und Caches
    php artisan key:generate
    php artisan optimize:clear
    php artisan config:clear
    php artisan view:clear
    php artisan route:clear

    # Node-Module
    npm install

    # Rechte setzen
    mkdir -p /var/www/frontend/storage/framework/sessions
    mkdir -p /var/www/frontend/storage/framework/views
    mkdir -p /var/www/frontend/storage/framework/cache
    chmod -R 777 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache

    # npm init -y

fi

# Node-Module
npm install

# Services starten
echo "Starting services..."
service php8.2-fpm start

echo "Ready."

# Vite Dev Server starten
npm run dev & # || exit 1
php artisan serve --host=0.0.0.0 --port=80 