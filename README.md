# CloudStore – Production-Ready Highly Available AWS Multi-Tier Architecture

**A scalable, highly available cloud-hosted e-commerce application built using AWS, Python Flask, MySQL, Application Load Balancer, and Auto Scaling.**

Developed by **Vishal B.**

[GitHub Repository](https://github.com/VishalGit2026/CloudStore-AWS-Multi-Tier)

---

## Project Overview

CloudStore is a cloud-based technology storefront deployed on Amazon Web Services (AWS) using a multi-tier architecture.

The project demonstrates how to deploy and operate a web application using private EC2 application servers, an Application Load Balancer, an Auto Scaling Group, and a private Amazon RDS MySQL database.

The infrastructure is designed to improve application availability, scalability, security, and maintainability.

## Architecture Overview

```text
                 Internet Users
                       |
                       v
              Application Load Balancer
                       |
                Target Group (HTTP:80)
                       |
             -----------------------
             |                     |
             v                     v
       EC2 App Server 01      EC2 App Server 02
       Availability Zone A    Availability Zone B
             |                     |
             -----------------------
                       |
                 Flask + Gunicorn
                       |
                    Nginx
                       |
                       v
                Amazon RDS MySQL
                 Private Database
```

**Infrastructure components:**
- Public-facing Application Load Balancer
- Private EC2 application instances
- Auto Scaling Group for instance management
- Amazon RDS MySQL database
- Security Groups controlling tier-to-tier communication

## AWS Services & Technologies

| Service / Technology | Purpose |
|---|---|
| Amazon VPC | Network isolation |
| Public & Private Subnets | Network segmentation |
| Amazon EC2 | Application hosting |
| Application Load Balancer | Traffic distribution |
| Auto Scaling Group | Application instance scaling |
| Amazon RDS MySQL | Managed relational database |
| IAM | Access and permissions management |
| Security Groups | Network access control |
| AWS Secrets Manager | Database credential management |
| Amazon Linux 2023 | Application server operating system |
| Python Flask | Backend application |
| Gunicorn | Python application server |
| Nginx | Reverse proxy |
| MySQL | Database |
| HTML, CSS, JavaScript | Frontend |

## Key Features

- Multi-tier AWS architecture.
- Load-balanced application traffic.
- Two EC2 application servers across separate Availability Zones.
- Auto Scaling Group configured with desired capacity of 2 and scaling range of 2–4 instances.
- Private RDS MySQL database.
- Database connectivity using SSL/TLS.
- Flask REST API endpoints.
- Product catalogue with categories and search.
- Shopping cart and demonstration checkout functionality.
- Systemd service management.
- Nginx reverse proxy configuration.

## Infrastructure Configuration

**AWS Region:** Asia Pacific (Sydney) – `ap-southeast-2`

| Component | Configuration |
|---|---|
| Application Load Balancer | CloudStore-App-ALB |
| Target Group | CloudStore-App-TG |
| Auto Scaling Group | CloudStore-App-ASG |
| Application Server 01 | `10.20.11.98` |
| Application Server 02 | `10.20.12.42` |
| Database | Amazon RDS MySQL |
| Database Name | `cloudstore` |
| Application Port | 80 |
| Gunicorn Port | 8000 (localhost) |
| Database Port | 3306 |

## Application Testing & Validation

The following application endpoints were tested through the Application Load Balancer:

| Endpoint | Test Result |
|---|---|
| `/` | HTTP 200 |
| `/health` | HTTP 200 |
| `/api/health` | HTTP 200 |
| `/api/categories` | HTTP 200 |
| `/api/products` | HTTP 200 |
| `/api/products/1` | HTTP 200 |

**Additional validation:**
- Database health check returned application and database status as `ok`.
- Ten consecutive `/api/health` requests returned HTTP 200.
- Product catalogue returned 18 demonstration products.
- Category API returned 6 categories.
- Frontend category browsing, search, product details, and cart interactions were tested.

*Note: Checkout is a demonstration feature and is not a production payment-processing system.*

## Security Implementation

- RDS database is kept private.
- Application Security Group permits inbound HTTP traffic only from the ALB Security Group.
- Database Security Group permits MySQL traffic only from the application Security Group.
- Application uses a restricted database account instead of the RDS master account.
- Database connections use SSL/TLS certificate verification.
- IAM instance role provides controlled access to AWS Secrets Manager.
- Sensitive credentials are kept outside the Git repository.
- Health checks are separated into application health and database health endpoints.

## Repository Structure

```text
CloudStore-AWS-Multi-Tier/
│
├── app.py
├── requirements.txt
├── README.md
│
├── templates/
│   └── index.html
│
├── static/
│   ├── css/
│   └── js/
│
├── sql/
│   ├── 01-migrate-products.sql
│   ├── 02-seed-catalog.sql
│   └── 03-create-app-user.sql
│
├── deploy/
│   ├── cloudstore.service
│   └── cloudstore-nginx.conf
│
└── docs/
    ├── CloudStore_AWS_Multi_Tier_Project_Documentation_With_Cover.pdf
    └── CloudStore_AWS_Multi_Tier_Project_Documentation_With_Cover.docx
```

## Project Documentation

The complete project documentation, including implementation details and supporting screenshots, is available below:

- [Complete Project Documentation (PDF)](docs/CloudStore_AWS_Multi_Tier_Project_Documentation_With_Cover.pdf)
- [Editable Project Documentation (DOCX)](docs/CloudStore_AWS_Multi_Tier_Project_Documentation_With_Cover.docx)

## Deployment Overview

1. Create the VPC, public subnets, and private subnets.
2. Configure the required Security Groups.
3. Create the Amazon RDS MySQL database.
4. Prepare the EC2 application servers.
5. Configure Flask, Gunicorn, and Nginx.
6. Configure database connectivity and application environment variables.
7. Create the Application Load Balancer and Target Group.
8. Configure the Launch Template and Auto Scaling Group.
9. Validate application health and database connectivity.
10. Test application access through the ALB DNS endpoint.

Refer to the project documentation for detailed configuration and deployment instructions.

## Important Security Notice

This repository is intended for educational and portfolio demonstration purposes.

- Never commit `.env` files, database passwords, access keys, private keys, or sensitive customer data.
- Use AWS IAM roles and Secrets Manager for secure credential management.
- Review AWS resource costs before deploying infrastructure.
- Demo checkout does not process real payments.

## Author

**Vishal B.**

Cloud & Cybersecurity Enthusiast | CEH Certified | AWS Cloud Projects

- GitHub: [VishalGit2026](https://github.com/VishalGit2026)

---

*Built as a hands-on AWS cloud architecture and deployment project.*