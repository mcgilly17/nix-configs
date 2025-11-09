---
name: Prisma Patterns
description: Schema design, migrations, query optimization
---

# Prisma Development Patterns

Best practices for Prisma ORM with PostgreSQL, MySQL, and SQLite.

## Schema Design

### Models and Relations

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  posts     Post[]
  profile   Profile?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  tags      Tag[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@index([published])
}

model Profile {
  id     String @id @default(cuid())
  bio    String?
  user   User   @relation(fields: [userId], references: [id])
  userId String @unique
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}
```

### Relation Types

**One-to-One**:
```prisma
model User {
  profile Profile?
}

model Profile {
  user   User   @relation(fields: [userId], references: [id])
  userId String @unique
}
```

**One-to-Many**:
```prisma
model User {
  posts Post[]
}

model Post {
  author   User   @relation(fields: [authorId], references: [id])
  authorId String
}
```

**Many-to-Many**:
```prisma
model Post {
  tags Tag[]
}

model Tag {
  posts Post[]
}
```

## Migrations

### Creating Migrations

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_user_role

# Apply migrations in production
npx prisma migrate deploy

# Reset database (dev only!)
npx prisma migrate reset
```

### Migration Best Practices

✅ **Do**:
- Always review generated SQL before applying
- Name migrations descriptively
- Use `prisma migrate dev` in development
- Use `prisma migrate deploy` in production
- Commit migrations to version control

❌ **Don't**:
- Edit migration files after they're applied
- Use `migrate reset` in production
- Skip testing migrations on staging first

## Query Optimization

### Preventing N+1 Queries

```typescript
// ❌ Bad - N+1 query
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({
    where: { authorId: user.id }
  });
}

// ✅ Good - Single query with include
const users = await prisma.user.findMany({
  include: {
    posts: true
  }
});
```

### Select Only What You Need

```typescript
// ❌ Bad - Fetches all fields
const users = await prisma.user.findMany();

// ✅ Good - Select specific fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    name: true
  }
});
```

### Pagination

```typescript
// Cursor-based (recommended for large datasets)
const posts = await prisma.post.findMany({
  take: 10,
  skip: 1,
  cursor: {
    id: lastPostId
  },
  orderBy: {
    createdAt: 'desc'
  }
});

// Offset-based (simpler, but slower at scale)
const posts = await prisma.post.findMany({
  take: 10,
  skip: page * 10,
  orderBy: {
    createdAt: 'desc'
  }
});
```

### Indexing

```prisma
model User {
  email String @unique  // Automatic index

  @@index([lastName, firstName]) // Compound index
  @@index([createdAt(sort: Desc)]) // Sorted index
}
```

## Query Patterns

### Filtering

```typescript
// Simple where
const users = await prisma.user.findMany({
  where: {
    email: {
      contains: '@example.com'
    }
  }
});

// Complex where with AND/OR
const posts = await prisma.post.findMany({
  where: {
    AND: [
      { published: true },
      {
        OR: [
          { title: { contains: 'prisma' } },
          { content: { contains: 'prisma' } }
        ]
      }
    ]
  }
});
```

### Sorting

```typescript
const users = await prisma.user.findMany({
  orderBy: [
    { lastName: 'asc' },
    { firstName: 'asc' }
  ]
});
```

### Aggregations

```typescript
const stats = await prisma.post.aggregate({
  _count: true,
  _avg: { views: true },
  _sum: { views: true },
  _max: { createdAt: true }
});

// Group by
const userPostCounts = await prisma.post.groupBy({
  by: ['authorId'],
  _count: true,
  orderBy: {
    _count: {
      authorId: 'desc'
    }
  }
});
```

## Transactions

### Sequential Operations

```typescript
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: { email: 'user@example.com' } }),
  prisma.post.create({ data: { title: 'Hello' } })
]);
```

### Interactive Transactions

```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({
    data: { email: 'user@example.com' }
  });

  await tx.post.create({
    data: {
      title: 'Hello',
      authorId: user.id
    }
  });
});
```

## Type Safety

### Generated Types

```typescript
import { Prisma, User, Post } from '@prisma/client';

// Use generated types
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true }
}>;

// Validator for input
const userCreateInput = Prisma.validator<Prisma.UserCreateInput>()({
  email: 'user@example.com',
  name: 'John Doe'
});
```

### Type-safe Queries

```typescript
// TypeScript knows the shape
const user = await prisma.user.findUnique({
  where: { id: '123' },
  include: { posts: true }
});

// user.posts is typed as Post[]
```

## Connection Pooling

```typescript
// prisma/client.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: ['query', 'error', 'warn'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

## Soft Deletes

```prisma
model Post {
  id        String    @id @default(cuid())
  title     String
  deletedAt DateTime?

  @@index([deletedAt])
}
```

```typescript
// Middleware for soft deletes
prisma.$use(async (params, next) => {
  if (params.model === 'Post') {
    if (params.action === 'delete') {
      params.action = 'update';
      params.args['data'] = { deletedAt: new Date() };
    }
    if (params.action === 'findMany') {
      params.args['where'] = {
        ...params.args['where'],
        deletedAt: null
      };
    }
  }
  return next(params);
});
```

## Common Patterns

### Upsert (Update or Create)

```typescript
const user = await prisma.user.upsert({
  where: { email: 'user@example.com' },
  update: { name: 'Updated Name' },
  create: {
    email: 'user@example.com',
    name: 'New User'
  }
});
```

### Nested Writes

```typescript
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    posts: {
      create: [
        { title: 'Post 1' },
        { title: 'Post 2' }
      ]
    }
  },
  include: {
    posts: true
  }
});
```

### Batch Operations

```typescript
// Create many
await prisma.user.createMany({
  data: [
    { email: 'user1@example.com' },
    { email: 'user2@example.com' }
  ]
});

// Update many
await prisma.post.updateMany({
  where: { published: false },
  data: { published: true }
});

// Delete many
await prisma.post.deleteMany({
  where: { authorId: userId }
});
```

## Security

### Input Validation

```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100)
});

// Validate before querying
const validated = userSchema.parse(input);
await prisma.user.create({ data: validated });
```

### Prepared Statements

Prisma automatically uses prepared statements - no manual work needed!

### Row-Level Security

Use database-level RLS (PostgreSQL):
```sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_posts ON posts
  FOR ALL
  TO authenticated_user
  USING (author_id = current_user_id());
```

## Performance Tips

1. **Use indexes** on frequently queried fields
2. **Select only needed fields** - avoid fetching entire models
3. **Use cursor pagination** for large datasets
4. **Batch operations** when possible
5. **Monitor query performance** with Prisma logging
6. **Use connection pooling** (especially in serverless)
7. **Avoid N+1 queries** with includes/selects

## Anti-Patterns

❌ **Querying in loops**
❌ **Fetching all fields when you need few**
❌ **No indexes on foreign keys**
❌ **Ignoring TypeScript types**
❌ **Not using transactions for related operations**
