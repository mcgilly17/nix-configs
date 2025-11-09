---
name: TypeScript Patterns
description: Advanced types, strict mode, type safety
---

# TypeScript Development Patterns

Advanced TypeScript patterns for type-safe code.

## Strict Mode

Enable all strict checks in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true
  }
}
```

## Basic Types

```typescript
// Primitives
const name: string = "John";
const age: number = 30;
const isActive: boolean = true;

// Arrays
const numbers: number[] = [1, 2, 3];
const names: Array<string> = ["Alice", "Bob"];

// Tuples
const tuple: [string, number] = ["Alice", 30];

// Objects
const user: { name: string; age: number } = {
  name: "Alice",
  age: 30
};
```

## Advanced Types

### Union Types

```typescript
type Status = "pending" | "success" | "error";
type ID = string | number;

function handleStatus(status: Status) {
  // TypeScript knows status can only be those 3 values
}
```

### Intersection Types

```typescript
type Person = { name: string };
type Employee = { employeeId: number };

type Worker = Person & Employee;

const worker: Worker = {
  name: "Alice",
  employeeId: 123
};
```

### Type Guards

```typescript
function isString(value: unknown): value is string {
  return typeof value === "string";
}

function process(value: string | number) {
  if (isString(value)) {
    // TypeScript knows value is string here
    return value.toUpperCase();
  }
  // TypeScript knows value is number here
  return value.toFixed(2);
}
```

### Discriminated Unions

```typescript
type Success = { status: "success"; data: string };
type Error = { status: "error"; error: string };
type Loading = { status: "loading" };

type State = Success | Error | Loading;

function handleState(state: State) {
  switch (state.status) {
    case "success":
      return state.data; // TypeScript knows data exists
    case "error":
      return state.error; // TypeScript knows error exists
    case "loading":
      return "Loading...";
  }
}
```

## Generics

### Basic Generics

```typescript
function identity<T>(value: T): T {
  return value;
}

const num = identity(42); // number
const str = identity("hello"); // string
```

### Generic Constraints

```typescript
function getLength<T extends { length: number }>(item: T): number {
  return item.length;
}

getLength("hello"); // OK
getLength([1, 2, 3]); // OK
getLength(42); // Error: number has no length
```

### Generic Interfaces

```typescript
interface APIResponse<T> {
  data: T;
  status: number;
  error?: string;
}

const userResponse: APIResponse<User> = {
  data: { id: 1, name: "Alice" },
  status: 200
};
```

## Utility Types

### Partial

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

// All properties optional
type PartialUser = Partial<User>;

function updateUser(id: number, updates: Partial<User>) {
  // Can update any subset of User properties
}
```

### Pick

```typescript
// Select subset of properties
type UserPreview = Pick<User, "id" | "name">;
```

### Omit

```typescript
// Exclude properties
type UserWithoutEmail = Omit<User, "email">;
```

### Required

```typescript
interface Config {
  host?: string;
  port?: number;
}

// All properties required
type RequiredConfig = Required<Config>;
```

### Record

```typescript
type UserRoles = Record<string, string[]>;

const roles: UserRoles = {
  admin: ["read", "write", "delete"],
  user: ["read"]
};
```

### ReturnType

```typescript
function getUser() {
  return { id: 1, name: "Alice" };
}

type User = ReturnType<typeof getUser>; // { id: number; name: string }
```

## Mapped Types

```typescript
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

type Nullable<T> = {
  [P in keyof T]: T[P] | null;
};

interface User {
  id: number;
  name: string;
}

type ReadonlyUser = Readonly<User>;
type NullableUser = Nullable<User>;
```

## Conditional Types

```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<string>; // true
type B = IsString<number>; // false

// More complex
type Flatten<T> = T extends Array<infer U> ? U : T;

type Num = Flatten<number[]>; // number
type Str = Flatten<string>; // string
```

## Template Literal Types

```typescript
type HTTPMethod = "GET" | "POST" | "PUT" | "DELETE";
type Endpoint = `/api/${string}`;

type APIRoute = `${HTTPMethod} ${Endpoint}`;

const route: APIRoute = "GET /api/users"; // OK
const invalid: APIRoute = "PATCH /api/users"; // Error
```

