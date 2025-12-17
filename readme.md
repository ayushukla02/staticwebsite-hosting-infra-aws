<div align="center">

# ☁️ AWS Serverless Static Website Hosting
### Secure. Automated. Scalable.

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

<p align="center">
  <a href="#-project-overview">Overview</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-setup--deployment-guide">Setup Guide</a> •
  <a href="#-troubleshooting-common-issues">Troubleshooting</a>
</p>

</div>

---

## 📖 Project Overview

This project provisions a secure, enterprise-grade static website infrastructure on AWS using **Terraform** and creates a fully automated CI/CD pipeline with **GitHub Actions**.

It moves beyond basic hosting by implementing **Zero-Trust security** principles:
* 🔒 **Private S3 Storage:** The bucket is not public; it is accessed only via CloudFront.
* 🛡️ **OAC (Origin Access Control):** Ensures only your specific CloudFront distribution can access your data.
* 🔑 **OIDC Authentication:** Eliminates the need for long-lived AWS Access Keys in GitHub Secrets.

---

## 🏗 Architecture

Since Mermaid diagrams can be inconsistent, here is the visual flow of the infrastructure:

```text
                                  🌐 Public Internet
                                         │
                                         ▼
                                [ 🚦 Route 53 DNS ]
                                         │
                                         ▼
                               [ ⚡ CloudFront CDN ]
                                 (Edge Locations)
                                         │
                                         │ (Signed Request via OAC)
                                         ▼
    ┌──────────────────────────────────────────────────────────────────┐
    │  ☁️ AWS Cloud                                                    │
    │                                                                  │
    │   [ 🔒 S3 Bucket (Private Origin) ] ◀───┐                        │
    │       (Stores HTML/CSS/JS)              │                        │
    │                                         │ (Sync Files)           │
    └─────────────────────────────────────────┼────────────────────────┘
                                              │
                                              │
                                     [ 🐙 GitHub Actions ]
                                     (Build & Deploy Pipeline)
```
---

## 🛠 Tech Stack

| Component          | Technology     | Description                                          |
| ------------------ | -------------- | ---------------------------------------------------- |
| **Infrastructure** | Terraform      | State management and resource provisioning.          |
| **CDN**            | AWS CloudFront | Global edge network for low-latency delivery.        |
| **Storage**        | AWS S3         | Object storage with Versioning enabled for rollback. |
| **Security**       | AWS ACM        | Automated SSL/TLS certificate management.            |
| **Identity**       | AWS IAM (OIDC) | Passwordless authentication for GitHub Actions.      |
| **DNS**            | AWS Route 53   | Authoritative DNS management.                        |
| **CI/CD**          | GitHub Actions | Automated build, sync, and cache invalidation.       |

---

## 📂 Project Structure

```bash
├── .github/
│   └── workflows/
│       └── deploy.yml   # 🤖 CI/CD Pipeline logic
├── terraform/           # 🏗️ Infrastructure Code
│   ├── main.tf          # Core resources (S3, CloudFront, Route53)
│   ├── iam.tf           # OIDC Trust Policy & Roles
│   ├── providers.tf     # AWS Provider config
│   ├── variables.tf     # Custom configuration
│   └── outputs.tf       # Resource IDs (needed for CI/CD)
└── website/             # 🌐 The actual website content
    └── index.html
```

---

# 🚀 Setup & Deployment Guide

This document outlines the step-by-step procedure to provision the AWS infrastructure and set up the automated CI/CD pipeline for the Serverless Static Website.

## ✅ Prerequisites

Before starting, ensure you have the following ready:

1.  **AWS Account:** You need active Access Key & Secret Key configured locally.
2.  **Terraform:** Installed on local machine (v1.5+).
    - _Verify:_ `terraform version`
3.  **Domain Name:** Purchased from a registrar (e.g., Hostinger, GoDaddy).
4.  **GitHub Repository:** An empty public or private repository created on GitHub.
5.  **AWS CLI (Optional but recommended):** For debugging credentials.
    - _Verify:_ `aws sts get-caller-identity`

---

## Phase 1: Domain Preparation (Manual Step)

_Objective: Transfer DNS management from your registrar (e.g., Hostinger) to AWS Route 53 to utilize Alias records._

1.  **Create Hosted Zone in AWS:**

    - Log in to the **AWS Console** > **Route 53** > **Hosted zones**.
    - Click **Create hosted zone**.
    - **Domain name:** Enter your exact domain (e.g., `yourdomain.com`).
    - **Type:** Public hosted zone.
    - Click **Create**.

2.  **Retrieve Name Servers:**

    - Open your new Hosted Zone > **NS** (Name Server) record.
    - Copy the 4 values listed (e.g., `ns-123.awsdns-45.com`).

3.  **Update Registrar (e.g., Hostinger):**
    - Log in to your domain registrar's dashboard.
    - Navigate to **DNS / Nameservers**.
    - Select **Change Nameservers** -> **Custom Nameservers**.
    - Paste the 4 AWS Name Servers you copied.
    - **Save**.
    - **Note:** DNS propagation can take anywhere from 15 minutes to 24 hours. Verify it from https://dnschecker.org/.

