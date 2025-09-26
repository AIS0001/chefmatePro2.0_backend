const selectedDate = '2023-08-29';
const sqlExpression = `DATE(setup_date)='${selectedDate}'`;
const encoded = encodeURIComponent(sqlExpression);
const decoded = decodeURIComponent(encoded);

console.log('Original SQL:', sqlExpression);
console.log('Encoded:', encoded);
console.log('Decoded:', decoded);

// Test URL parsing like fetchData function does
const params = new URLSearchParams(decoded);
console.log('URL Parameters:');
for (const [key, value] of params.entries()) {
  console.log(`  ${key} = ${value}`);
}
