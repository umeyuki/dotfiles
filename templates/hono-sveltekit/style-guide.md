# TypeScript Coding Guide for Hono + SvelteKit
*Functional Programming Edition*

## 🎯 Core Principles

### Functional Programming Principles
- **No Classes**: Implement all logic with pure functions
- **Immutable**: Create new data instead of modifying existing data
- **Side Effect Separation**: Clearly separate pure functions from side effects
- **Composable**: Build complex processing by combining small functions
- **Testable**: Each function should be independently testable

### Design Philosophy
- **Pure Functions First**: Implement with pure functions whenever possible
- **Composition over Inheritance**: Use composition instead of inheritance
- **Explicit State Management**: Manage state explicitly and pass between functions
- **Type Safety**: Maximize TypeScript's type system usage

## 🏗️ Functional Code Structure

### 1. Pure Function Definition
```typescript
// ✅ Pure function - always same output for same input
export const calculateTaskPriority = (
  task: Task,
  currentTime: Date
): TaskPriority => {
  if (task.dueDate && new Date(task.dueDate) < currentTime) {
    return 'urgent'
  }
  return task.priority
}

// ✅ Immutable updates
export const updateTaskStatus = (
  task: Task,
  newStatus: TaskStatus
): Task => ({
  ...task,
  status: newStatus,
  updatedAt: new Date().toISOString()
})
```

### 2. Explicit Side Effect Separation
```typescript
// ✅ Explicitly separate side effects
export const saveTask = async (task: Task): Promise<Result<Task>> => {
  try {
    // Side effects like file I/O
    await writeFile(`./data/tasks/${task.id}.json`, JSON.stringify(task))
    return { success: true, data: task }
  } catch (error) {
    return { success: false, error: error as Error }
  }
}

// ✅ Combination of pure functions + side effect functions
export const createAndSaveTask = async (
  taskData: CreateTaskData
): Promise<Result<Task>> => {
  // Pure function for task creation
  const task = createTask(taskData)
  
  // Separate side effects
  return await saveTask(task)
}
```

### 3. Higher-Order Functions and Currying
```typescript
// ✅ Higher-order functions
export const withErrorHandling = <T, R>(
  fn: (input: T) => R
) => (input: T): Result<R> => {
  try {
    const result = fn(input)
    return { success: true, data: result }
  } catch (error) {
    return { success: false, error: error as Error }
  }
}

// ✅ Currying
export const filterTasksByUser = (userId: string) => 
  (tasks: readonly Task[]): readonly Task[] =>
    tasks.filter(task => task.userId === userId)
```

### 4. Pipeline Processing
```typescript
// ✅ Function composition and pipeline
export const pipe = <T>(...functions: Array<(arg: T) => T>) =>
  (value: T): T =>
    functions.reduce((acc, fn) => fn(acc), value)

// Usage example
export const processUserTasks = (userId: string, tasks: readonly Task[]) =>
  pipe(
    filterTasksByUser(userId),
    sortTasksByPriority,
    addEstimatedTime
  )(tasks)
```

## 🌐 Hono-Specific Patterns

### Route Handlers as Pure Functions
```typescript
// ✅ Pure route logic
export const createTaskHandler = (c: Context) => {
  const taskData = parseTaskData(c.req.json())
  
  return pipe(
    validateTaskData,
    createTask,
    formatTaskResponse
  )(taskData)
}

// ✅ Middleware as higher-order functions
export const withAuth = (handler: Handler) => 
  async (c: Context) => {
    const authResult = await validateAuth(c)
    if (!authResult.success) {
      return c.json({ error: 'Unauthorized' }, 401)
    }
    return handler(c)
  }
```

### Error Handling
```typescript
// ✅ Consistent error handling with Result type
export const handleAPIError = (error: unknown): Response => {
  if (error instanceof ValidationError) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    })
  }
  
  return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
    status: 500,
    headers: { 'Content-Type': 'application/json' }
  })
}
```

## ⚡ SvelteKit-Specific Patterns

### Store Management
```typescript
// ✅ Functional store updates
export const updateTaskStore = (updater: (tasks: Task[]) => Task[]) =>
  taskStore.update(updater)

export const addTaskToStore = (task: Task) =>
  updateTaskStore(tasks => [...tasks, task])

export const removeTaskFromStore = (taskId: string) =>
  updateTaskStore(tasks => tasks.filter(t => t.id !== taskId))
```

