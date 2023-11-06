import { default as connection } from "./connection.js";
import { default as plainAsync } from "./plain-async.js";
import { default as plainSync } from "./plain-sync.js";
import { default as jsonAsync } from "./json-async.js";
import { default as jsonSync } from "./json-sync.js";
import { default as binaryAsync } from "./binary-async.js";
import { default as binarySync } from "./binary-sync.js";

const vus = 1;
const iterations = 1; // set to 1 because it have iterations per function
const maxDuration = "20s";

export const options = {
  thresholds: {},
  scenarios: {
    connectionScenario: {
      exec: "connectionScenario",
      executor: "constant-vus",
      vus,
      duration: "10s",
    },
    plainSyncScenario: {
      exec: "plainSyncScenario",
      executor: "per-vu-iterations",
      vus,
      iterations,
      maxDuration,
    },
    plainAsyncScenario: {
      exec: "plainAsyncScenario",
      executor: "per-vu-iterations",
      vus,
      iterations,
      maxDuration,
    },
    jsonSyncScenario: {
      exec: "jsonSyncScenario",
      executor: "per-vu-iterations",
      vus,
      iterations,
      maxDuration,
    },
    jsonAsyncScenario: {
      exec: "jsonAsyncScenario",
      executor: "per-vu-iterations",
      vus,
      iterations,
      maxDuration,
    },
    binarySyncScenario: {
      exec: "binarySyncScenario",
      executor: "per-vu-iterations",
      vus,
      iterations,
      maxDuration,
    },
    binaryAsyncScenario: {
      exec: "binaryAsyncScenario",
      executor: "per-vu-iterations",
      vus,
      iterations,
      maxDuration,
    },
  },
};

export function connectionScenario() {
  connection();
}

export function plainSyncScenario() {
  plainSync();
}

export function plainAsyncScenario() {
  plainAsync();
}

export function jsonSyncScenario() {
  jsonSync();
}

export function jsonAsyncScenario() {
  jsonAsync();
}

export function binarySyncScenario() {
  binarySync();
}

export function binaryAsyncScenario() {
  binaryAsync();
}
