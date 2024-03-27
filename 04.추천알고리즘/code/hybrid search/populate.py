# pip install weaviate-client  --upgrade
import os
import csv
import weaviate

from dotenv import load_dotenv

load_dotenv()

WEAVIATE_CLUSTER_URL = os.getenv('WEAVIATE_CLUSTER_URL')
WEAVIATE_API_KEY = os.getenv('WEAVIATE_API_KEY')
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
COHERE_API_KEY = os.getenv('COHERE_API_KEY')

client = weaviate.Client(
    url=WEAVIATE_CLUSTER_URL,
    auth_client_secret=weaviate.AuthApiKey(api_key=WEAVIATE_API_KEY), 
    additional_headers={"X-OpenAI-Api-Key": OPENAI_API_KEY, "X-Cohere-Api-Key": COHERE_API_KEY})

client.schema.delete_class("Recipe")

class_obj = {
    "class": "Recipe",
    "vectorizer": "text2vec-openai",
    "moduleConfig": {
        "text2vec-openai": {
            "model": "ada",
            "modelVersion": "002",
            "type": "text"
        },
        "generative-cohere": {

        }
    }
}

client.schema.create_class(class_obj)

f = open("/Users/jiapannan/PycharmProjects/pythonProject/pythonProject/10.project/Final project/recommendation/weaviate_data.csv", "r")
current_recipe = None
try:
  with client.batch as batch:  # Initialize a batch process
    batch.batch_size = 100
    reader = csv.reader(f)
    # Iterate through each row of data
    for recipe in reader:
      current_recipe = recipe
      # 0 - recipe_name
      # 1 - summary
      # 2 - ingredient_name
      # 3 - full_step
      # 4 - category
      # 5 - image_link
       

      properties = {
        # recipe_name,summary,ingredient_name,full_step,category,image_link

          "recipe_name": recipe[0],
          "summary": recipe[1],
          "ingredient_name": recipe[2],
          "full_step": recipe[3],
          "category": recipe[4],
          "image_link": recipe[5],
      }

      batch.add_data_object(data_object=properties, class_name="Recipe")
      # print(f"{book[2]}: {uuid}", end='\n')
except Exception as e:
  print(f"something happened {e}. Failure at {current_recipe}")

f.close()


