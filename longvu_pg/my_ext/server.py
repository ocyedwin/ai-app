#!/usr/bin/env python
import asyncio
import websockets
from websockets.asyncio.server import serve

from inference import main as inference_main
import json
import argparse

class MockArgs:
    def __init__(self, video_path, question):
        self.video_path = video_path
        self.question = question

async def echo(websocket):
    try:
        async for message in websocket:
            print(f"Received message from {websocket.remote_address}: {message}")
            data = json.loads(message)
            video_path = data.get('video_path')
            question = data.get('question')

            # Create mock args object
            args = MockArgs(video_path, question)
                
            # Run inference and get result
            result = inference_main(args)

            await websocket.send(result)
            print(f"Sent response to {websocket.remote_address}")
    except websockets.exceptions.ConnectionClosedError:
        print(f"Connection closed by client {websocket.remote_address}")
    except Exception as e:
        print(f"Error handling connection from {websocket.remote_address}: {str(e)}")
    finally:
        print(f"Connection finished with {websocket.remote_address}")


async def main():
    print("WebSocket server starting on ws://0.0.0.0:6789...")
    async with serve(echo, "0.0.0.0", 6789) as server:
        print("WebSocket server is running! Waiting for connections...")
        await server.serve_forever()


if __name__ == "__main__":
    asyncio.run(main())