---
name: API Design Patterns
description: REST, GraphQL, tRPC patterns and best practices
---

# API Design Patterns

Modern API design for REST, GraphQL, and tRPC.

## REST API

### Resource Naming

```
✅ Good:
GET    /api/users
GET    /api/users/:id
POST   /api/users
PUT    /api/users/:id
PATCH  /api/users/:id
DELETE /api/users/:id

❌ Bad:
GET    /api/getUsers
POST   /api/createUser
GET    /api/user/:id
```

### Status Codes

```
200 OK - Success
201 Created - Resource created
204 No Content - Success, no body
400 Bad Request - Invalid input
401 Unauthorized - Not authenticated
403 Forbidden - Authenticated but not allowed
404 Not Found - Resource doesn't exist
409 Conflict - Resource conflict
422 Unprocessable Entity - Validation error
500 Internal Server Error - Server error
```

### Pagination

```typescript
// Offset-based
GET /api/users?page=2&limit=20

// Cursor-based (preferred)
GET /api/users?cursor=abc123&limit=20

// Response
{
  "data": [...],
  "pagination": {
    "next": "def456",
    "prev": "xyz789",
    "hasMore": true
  }
}
```

### Filtering and Sorting

```
GET /api/users?role=admin&sort=createdAt:desc
GET /api/posts?author=123&status=published
```

### Versioning

```
# URL versioning (simple)
GET /api/v1/users

# Header versioning (cleaner URLs)
GET /api/users
Accept: application/vnd.myapp.v1+json
```

## GraphQL

### Schema Design

```graphql
type User {
  id: ID!
  email: String!
  name: String
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String
  author: User!
  published: Boolean!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
  post(id: ID!): Post
  posts(authorId: ID): [Post!]!
}

type Mutation {
  createUser(email: String!, name: String): User!
  updateUser(id: ID!, name: String): User!
  deleteUser(id: ID!): Boolean!
}
```

### Resolvers

```typescript
const resolvers = {
  Query: {
    user: async (_parent, { id }, context) => {
      return context.db.user.findUnique({ where: { id } });
    },
    users: async (_parent, { limit = 10, offset = 0 }, context) => {
      return context.db.user.findMany({
        take: limit,
        skip: offset
      });
    }
  },
  Mutation: {
    createUser: async (_parent, { email, name }, context) => {
      return context.db.user.create({
        data: { email, name }
      });
    }
  },
  User: {
    posts: async (parent, _args, context) => {
      return context.db.post.findMany({
        where: { authorId: parent.id }
      });
    }
  }
};
```

### N+1 Prevention

```typescript
import DataLoader from 'dataloader';

const userLoader = new DataLoader(async (ids) => {
  const users = await db.user.findMany({
    where: { id: { in: ids } }
  });
  return ids.map(id => users.find(u => u.id === id));
});

// In resolver
const posts = await context.loaders.user.loadMany(authorIds);
```

## tRPC

### Router Definition

```typescript
import { z } from 'zod';
import { router, publicProcedure } from './trpc';

export const appRouter = router({
  user: {
    get: publicProcedure
      .input(z.object({ id: z.string() }))
      .query(async ({ input, ctx }) => {
        return ctx.db.user.findUnique({
          where: { id: input.id }
        });
      }),

    create: publicProcedure
      .input(z.object({
        email: z.string().email(),
        name: z.string().optional()
      }))
      .mutation(async ({ input, ctx }) => {
        return ctx.db.user.create({ data: input });
      }),

    list: publicProcedure
      .input(z.object({
        limit: z.number().default(10),
        cursor: z.string().optional()
      }))
      .query(async ({ input, ctx }) => {
        const users = await ctx.db.user.findMany({
          take: input.limit + 1,
          cursor: input.cursor ? { id: input.cursor } : undefined
        });

        let nextCursor: string | undefined;
        if (users.length > input.limit) {
          const next = users.pop();
          nextCursor = next!.id;
        }

        return { users, nextCursor };
      })
  }
});

export type AppRouter = typeof appRouter;
```

### Client Usage

```typescript
import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from './server';

const client = createTRPCProxyClient<AppRouter>({
  links: [
    httpBatchLink({
      url: 'http://localhost:3000/api/trpc',
    }),
  ],
});

// Type-safe calls
const user = await client.user.get.query({ id: '123' });
const newUser = await client.user.create.mutate({
  email: 'user@example.com',
  name: 'John Doe'
});
```

## Authentication

### JWT Pattern

```typescript
import jwt from 'jsonwebtoken';

// Generate token
function generateToken(userId: string) {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET!,
    { expiresIn: '7d' }
  );
}

// Verify middleware
function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

## Best Practices

✅ **Do**:
- Use proper HTTP methods and status codes
- Version your API
- Implement pagination
- Validate all inputs
- Use consistent naming
- Document with OpenAPI/GraphQL schema
- Rate limit endpoints
- Use HTTPS everywhere

❌ **Don't**:
- Expose internal IDs unnecessarily
- Return sensitive data
- Skip input validation
- Ignore security headers
- Use GET for mutations
- Return huge responses without pagination
