# simple_server.py
import asyncio
import websockets
from inference import main as inference_main
import json
import argparse

class MockArgs:
    def __init__(self, video_path, question):
        self.video_path = video_path
        self.question = question

async def websocket_handler(websocket):
    print(f"New WebSocket connection from {websocket.remote_address}")
    try:
        while True:
            message = await websocket.recv()
            print(f"Received message from {websocket.remote_address}: {message}")
            
            try:
                # Parse the incoming message as JSON
                data = json.loads(message)
                video_path = data.get('video_path')
                question = data.get('question', "Describe this video in detail")

                # Create mock args object
                args = MockArgs(video_path, question)
                
                # Run inference and get result
                result = inference_main(args)  # Now captures the return value
                
                await websocket.send(result)  # Send the actual inference result
                print(f"Sent response to {websocket.remote_address}")
            except json.JSONDecodeError:
                await websocket.send("Error: Invalid JSON format")
            except Exception as e:
                await websocket.send(f"Error: {str(e)}")
                print(f"Error processing request: {str(e)}")

    except websockets.ConnectionClosed:
        print(f"Connection closed by client {websocket.remote_address}")
    finally:
        await websocket.close()
        print(f"Cleaned up connection from {websocket.remote_address}")

async def start_websocket_server():
    try:
        server = await websockets.serve(
            websocket_handler, 
            "0.0.0.0",  # Consider changing to "127.0.0.1" for local testing
            6789,
            ping_interval=20,  # Add heartbeat
            ping_timeout=30
        )
        print("WebSocket server started on ws://0.0.0.0:6789")
        await server.wait_closed()
    except Exception as e:
        print(f"Failed to start WebSocket server: {str(e)}")
        raise

async def main():
    websocket_server_task = asyncio.ensure_future(start_websocket_server())
    await asyncio.gather(websocket_server_task)

if __name__ == "__main__":
    asyncio.run(main())