import { default as connection } from "./connection.js";
import { default as plainSync } from "./plain-sync.js";
import { default as jsonSync } from "./json-sync.js";
import { default as binarySync } from "./binary-sync.js";

const vus = 64;
const duration = 5000;
const gracefulStop = "0s";

const scenarioConfig = {
  executor: "constant-vus",
  vus,
  duration,
  gracefulStop,
};

export const options = {
  thresholds: {},
  scenarios: {
    connectionScenario: Object.assign(
      {
        exec: "connectionScenario",
        startTime: duration * 0,
        tags: { exec: "connectionScenario" },
      },
      scenarioConfig
    ),
    plainSyncScenario: Object.assign(
      {
        exec: "plainSyncScenario",
        startTime: duration * 1,
        tags: { exec: "plainSyncScenario" },
      },
      scenarioConfig
    ),
    jsonSyncScenario: Object.assign(
      {
        exec: "jsonSyncScenario",
        startTime: duration * 2,
        tags: { exec: "jsonSyncScenario" },
      },
      scenarioConfig
    ),
    binarySyncScenario: Object.assign(
      {
        exec: "binarySyncScenario",
        startTime: duration * 3,
        tags: { exec: "binarySyncScenario" },
      },
      scenarioConfig
    ),
  },
};

export function connectionScenario() {
  connection();
}

export function plainSyncScenario() {
  plainSync();
}

export function jsonSyncScenario() {
  jsonSync();
}

export function binarySyncScenario() {
  binarySync();
}
