import * as BunFileSystem from '@effect/platform-bun/BunFileSystem';
console.log('bare require.resolve:', require.resolve('@effect/platform-bun'));
console.log('OK BunFileSystem =', typeof BunFileSystem.layer);