---

## Phase 2: Provision Infrastructure (Terraform)

_Objective: Use Infrastructure as Code to build the S3 Bucket, CloudFront Distribution, ACM Certificate, and OIDC roles._

1.  **Clone the Repository:**

    ```bash
    git clone https://github.com/ayushukla02/staticwebsite-hosting-infra-aws.git
    cd staticwebsite-hosting-infra-aws/terraform


    ```

2.  **Initialize Terraform:**
    Downloads the necessary AWS provider plugins.

    ```bash
    terraform init
    ```

3.  **Configure Variables:**
    Create a file named `terraform.tfvars` in the `terraform/` directory:

    ```hcl
    # /terraform.tfvars

    domain_name = "yourdomain.com"       # Your domain address of website (ie. ayushukla.com)
    bucket_name = "yourdomain.com"       # Bucket name for website (must same as domain name ie. ayushukla.com)
    aws_region  = "ap-south-1"           # Setup region (e.g., Mumbai)
    github_repo = "YourUsername/RepoName" # (Name of your GitHub repository)
    ```

4.  **Plan and Apply:**
    Preview the changes and then apply them.

    ```bash
    terraform plan
    terraform apply
    ```

    - Type `yes` when prompted.
    - _Wait:_ Creating the CloudFront distribution and other resources typically takes **10-15 minutes**.

    - _Note:_ If you get an error about the CloudFront distribution not being ready, wait a few minutes and try again.

    - _Note:_ 4. Verification
      Once Terraform finishes:

                            Go to the S3 Console. You will see an empty bucket.

                            - **Manual Testing (Optional, if skipping Phase 3):** Upload your `index.html` manually to the S3 bucket (`yourdomain.com`) to test your deployment.
                            - Visit `https://yourdomain.com` to verify.

5.  **Save Outputs:**
    Once finished, Terraform will output critical values. **Keep this terminal open** or copy these values to a notepad:
    - `github_role_arn`
    - `cloudfront_distribution_id`
    - `s3_bucket_name`

---

## Phase 3: Configure Automation (GitHub Actions - optional )

_Objective: Connect your GitHub repository to AWS securely using OIDC._

1.  **Open GitHub Secrets:**

    - Go to your GitHub Repository.
    - Click **Settings** > **Secrets and variables** > **Actions**.
    - Click **New repository secret**.

2.  **Add the Required Secrets:**
    Add the following 4 secrets exactly as named:

    | Secret Name          | Value Source                                            |
    | :------------------- | :------------------------------------------------------ |
    | `AWS_ROLE_ARN`       | The `github_role_arn` output from Terraform.            |
    | `AWS_REGION`         | The region you used (e.g., `ap-south-1`).               |
    | `S3_BUCKET_NAME`     | The `s3_bucket_name` output from Terraform.             |
    | `CLOUDFRONT_DIST_ID` | The `cloudfront_distribution_id` output from Terraform. |

---

## Phase 4: Deploy Your Site

_Objective: Push new code changes to trigger the pipeline._

1.  **Push to GitHub:**

    ```bash
    git add .
    git commit -m "New changes to website"
    git push origin main
    ```

2.  **Verify Deployment:**

    - Go to the **Actions** tab in your GitHub repository.
    - Click on the running workflow.
    - Wait for the "Deploy" and "Invalidate CloudFront" steps to turn green ✅.

3.  **Visit Your Site:**
    Open `https://yourdomain.com` in your browser. You should see your HTML content secured with a lock icon 🔒.

---

## 🔧 Troubleshooting Common Issues

**1. Terraform Error: "Certificate validation timed out"**

- **Cause:** DNS propagation hasn't finished, or you didn't update nameservers in Hostinger correctly.
- **Fix:** Check your domain on [dnschecker.org](https://dnschecker.org/ns-lookup.php). If NS records don't show AWS servers, wait longer or re-check Hostinger settings.

**2. GitHub Action Error: "Not authorized to perform sts:AssumeRoleWithWebIdentity"**

- **Cause:** The `github_repo` variable in `terraform.tfvars` is wrong or case-sensitive.
- **Fix:** Ensure it matches exactly `User/Repo`. If you change it, run `terraform apply` again.

**3. Website Access Denied (403 Forbidden)**

- **Cause:** CloudFront OAC settings might not be synced with the S3 policy.
- **Fix:** Ensure the Terraform apply completed successfully. Verify that the S3 Bucket Policy allows `cloudfront.amazonaws.com`.

## 💰 Cost Estimation

- **Route 53:** ~$0.50 per month per Hosted Zone.
- **S3 & CloudFront:** Eligible for AWS Free Tier (Standard limits apply).
- **ACM Certificates:** Free for public domains.

📜 License
This project is open-source and available under the [MIT License](https://opensource.org/licenses/MIT).
