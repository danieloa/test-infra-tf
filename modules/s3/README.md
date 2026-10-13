# S3 Module

This module implements the unified S3 bucket pattern matching `core/s3.go`:
- **Server-Side Encryption:** AES256 / SSE-S3 with bucket key enabled
- **Versioning:** Enabled by default
- **Lifecycle Configuration:**
  - Transition non-current versions to `STANDARD_IA` after 90 days
  - Transition non-current versions to `GLACIER` after 180 days
  - Expire non-current versions after 270 days
- **Ownership Controls:** `BucketOwnerPreferred`
- **Security:** Public access block automatically applied for private buckets
- **CORS:** Optional CORS configuration for public web assets