### Component Logic
```typescript
// ✅ Extract business logic to pure functions
export const calculateProgress = (tasks: readonly Task[]): number => {
  const completed = tasks.filter(task => task.status === 'completed').length
  return tasks.length > 0 ? (completed / tasks.length) * 100 : 0
}

// ✅ Form validation as pure functions
export const validateTaskForm = (formData: FormData): Result<TaskData> => {
  const title = formData.get('title')?.toString()
  
  if (!title || title.trim().length === 0) {
    return { success: false, error: new Error('Title is required') }
  }
  
  return {
    success: true,
    data: { title: title.trim(), /* ... */ }
  }
}
```

## 📝 Function Naming Conventions

### Pure Functions
```typescript
// Verb + Noun (transformation/calculation)
const parseTaskDescription = (input: string): ParsedTask
const calculateDueDate = (days: number): Date
const formatTaskList = (tasks: Task[]): string

// Predicate functions start with is/has
const isTaskOverdue = (task: Task): boolean
const hasSubtasks = (task: Task): boolean

// Transformation functions start with to
const toTaskSummary = (task: Task): TaskSummary
const toJSON = (data: any): string
```

### Side Effect Functions
```typescript
// Start with verb, indicate side effects
const saveTaskToFile = async (task: Task): Promise<Result<void>>
const sendNotification = async (message: string): Promise<Result<void>>
const readConfigFromEnv = (): Config
const logTaskEvent = (event: TaskEvent): void
```

## 🚫 Prohibited Patterns

### Absolutely Forbidden
```typescript
// ❌ Class definitions are completely prohibited
class TaskManager { }
class APIService { }

// ❌ Using 'this' keyword is forbidden
function processTask() {
  this.status = 'processing' // NG
}

// ❌ Direct mutation of arrays/objects
const tasks = getTasks()
tasks.push(newTask) // NG
tasks[0].status = 'completed' // NG

// ❌ Variable reassignment with let (except loops)
let result = ''
result = processData() // NG (use const)
```

## 🛡️ Type Safety

### Mandatory Result Type Pattern
```typescript
export type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E }

// ✅ Use Result type for all fallible operations
export const parseJSON = (input: string): Result<any> => {
  try {
    const data = JSON.parse(input)
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error as Error }
  }
}
```

### Strict Type Definitions
```typescript
// ✅ Detailed type definitions
export interface TaskCreationData {
  readonly title: string
  readonly description?: string
  readonly priority: TaskPriority
  readonly dueDate?: string
}

// ✅ Read-only arrays
export const sortTasks = (tasks: readonly Task[]): readonly Task[] =>
  [...tasks].sort((a, b) => a.priority.localeCompare(b.priority))
```

## 🧪 Testing Strategy

### Pure Function Testing
```typescript
// ✅ Pure functions are easily testable
describe('calculateTaskPriority', () => {
  it('should return urgent for overdue tasks', () => {
    const task = createMockTask({ dueDate: '2023-01-01' })
    const currentTime = new Date('2023-01-02')
    
    const result = calculateTaskPriority(task, currentTime)
    
    expect(result).toBe('urgent')
  })
})
```

### Side Effect Testing
```typescript
// ✅ Test side effects in isolation
describe('saveTask', () => {
  it('should save task successfully', async () => {
    const task = createMockTask()
    
    // Use mock filesystem
    const result = await saveTask(task)
    
    expect(result.success).toBe(true)
  })
})
```

## 📦 Module Structure

### Export Strategy
```typescript
// ✅ Use only named exports
export const createTask = (data: TaskCreationData): Task => { }
export const updateTask = (task: Task, updates: Partial<Task>): Task => { }
export const deleteTask = (taskId: string): (tasks: Task[]) => Task[] => { }

// ✅ Group related functions
export const TaskFunctions = {
  create: createTask,
  update: updateTask,
  delete: deleteTask
} as const
```

### Import Strategy
```typescript
// ✅ Explicit imports
import { createTask, updateTask } from '../functions/task-functions'
import { Result, Task } from '../models/types'

// ✅ Namespace imports (for grouping)
import * as TaskFunctions from '../functions/task-functions'
```

---

**Important**: These rules apply without exception. When you want to use classes or mutable state, consider functional alternatives instead.