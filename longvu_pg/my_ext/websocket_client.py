import asyncio
import websockets

async def hello():
    uri = "ws://127.0.0.1:6789"
    async with websockets.connect(uri) as websocket:
        await websocket.send("Hello world!")
        response = await websocket.recv()
        print(f"Received: {response}")

asyncio.run(hello())