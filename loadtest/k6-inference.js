// k6 run -e TARGET=https://api.example.com loadtest/k6-inference.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  scenarios: { steady: { executor: 'constant-arrival-rate', rate: 20, timeUnit: '1s', duration: '15m', preAllocatedVUs: 50 } },
  thresholds: { http_req_failed: ['rate<0.005'], http_req_duration: ['p(95)<2000'] },
};

export default function () {
  const res = http.post(`${__ENV.TARGET}/v1/completions`,
    JSON.stringify({ model: 'default', prompt: 'Say hello in five words.', max_tokens: 16 }),
    { headers: { 'Content-Type': 'application/json' } });
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(0.1);
}
