import WebSocket from 'ws';

export default defineNitroPlugin(() => {
  if (typeof (globalThis as any).WebSocket === 'undefined') {
    (globalThis as any).WebSocket = WebSocket;
  }
});