## Type Inference

```typescript
// Let TypeScript infer when possible
const user = {
  id: 1,
  name: "Alice"
}; // Type is inferred

// Explicit when needed
const users: User[] = [];

// Generic inference
function map<T, U>(items: T[], fn: (item: T) => U): U[] {
  return items.map(fn);
}

const lengths = map(["a", "ab", "abc"], s => s.length); // number[]
```

## Null Safety

```typescript
// Use strict null checks
let value: string | null = null;

// Optional chaining
const length = value?.length; // number | undefined

// Nullish coalescing
const name = value ?? "default";

// Non-null assertion (use sparingly!)
const definitelyExists = value!.length;
```

## Index Signatures

```typescript
interface StringMap {
  [key: string]: string;
}

const config: StringMap = {
  host: "localhost",
  port: "3000"
};

// With noUncheckedIndexedAccess
const port = config["port"]; // string | undefined
```

## Function Overloads

```typescript
function process(value: string): string;
function process(value: number): number;
function process(value: string | number): string | number {
  if (typeof value === "string") {
    return value.toUpperCase();
  }
  return value * 2;
}

const str = process("hello"); // string
const num = process(42); // number
```

## Type Assertions

```typescript
// As syntax (preferred)
const canvas = document.getElementById("canvas") as HTMLCanvasElement;

// Angle bracket (avoid in TSX)
const canvas = <HTMLCanvasElement>document.getElementById("canvas");

// Double assertion (last resort)
const value = (unknown as any) as MyType;
```

## Enums

```typescript
// Numeric enum
enum Status {
  Pending,
  Success,
  Error
}

// String enum (preferred)
enum Color {
  Red = "RED",
  Green = "GREEN",
  Blue = "BLUE"
}

// Const enum (inlined at compile time)
const enum Direction {
  Up,
  Down,
  Left,
  Right
}
```

## Type Narrowing

```typescript
function example(value: string | number | null) {
  // typeof narrowing
  if (typeof value === "string") {
    return value.toUpperCase();
  }

  // Truthiness narrowing
  if (value) {
    return value.toFixed(2);
  }

  // Equality narrowing
  if (value === null) {
    return "null";
  }
}
```

## Best Practices

✅ **Do**:
- Enable strict mode
- Use `unknown` instead of `any`
- Leverage type inference
- Use discriminated unions for complex state
- Prefer interfaces for objects
- Use type aliases for unions/intersections
- Add return types to public APIs

❌ **Don't**:
- Use `any` (use `unknown` instead)
- Overuse type assertions
- Ignore TypeScript errors
- Use `as any` to bypass errors
- Use `!` (non-null assertion) without understanding
- Define types for everything (let inference work)

## Common Patterns

### Result Type

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function divide(a: number, b: number): Result<number> {
  if (b === 0) {
    return { ok: false, error: new Error("Division by zero") };
  }
  return { ok: true, value: a / b };
}
```

### Builder Pattern

```typescript
class QueryBuilder {
  private query = "";

  where(condition: string): this {
    this.query += ` WHERE ${condition}`;
    return this;
  }

  orderBy(field: string): this {
    this.query += ` ORDER BY ${field}`;
    return this;
  }

  build(): string {
    return this.query;
  }
}
```

### Type-safe Event Emitter

```typescript
type Events = {
  userCreated: { id: number; name: string };
  userDeleted: { id: number };
};

class TypedEmitter<T extends Record<string, any>> {
  on<K extends keyof T>(event: K, handler: (data: T[K]) => void) {
    // Implementation
  }

  emit<K extends keyof T>(event: K, data: T[K]) {
    // Implementation
  }
}

const emitter = new TypedEmitter<Events>();
emitter.on("userCreated", data => {
  // data is typed as { id: number; name: string }
});
```

## Anti-Patterns

❌ **Using `any` everywhere**
❌ **Ignoring compiler errors**
❌ **Over-using type assertions**
❌ **Not enabling strict mode**
❌ **Defining types for simple inferred values**
