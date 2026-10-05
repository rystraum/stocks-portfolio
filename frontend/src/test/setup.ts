import "@testing-library/jest-dom/vitest"

// jsdom has no ResizeObserver; recharts (ResponsiveContainer) needs one to render.
if (typeof window !== "undefined" && !("ResizeObserver" in window)) {
  class ResizeObserverMock {
    observe() {}
    unobserve() {}
    disconnect() {}
  }
  window.ResizeObserver = ResizeObserverMock as unknown as typeof ResizeObserver
}
