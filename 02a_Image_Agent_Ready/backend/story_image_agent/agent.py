import json
import logging
from typing import AsyncGenerator

from google.adk.agents import BaseAgent, InvocationContext
from google.adk.runtime.events import Event

from story_image_agent.imagen_tool import ImagenTool


class CustomImageAgent(BaseAgent):
    """A custom agent for generating images directly using ImagenTool."""

    def __init__(self, imagen_tool: ImagenTool | None = None) -> None:
        super().__init__()
        self.imagen_tool = imagen_tool or ImagenTool()

    @property
    def name(self) -> str:
        return "custom_image_agent"

    async def _run_async_impl(
        self, ctx: InvocationContext
    ) -> AsyncGenerator[Event, None]:
        """Directly calls ImagenTool to generate an image based on user input."""
        logging.info("CustomImageAgent running...")

        if not ctx.user_content or not ctx.user_content.parts:
            error_message = "User content is empty."
            logging.error(error_message)
            ctx.session.state["image_result"] = {
                "success": False,
                "error": error_message,
            }
            yield Event(
                type="agent:thought",
                payload={"content": f"Error: {error_message}"},
            )
            return

        user_message = "".join(part.text for part in ctx.user_content.parts if hasattr(part, 'text'))

        try:
            # Assume user_message is a JSON string
            input_data = json.loads(user_message)
            scene_description = input_data.get("scene_description", "")
            character_descriptions = input_data.get("character_descriptions", {})
        except json.JSONDecodeError:
            # Fallback to using the whole message as the scene description
            logging.warning("Input is not a valid JSON. Treating as plain text.")
            scene_description = user_message
            character_descriptions = {}

        if not scene_description:
            error_message = "Scene description is missing."
            logging.error(error_message)
            ctx.session.state["image_result"] = {
                "success": False,
                "error": error_message,
            }
            yield Event(
                type="agent:thought",
                payload={"content": f"Error: {error_message}"},
            )
            return

        # Build the prompt
        style_prefix = "Children's book cartoon illustration with bright vibrant colors, simple shapes, friendly characters."
        
        character_details = []
        for name, desc in character_descriptions.items():
            character_details.append(f"{name}: {desc}")
        
        prompt = f"{style_prefix} {scene_description}"
        if character_details:
            prompt += " " + " ".join(character_details)

        yield Event(
            type="agent:thought",
            payload={"content": f"Generating image with prompt: {prompt}"},
        )

        try:
            # Directly call the tool
            image_result = await self.imagen_tool.run(prompt=prompt)
            
            # The result from ImagenTool is expected to be a JSON string
            # with image URLs.
            images = json.loads(image_result)

            ctx.session.state["image_result"] = {
                "success": True,
                "images": images,
            }
            yield Event(
                type="agent:result",
                payload={"content": json.dumps(ctx.session.state["image_result"])},
            )
            logging.info("Image generation successful.")

        except Exception as e:
            error_message = f"Failed to generate image: {e}"
            logging.exception(error_message)
            ctx.session.state["image_result"] = {
                "success": False,
                "error": error_message,
            }
            yield Event(
                type="agent:thought",
                payload={"content": f"Error: {error_message}"},
            )
