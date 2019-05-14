// RUN: %target-swiftc_driver %s -target %sanitizers-target-triple -g -sanitize=thread %import-libdispatch -o %t_tsan-binary
// RUN: %target-codesign %t_tsan-binary
// RUN: not %target-run %t_tsan-binary 2>&1 | %FileCheck %s
// REQUIRES: executable_test
// REQUIRES: tsan_runtime
// UNSUPPORTED: OS=tvos

// FIXME: This should be covered by "tsan_runtime"; older versions of Apple OSs
// don't support TSan.
// UNSUPPORTED: remote_run

// Test ThreadSanitizer execution end-to-end with libdispatch.

import Dispatch

let sem = DispatchSemaphore(value: 0)
let q = DispatchQueue.global(qos: .default)

var racy = 1

for _ in 1...1000 {
  q.async {
    racy = 2
    sem.signal()
  }
  q.async {
    racy = 3
    sem.signal()
  }
}

for _ in 1...2000 {
  sem.wait()
}

// CHECK: ThreadSanitizer: data race
