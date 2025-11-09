---
name: React Patterns
description: Modern React patterns, hooks, Server/Client components, performance
---

# React Development Patterns

Modern React patterns and best practices for 2025.

## Hooks

### useState

```typescript
// Simple state
const [count, setCount] = useState(0);

// With function updater (safer for async)
setCount(prev => prev + 1);

// Lazy initialization (expensive computation)
const [data, setData] = useState(() => {
  return expensiveComputation();
});
```

### useEffect

```typescript
// Run once on mount
useEffect(() => {
  fetchData();
}, []);

// Run when dependencies change
useEffect(() => {
  const subscription = api.subscribe(userId);
  return () => subscription.unsubscribe(); // Cleanup
}, [userId]);

// ❌ Don't forget cleanup for subscriptions, timers, listeners
```

### useRef

```typescript
// DOM reference
const inputRef = useRef<HTMLInputElement>(null);
inputRef.current?.focus();

// Persist value across renders (doesn't cause re-render)
const countRef = useRef(0);
countRef.current += 1;
```

### useMemo

```typescript
// Expensive computation
const sortedUsers = useMemo(() => {
  return users.sort((a, b) => a.name.localeCompare(b.name));
}, [users]);

// ✅ Use when computation is expensive
// ❌ Don't use for cheap operations - adds overhead
```

### useCallback

```typescript
const handleClick = useCallback(() => {
  doSomething(value);
}, [value]);

// Pass to child to prevent re-renders
<ChildComponent onClick={handleClick} />
```

### Custom Hooks

```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}

// Usage
const [theme, setTheme] = useLocalStorage('theme', 'light');
```

## Server vs Client Components

### When to Use Server Components

✅ **Use Server Components for**:
- Data fetching
- Backend logic
- Direct database access
- Secret keys
- Large dependencies
- SEO-critical content

```tsx
// Server Component (no 'use client')
async function UserList() {
  const users = await db.user.findMany();
  return <div>{users.map(user => <UserCard key={user.id} user={user} />)}</div>;
}
```

### When to Use Client Components

✅ **Use Client Components for**:
- Interactivity (onClick, onChange)
- State (useState, useReducer)
- Effects (useEffect)
- Browser APIs (window, localStorage)
- Event listeners
- Custom hooks that use state/effects

```tsx
'use client';

function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

### Composition Pattern

```tsx
// Server Component
async function Page() {
  const data = await fetchData();

  return (
    <div>
      <StaticHeader data={data} /> {/* Server */}
      <InteractiveSection data={data} /> {/* Client */}
    </div>
  );
}

// Client Component
'use client';
function InteractiveSection({ data }) {
  const [selected, setSelected] = useState(null);
  return <div onClick={() => setSelected(data[0])}>{/* ... */}</div>;
}
```

## Performance Optimization

### React.memo

```typescript
const UserCard = React.memo(function UserCard({ user }) {
  return <div>{user.name}</div>;
});

// With custom comparison
const UserCard = React.memo(
  function UserCard({ user }) {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => {
    return prevProps.user.id === nextProps.user.id;
  }
);
```

### Virtualization for Long Lists

```typescript
import { FixedSizeList } from 'react-window';

function UserList({ users }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={users.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>{users[index].name}</div>
      )}
    </FixedSizeList>
  );
}
```

### Code Splitting

```typescript
// Lazy load component
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  );
}
```

## Component Patterns

### Compound Components

```typescript
const Tabs = ({ children }) => {
  const [activeIndex, setActiveIndex] = useState(0);

  return (
    <TabsContext.Provider value={{ activeIndex, setActiveIndex }}>
      {children}
    </TabsContext.Provider>
  );
};

const TabList = ({ children }) => <div role="tablist">{children}</div>;
const Tab = ({ index, children }) => {
  const { activeIndex, setActiveIndex } = useTabsContext();
  return (
    <button onClick={() => setActiveIndex(index)}>
      {children}
    </button>
  );
};
const TabPanel = ({ index, children }) => {
  const { activeIndex } = useTabsContext();
  return activeIndex === index ? <div>{children}</div> : null;
};

