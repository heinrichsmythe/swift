// RUN: %target-swiftc_driver %s -target %sanitizers-target-triple -g -sanitize=thread %import-libdispatch -o %t_tsan-binary
// RUN: %target-codesign %t_tsan-binary
// RUN: %target-run %t_tsan-binary 2>&1 | %FileCheck %s
// REQUIRES: executable_test
// REQUIRES: tsan_runtime
// UNSUPPORTED: OS=tvos

// FIXME: This should be covered by "tsan_runtime"; older versions of Apple OSs
// don't support TSan.
// UNSUPPORTED: remote_run

import Dispatch

let sem = DispatchSemaphore(value: 0)
let q1 = DispatchQueue(label: "q1")
let q2 = DispatchQueue(label: "q2")

q1.async {
  var oneEmptyArray: [[String:String]] = []
  oneEmptyArray.append(contentsOf: [])
  sem.signal()
}
q2.async {
  var aCompletelyUnrelatedOtherEmptyArray: [[Double:Double]] = []
  aCompletelyUnrelatedOtherEmptyArray.append(contentsOf: [])
  sem.signal()
}

sem.wait()
sem.wait()
print("Done!")

// CHECK: Done!
