import "@testing-library/jest-dom/vitest"
import { cleanup } from "@testing-library/react"
import { afterEach } from "vitest"

// Unmount rendered trees between tests so queries (which search document.body)
// never see leftovers from a previous test.
afterEach(() => {
  cleanup()
})

// jsdom has no ResizeObserver; recharts (ResponsiveContainer) needs one to render.
if (typeof window !== "undefined" && !("ResizeObserver" in window)) {
  class ResizeObserverMock {
    observe() {}
    unobserve() {}
    disconnect() {}
  }
  window.ResizeObserver = ResizeObserverMock as unknown as typeof ResizeObserver
}
