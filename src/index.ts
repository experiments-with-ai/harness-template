// Tracer bullet — a trivial function whose only job is to prove the harness loop
// (fmt → lint → test → build → CI green) works end to end. The cold-start flow
// (docs/bootstrap/cold-start.md) replaces this file when it provisions a real stack.

export function greet(name: string): string {
  return `Hello, ${name}!`
}
