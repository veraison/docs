# Error Handling Guide

This guide documents common error scenarios and their handling across Veraison documentation and demos.

## Common Error Scenarios

### 1. Invalid Token Format

**Scenario**: Evidence token is malformed or uses incorrect encoding.

**Detection**:
```
Error: failed to decode token: invalid format
```

**Resolution**:
- Verify token is properly base64-encoded
- Check token structure matches expected format (CoRIM, PSA, CCA)
- Validate JSON structure for claims

**Prevention**:
- Use provided templates in `demo/*/data/templates/`
- Validate tokens before submission

### 2. Missing Endorsements

**Scenario**: Reference values or endorsements not provisioned before verification.

**Detection**:
```
Error: no matching reference values found
Error: endorsement not found for platform
```

**Resolution**:
1. Provision endorsements first using the provisioning API
2. Verify endorsement was accepted: check API response
3. Confirm evidence fields match provisioned reference values

**Order of Operations**:
```bash
# 1. Provision endorsements
curl -X POST http://localhost:8888/endorsement-provisioning/v1/submit \
  -H "Content-Type: application/corim-unsigned+cbor; profile=http://arm.com/psa/iot/1" \
  -d @corim.cbor

# 2. Verify evidence
curl -X POST http://localhost:8080/challenge-response/v1/newSession
```

### 3. Network Connectivity Issues

**Scenario**: Services cannot communicate with each other.

**Detection**:
```
Error: connection refused
Error: dial tcp: lookup failed
```

**Resolution**:
- Check all services are running: `docker compose ps`
- Verify network configuration in docker-compose.yml
- Check firewall rules
- Use service names (not localhost) in Docker network

### 4. Certificate/Key Errors

**Scenario**: Invalid or missing cryptographic keys.

**Detection**:
```
Error: failed to verify signature
Error: certificate verification failed
```

**Resolution**:
- Verify key files exist in `demo/*/data/keys/`
- Check key format matches expected type (EC256, EC384, etc.)
- Ensure public/private key pairs match
- Validate key permissions (should be readable)

### 5. Schema Validation Errors

**Scenario**: API requests fail schema validation.

**Detection**:
```
Error: invalid request: missing required field
Error: schema validation failed
```

**Resolution**:
- Review OpenAPI specifications in `api/*/schemas/`
- Check request Content-Type headers
- Validate JSON/CBOR structure
- Use provided templates as reference

## Error Handling Best Practices

### For Demo Users

1. **Check Prerequisites**:
   ```bash
   ./scripts/validate-setup.sh
   ```

2. **Start Services in Order**:
   ```bash
   # Start verification services first
   docker compose up -d
   
   # Wait for health checks
   ./scripts/healthcheck.sh http://localhost:8080/health
   
   # Then proceed with provisioning
   ```

3. **Enable Verbose Logging**:
   ```bash
   # Add to docker-compose.yml environment
   VERAISON_LOG_LEVEL: debug
   ```

4. **Capture Logs**:
   ```bash
   docker compose logs > debug.log
   ```

### For Contributors

1. **Validate Before Commit**:
   ```bash
   make validate
   make shellcheck
   ```

2. **Test Error Paths**:
   - Include negative test cases
   - Document expected error messages
   - Test with invalid inputs

3. **Document Error Messages**:
   - Clear, actionable error messages
   - Include context and suggested fixes
   - Reference relevant documentation

## API Error Responses

### Standard Error Format

```json
{
  "error": "brief error description",
  "detail": "detailed explanation of what went wrong",
  "status": 400,
  "suggestion": "what to do next"
}
```

### Common HTTP Status Codes

- `400 Bad Request`: Invalid input data, schema validation failure
- `401 Unauthorized`: Missing or invalid authentication
- `404 Not Found`: Resource (endorsement, session) not found
- `409 Conflict`: Resource already exists
- `500 Internal Server Error`: Service error, check logs
- `503 Service Unavailable`: Service not ready, retry later

## Debugging Tips

### Enable Debug Mode

For shell scripts:
```bash
bash -x ./scripts/setup.sh
```

For Docker services:
```yaml
environment:
  DEBUG: "1"
  LOG_LEVEL: "debug"
```

### Inspect Service State

```bash
# Check service health
docker compose ps

# View service logs
docker compose logs -f <service>

# Execute commands in container
docker compose exec <service> sh

# Inspect network
docker network inspect <network-name>
```

### Validate Data Files

```bash
# Check JSON syntax
jq . < data/templates/psa-claims.json

# Validate CBOR (requires cbor-diag)
cbor2diag < data.cbor

# Check file permissions
ls -la data/keys/
```

## Reporting Issues

When reporting errors, include:

1. **Environment Information**:
   ```bash
   ./scripts/validate-setup.sh
   docker --version
   docker compose version
   ```

2. **Complete Error Messages**:
   - Full command that failed
   - Complete error output
   - Relevant log excerpts

3. **Steps to Reproduce**:
   - Starting state
   - Exact commands run
   - Expected vs actual behavior

4. **Context**:
   - Which demo (PSA, CCA)
   - Platform (Ubuntu, macOS, Windows/WSL)
   - Any modifications made

Report issues at: https://github.com/veraison/docs/issues
