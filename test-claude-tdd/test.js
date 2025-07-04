const { add } = require('./index.js');

console.log('🧪 Test suite executed by Claude Code hook!');

// Test that should pass
const result = add(2, 2);
if (result !== 4) {
  console.error('❌ Test failed: Expected 2 + 2 = 4, but got', result);
  process.exit(1);
}

// Additional test case for subtraction functionality
const { subtract } = require('./index.js');
const subtractResult = subtract(5, 3);
if (subtractResult !== 2) {
  console.error('❌ Test failed: Expected 5 - 3 = 2, but got', subtractResult);
  process.exit(1);
}

console.log('✅ All tests passed');