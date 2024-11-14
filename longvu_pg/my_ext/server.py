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
            result = inference_main(args)  # Now captures the return value

            await websocket.send(result)
    except websockets.exceptions.ConnectionClosedError:
        print(f"Connection closed by client {websocket.remote_address}")
    except Exception as e:
        print(f"Error handling connection from {websocket.remote_address}: {str(e)}")


async def main():
    async with serve(echo, "0.0.0.0", 6789) as server:
        await server.serve_forever()


if __name__ == "__main__":
    asyncio.run(main())