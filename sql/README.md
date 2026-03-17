# Database

Cloudflare D1 database files and migrations.

## Files

- `schema.sql` - Database schema (tables, indexes, views)
- `migrations/` - Database migrations (future)
- `seeds/` - Seed data for development (future)

## Usage

### Create Database

```bash
wrangler d1 create jinbeibei-db
```

### Apply Schema

```bash
wrangler d1 execute jinbeibei-db --file=sql/schema.sql
```

### Query Database

```bash
wrangler d1 execute jinbeibei-db --command="SELECT * FROM devices"
```

## Documentation

See [docs/database_cloudflare_d1.md](../docs/database_cloudflare_d1.md) for detailed design.
