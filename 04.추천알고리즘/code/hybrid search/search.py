import os
import weaviate
import json

from dotenv import load_dotenv

load_dotenv()

WEAVIATE_CLUSTER_URL = os.getenv('WEAVIATE_CLUSTER_URL') or 'https://zxzyqcyksbw7ozpm5yowa.c0.us-west2.gcp.weaviate.cloud'
WEAVIATE_API_KEY = os.getenv('WEAVIATE_API_KEY') or 'n6mdfI32xrXF3DH76i8Pwc2IajzLZop2igb6'
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
COHERE_API_KEY = os.getenv('COHERE_API_KEY')

client = weaviate.Client(
    url=WEAVIATE_CLUSTER_URL,
    auth_client_secret=weaviate.AuthApiKey(api_key=WEAVIATE_API_KEY),
    additional_headers={"X-OpenAI-Api-Key": OPENAI_API_KEY, "X-Cohere-Api-Key": COHERE_API_KEY})

# nearText = {
#     "concepts":
#     ["혈액순환", "부추"]
# }
# generate_prompt = "Explain why this book might be interesting to someone who likes playing the violin, rock climbing, and doing yoga. the book's title is {recipe_name}, with a description: {summary}, and is in the genre: {category}."
# recipe_name,summary,ingredient_name,full_step,category,image_link

# response = (client.query.get("recipe", [
#     "recipe_name",
#     "summary",
#     "ingredient_name",
#     "full_step",
#     "category",
#     "image_link",
# ]).with_near_text(nearText).with_limit(4).do())
#.with_generate(single_prompt=generate_prompt).with_near_text(nearText).with_limit(10).do())

# hybrid search()
query = "혈액순환,부추"

response = (client.query.get("recipe", [
    "recipe_name",
    "summary",
    "ingredient_name",
    "full_step",
    "category",
    "image_link",
]).with_hybrid(query=query, alpha=0).with_limit(4).do())


print(json.dumps(response, indent=4, ensure_ascii=False))