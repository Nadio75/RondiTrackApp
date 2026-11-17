# RondiTrack API Contract — Assignment 11.1

Backend commit:
8500c796d886a540b5c0ca608595f85fe73ff71e

OpenAPI snapshot: contract/openapi/v1.json

## 1. Pagination
Members and cycle contributions:
- Query: page_size and page_token.
- Default page size: 20.
- Maximum page size: 100.
- Negative page_size: HTTP 400.
- page_token is opaque.
- Empty nextPageToken indicates the final page.

Activity and contribution history use camelCase pageSize/pageToken.
Contribution history also accepts from/to filters.
Other endpoint-specific pagination behavior requires verification.

## 2. Optimistic concurrency
Payout GET returns PostgreSQL xmin as version.
Payout PUT requires the returned version.
A stale version produces HTTP 409 Conflict.
No ETag or If-Match contract was identified.

## 3. Status strings
Status values are case-sensitive.
The complete set of backend values remains to be verified.
Clients must handle unknown status strings without crashing.

## 4. Authentication refresh
Refresh cookie: ronditrack_refresh.
Refresh lifetime: 7 days.
Access token lifetime: 900 seconds.
Refresh rotation grace: 2 seconds.
Duplicate refresh within the grace window still returns 401.
Cookie: HttpOnly, Secure, SameSite=Strict.

## 5. Error correlation
Backend ProblemDetails includes correlationId.
The OpenAPI snapshot does not explicitly document this extension.
Clients should preserve correlationId for troubleshooting.

## 6. Authorization
Nonmembers receive 404.
Members without sufficient permission receive 403.
Missing stokvels receive 404.
Authentication failures may produce 401.

## 7. Rate limiting
Login: 5 requests per 60 seconds per IP by default.
Financial: 30 requests per 60 seconds per user by default.
Limits are configurable.
HTTP 429 includes Retry-After and ProblemDetails.
Clients should respect Retry-After and avoid retry storms.

## Integration considerations
- Development API currently runs on http://localhost:5056.
- Secure refresh cookies require a suitable HTTPS development setup.
- Never commit passwords, refresh tokens or access tokens.
- Preserve fake repositories as test overrides.
