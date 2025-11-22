# Maawa Deployment Guide

This guide covers deploying the Maawa platform to production environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Backend Deployment (Laravel)](#backend-deployment-laravel)
- [Frontend Deployment (Flutter)](#frontend-deployment-flutter)
- [Environment Configuration](#environment-configuration)
- [Security Checklist](#security-checklist)
- [Monitoring and Maintenance](#monitoring-and-maintenance)

## Prerequisites

### Backend Requirements
- PHP 8.2+ with required extensions
- Composer 2.x
- MySQL 8.0+ or PostgreSQL 13+
- Web server (Nginx/Apache)
- SSL certificate (Let's Encrypt recommended)
- Redis (optional, for caching and queues)

### Frontend Requirements
- Flutter SDK 3.5.4+
- Android Studio (for Android builds)
- Xcode 15+ (for iOS builds, macOS only)
- Firebase project (for push notifications)
- Apple Developer Account (for iOS)
- Google Play Console Account (for Android)

## Backend Deployment (Laravel)

### Option 1: Traditional Server (VPS/Dedicated)

#### 1. Server Setup

**Install Dependencies:**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.2 and extensions
sudo apt install -y php8.2-fpm php8.2-cli php8.2-mysql php8.2-xml \
    php8.2-mbstring php8.2-curl php8.2-zip php8.2-bcmath \
    php8.2-redis php8.2-gd

# Install Composer
curl -sS https://getcomposer.com/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install MySQL
sudo apt install -y mysql-server
sudo mysql_secure_installation

# Install Nginx
sudo apt install -y nginx

# Install Redis (optional)
sudo apt install -y redis-server
```

#### 2. Configure Database

```bash
# Connect to MySQL
sudo mysql -u root -p

# Create database and user
CREATE DATABASE maawa_production;
CREATE USER 'maawa_user'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON maawa_production.* TO 'maawa_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 3. Deploy Application

```bash
# Create application directory
sudo mkdir -p /var/www/maawa
cd /var/www/maawa

# Clone repository (or upload files)
git clone https://github.com/yourusername/maawa_backend.git .

# Install dependencies
composer install --no-dev --optimize-autoloader

# Set permissions
sudo chown -R www-data:www-data /var/www/maawa
sudo chmod -R 755 /var/www/maawa
sudo chmod -R 775 /var/www/maawa/storage
sudo chmod -R 775 /var/www/maawa/bootstrap/cache
```

#### 4. Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Edit environment variables
nano .env
```

**Production .env:**
```env
APP_NAME=Maawa
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://api.maawa.com

LOG_CHANNEL=daily
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=maawa_production
DB_USERNAME=maawa_user
DB_PASSWORD=strong_password_here

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

JWT_SECRET=your_jwt_secret_here
JWT_TTL=60

FIREBASE_CREDENTIALS=/path/to/firebase-credentials.json

# File storage (use S3 for production)
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=
AWS_BUCKET=
AWS_URL=
```

#### 5. Initialize Application

```bash
# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Create symbolic link for storage
php artisan storage:link
```

#### 6. Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/maawa
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.maawa.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.maawa.com;

    root /var/www/maawa/public;
    index index.php;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.maawa.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.maawa.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Logging
    access_log /var/log/nginx/maawa-access.log;
    error_log /var/log/nginx/maawa-error.log;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Enable Site:**
```bash
sudo ln -s /etc/nginx/sites-available/maawa /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 7. SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.maawa.com

# Auto-renewal is configured automatically
```

#### 8. Setup Queue Workers (Optional)

```bash
sudo nano /etc/supervisor/conf.d/maawa-worker.conf
```

```ini
[program:maawa-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/maawa/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/maawa/storage/logs/worker.log
stopwaitsecs=3600
```

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start maawa-worker:*
```

### Option 2: Platform as a Service (PaaS)

#### Deploy to Laravel Forge

1. **Create Server** on Laravel Forge
2. **Add Site** (api.maawa.com)
3. **Configure Repository** (GitHub/GitLab/Bitbucket)
4. **Set Environment Variables** in Forge dashboard
5. **Enable Quick Deploy** for automatic deployments
6. **Setup SSL** (automatic with Let's Encrypt)
7. **Configure Queue Workers** (if needed)

#### Deploy to Heroku

```bash
# Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Login
heroku login

# Create app
heroku create maawa-api

# Add MySQL addon
heroku addons:create jawsdb:kitefin

# Add Redis addon (optional)
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set APP_KEY=$(php artisan key:generate --show)
heroku config:set APP_ENV=production
heroku config:set APP_DEBUG=false

# Deploy
git push heroku main

# Run migrations
heroku run php artisan migrate --force
```

## Frontend Deployment (Flutter)

### Android Build

#### 1. Configure App Signing

**Create keystore:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
    -keysize 2048 -validity 10000 -alias upload
```

**Configure signing in `android/key.properties`:**
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

**Update `android/app/build.gradle`:**
```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 2. Build Release APK/AAB

```bash
# Update API endpoint in app_config.dart
# Set API_BASE_URL to production URL

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Or build APK
flutter build apk --release --split-per-abi
```

**Outputs:**
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APKs: `build/app/outputs/flutter-apk/`

#### 3. Deploy to Google Play Store

1. **Create App** in [Google Play Console](https://play.google.com/console)
2. **Fill App Details** (title, description, screenshots)
3. **Upload App Bundle** in "Production" track
4. **Complete Content Rating** questionnaire
5. **Set Pricing** (Free/Paid)
6. **Review and Publish**

### iOS Build

#### 1. Configure Signing

**In Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Select your Team
5. Configure Bundle Identifier (e.g., `com.maawa.app`)

#### 2. Build Release IPA

```bash
# Update API endpoint for production
# Build iOS release
flutter build ios --release

# Or build IPA directly
flutter build ipa --release
```

#### 3. Deploy to App Store

**Using Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Product → Archive
3. Validate App
4. Distribute App → App Store Connect

**Or using command line:**
```bash
cd ios
fastlane deliver
```

## Environment Configuration

### Development Environment

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String API_BASE_URL = 'http://localhost:8000/v1';
  static const bool IS_PRODUCTION = false;
  static const bool ENABLE_LOGS = true;
}
```

### Production Environment

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String API_BASE_URL = 'https://api.maawa.com/v1';
  static const bool IS_PRODUCTION = true;
  static const bool ENABLE_LOGS = false;
}
```

### Using Flavors (Advanced)

Create separate configurations for dev/staging/prod:

```bash
# Run with flavor
flutter run --flavor dev
flutter build apk --flavor prod
```

## Security Checklist

### Backend Security

- [ ] `APP_DEBUG=false` in production
- [ ] Strong `APP_KEY` generated
- [ ] Secure database credentials
- [ ] JWT secrets are random and strong
- [ ] HTTPS enabled with valid SSL certificate
- [ ] CORS configured properly
- [ ] Rate limiting enabled
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (using Eloquent)
- [ ] XSS protection headers set
- [ ] File upload validation
- [ ] Sensitive data in `.env` not in version control
- [ ] Regular security updates applied

### Frontend Security

- [ ] API keys not hardcoded
- [ ] Sensitive data stored in Secure Storage
- [ ] HTTPS pinning (optional)
- [ ] Code obfuscation enabled
- [ ] ProGuard rules configured (Android)
- [ ] Debug logs disabled in production
- [ ] Input validation on forms
- [ ] Secure WebView configuration (if used)

## Monitoring and Maintenance

### Backend Monitoring

**Log Monitoring:**
```bash
# View Laravel logs
tail -f storage/logs/laravel.log

# View Nginx logs
tail -f /var/log/nginx/maawa-error.log
```

**Application Monitoring:**
- Use services like [Laravel Telescope](https://laravel.com/docs/telescope)
- Setup [Sentry](https://sentry.io/) for error tracking
- Use [New Relic](https://newrelic.com/) for performance monitoring

**Database Backups:**
```bash
# Automated daily backups
sudo crontab -e

# Add cron job
0 2 * * * /usr/bin/mysqldump -u maawa_user -p'password' maawa_production > /backups/db_$(date +\%Y\%m\%d).sql
```

### Frontend Monitoring

**Crashlytics (Firebase):**
```dart
// Initialize in main.dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

**Analytics:**
```dart
// Track screen views
FirebaseAnalytics.instance.logScreenView(
  screenName: 'PropertyDetail',
);

// Track events
FirebaseAnalytics.instance.logEvent(
  name: 'booking_created',
  parameters: {'property_id': propertyId},
);
```

### Performance Optimization

**Backend:**
- Enable OPcache for PHP
- Use Redis for caching
- Optimize database queries
- Enable GZIP compression
- Use CDN for static assets

**Frontend:**
- Optimize images before uploading
- Use cached_network_image
- Implement pagination
- Lazy load images
- Minimize app size

### Continuous Deployment

**Setup GitHub Actions:**

```.github/workflows/deploy-backend.yml
name: Deploy Backend

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USERNAME }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /var/www/maawa
            git pull origin main
            composer install --no-dev
            php artisan migrate --force
            php artisan config:cache
            php artisan route:cache
            php artisan view:cache
```

---

## Support

For deployment issues, contact: devops@maawa.com

## References

- [Laravel Deployment Docs](https://laravel.com/docs/deployment)
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Nginx Documentation](https://nginx.org/en/docs/)