// Usage
<Tabs>
  <TabList>
    <Tab index={0}>Tab 1</Tab>
    <Tab index={1}>Tab 2</Tab>
  </TabList>
  <TabPanel index={0}>Content 1</TabPanel>
  <TabPanel index={1}>Content 2</TabPanel>
</Tabs>
```

### Render Props

```typescript
function DataFetcher({ url, render }) {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch(url).then(res => res.json()).then(setData);
  }, [url]);

  return render(data);
}

// Usage
<DataFetcher
  url="/api/users"
  render={(data) => data ? <UserList users={data} /> : <Loading />}
/>
```

### Higher-Order Components (HOC)

```typescript
function withAuth<P extends object>(Component: React.ComponentType<P>) {
  return function AuthComponent(props: P) {
    const { user } = useAuth();

    if (!user) {
      return <Redirect to="/login" />;
    }

    return <Component {...props} />;
  };
}

// Usage
const ProtectedPage = withAuth(DashboardPage);
```

## State Management

### Context API

```typescript
const ThemeContext = createContext<{
  theme: string;
  setTheme: (theme: string) => void;
} | null>(null);

function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
}
```

### useReducer for Complex State

```typescript
type State = {
  count: number;
  error: string | null;
};

type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'error'; error: string };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + 1, error: null };
    case 'decrement':
      return { ...state, count: state.count - 1, error: null };
    case 'error':
      return { ...state, error: action.error };
    default:
      return state;
  }
}

function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0, error: null });

  return (
    <div>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <span>{state.count}</span>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
    </div>
  );
}
```

## Error Boundaries

```typescript
class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <div>Something went wrong: {this.state.error?.message}</div>;
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary>
  <MyComponent />
</ErrorBoundary>
```

## Forms

### Controlled Components

```typescript
function Form() {
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log(formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        name="email"
        value={formData.email}
        onChange={handleChange}
      />
      <input
        name="password"
        type="password"
        value={formData.password}
        onChange={handleChange}
      />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Uncontrolled with Refs

```typescript
function Form() {
  const emailRef = useRef<HTMLInputElement>(null);
  const passwordRef = useRef<HTMLInputElement>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const email = emailRef.current?.value;
    const password = passwordRef.current?.value;
    console.log({ email, password });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input ref={emailRef} name="email" />
      <input ref={passwordRef} name="password" type="password" />
      <button type="submit">Submit</button>
    </form>
  );
}
```

## Testing Patterns

### Component Testing

```typescript
import { render, screen, fireEvent } from '@testing-library/react';

test('counter increments', () => {
  render(<Counter />);

  const button = screen.getByRole('button', { name: /increment/i });
  fireEvent.click(button);

  expect(screen.getByText('1')).toBeInTheDocument();
});
```

### Hook Testing

```typescript
import { renderHook, act } from '@testing-library/react';

test('useCounter increments', () => {
  const { result } = renderHook(() => useCounter());

  act(() => {
    result.current.increment();
  });

  expect(result.current.count).toBe(1);
});
```

## Best Practices

✅ **Do**:
- Keep components small and focused
- Use TypeScript for type safety
- Memoize expensive computations with useMemo
- Use useCallback for functions passed to children
- Extract custom hooks for reusable logic
- Use Suspense for loading states
- Implement error boundaries

❌ **Don't**:
- Mutate state directly
- Use indexes as keys in lists
- Forget cleanup in useEffect
- Over-optimize with memo/useMemo/useCallback
- Use 'use client' at root unnecessarily
- Fetch data in useEffect (use Server Components instead)

## Anti-Patterns

❌ **Massive components** - Break into smaller pieces
❌ **Prop drilling** - Use Context or composition
❌ **useEffect for derived state** - Use useMemo instead
❌ **Premature optimization** - Measure first
❌ **Ignoring React DevTools** - Use profiler
