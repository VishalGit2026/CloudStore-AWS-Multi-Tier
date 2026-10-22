# CloudStore — AWS multi-tier storefront demo

Responsive technology storefront branded **CloudStore**, with the centered byline **Vishal Baskaran**. Built as a portfolio application for the AWS multi-tier project.

## What is included

- `app.py`: Flask API and storefront routing. Includes `/health` for the existing ALB health check, `/api/health`, product/category APIs and a transactional demo-order endpoint.
- `templates/index.html`, `static/css/styles.css`, `static/js/app.js`: responsive storefront, categories, search, sort, cart drawer and demo checkout.
- `sql/01-migrate-products.sql`: one-time migration adding brand, product image URL, badge and featured flag to the existing products table.
- `sql/02-seed-catalog.sql`: six categories and eighteen fictional demonstration products with sample INR prices.
- `sql/03-create-app-user.sql`: restricted application database user; replace its password placeholder before running.
- `deploy/`: systemd and Nginx examples.

The catalogue uses fictional demo product names/prices. Checkout stores a demo order in MySQL, decrements demo stock and **does not process payments**. Product photos load from Unsplash; a local SVG fallback is used when a photo cannot load.

## Existing database assumptions

The RDS database `cloudstore` already contains these tables from the earlier project steps: `categories`, `products`, `customers`, `orders`, and `order_items`. The existing table columns must match the CloudStore schema created earlier. The migration adds `brand`, `image_url`, `badge`, and `featured` to `products`.

## Database preparation (run once)

1. Connect as the RDS master user through the trusted SSL connection already tested.
2. Run `sql/01-migrate-products.sql` **once only**. It adds columns; running it again will report duplicate-column errors.
3. Run `sql/02-seed-catalog.sql`. It is safe to run again; category names and SKUs are unique and are upserted.
4. Edit `sql/03-create-app-user.sql`, replace `REPLACE_WITH_A_LONG_UNIQUE_PASSWORD` with a new strong password, and run it once. Use this limited user for the website; do not use the RDS master account in the application.
5. Save the application password securely. Never commit it or the `.env` file to GitHub.

## Deploy on BOTH EC2 App Servers

Repeat these steps on App Server 01 and App Server 02. Keep RDS private and permit inbound TCP/3306 from `CloudStore-App-SG` only.

### 1. Prepare Amazon Linux 2023

```bash
sudo dnf install -y python3 python3-pip nginx
sudo useradd --system --create-home --shell /sbin/nologin cloudstore
sudo mkdir -p /opt/cloudstore /etc/cloudstore
sudo chown -R cloudstore:cloudstore /opt/cloudstore
```

Copy the package's application files to `/opt/cloudstore` preserving `app.py`, `templates/`, `static/`, and `requirements.txt`. Then:

```bash
sudo -u cloudstore python3 -m venv /opt/cloudstore/venv
sudo -u cloudstore /opt/cloudstore/venv/bin/pip install --upgrade pip
sudo -u cloudstore /opt/cloudstore/venv/bin/pip install -r /opt/cloudstore/requirements.txt
```

### 2. Install RDS CA bundle

```bash
sudo curl -fSL https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -o /etc/cloudstore/global-bundle.pem
sudo chown root:cloudstore /etc/cloudstore/global-bundle.pem
sudo chmod 640 /etc/cloudstore/global-bundle.pem
```

### 3. Configure the application environment

Create `/etc/cloudstore/cloudstore.env` (do not place this file inside the GitHub repository):

```ini
DB_HOST=your-rds-endpoint
DB_PORT=3306
DB_NAME=cloudstore
DB_USER=cloudstore_app
DB_PASSWORD=your-unique-app-user-password
DB_SSL_CA=/etc/cloudstore/global-bundle.pem
DB_CONNECT_TIMEOUT=5
LOG_LEVEL=INFO
```

Then secure it:

```bash
sudo chown root:cloudstore /etc/cloudstore/cloudstore.env
sudo chmod 640 /etc/cloudstore/cloudstore.env
```

For a more mature setup, retrieve the DB password from AWS Systems Manager Parameter Store SecureString or Secrets Manager at boot rather than storing it directly in an environment file.

### 4. Install and start Gunicorn service

```bash
sudo cp /opt/cloudstore/deploy/cloudstore.service /etc/systemd/system/cloudstore.service
sudo systemctl daemon-reload
sudo systemctl enable --now cloudstore
sudo systemctl status cloudstore --no-pager
```

### 5. Configure Nginx reverse proxy

First inspect current configuration and back it up. The current project may have a static-site server block, so ensure **only one** default server listens on port 80. Do not blindly add a second `default_server` block.

```bash
sudo nginx -T | grep -nE 'listen .*80|server_name'
sudo cp -a /etc/nginx/conf.d /etc/nginx/conf.d.backup
```

Install the provided Nginx server block as the active port-80 server configuration (replace the existing static-site server block rather than leaving duplicate default blocks):

```bash
sudo cp /opt/cloudstore/deploy/cloudstore-nginx.conf /etc/nginx/conf.d/cloudstore.conf
sudo nginx -t
sudo systemctl reload nginx
```

If `nginx -t` reports a duplicate default server, inspect `nginx -T` and disable the old port-80 server file after backing it up, then run `nginx -t` again.

### 6. Test each server locally

```bash
curl -i http://127.0.0.1/health
curl -i http://127.0.0.1/api/health
curl -s http://127.0.0.1/api/categories
curl -s http://127.0.0.1/api/products
```

Expected: `/health` returns HTTP 200 with `healthy`; `/api/health` returns `{"application":"ok","database":"ok"}`; product APIs return seeded catalog records.

Then test the ALB DNS name in a browser. Confirm the existing target group `/health` checks still pass and both EC2 targets are healthy.

## Important project security notes

- Do not enable public access on RDS. Keep TCP/3306 restricted to the application security group.
- Use the restricted `cloudstore_app` DB user, not `cloudstoreadmin`, in the web application.
- The application verifies the RDS TLS certificate and hostname.
- `/health` checks the web process only so a temporary DB issue does not cause ASG instance replacement. `/api/health` checks the DB too.
- Demo checkout is not a payment system; do not collect payment card details or real sensitive customer data.
- Do not commit RDS passwords, app DB passwords, `.env`, PEM files, private keys or real customer records.
