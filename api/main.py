import subprocess
import os
import re
from pathlib import Path
from fastapi import FastAPI

app = FastAPI()

times_list = []


@app.get("/")
def read_root():
    return {
        "r file path": str(
            Path(
                Path(os.path.realpath(__file__)).parents[1], "src", "03_invoke_model.R"
            )
        )
    }


@app.get("/test/")
def test():
    ret = subprocess.run(
        [
            "Rscript",
            str(
                Path(
                    Path(os.path.realpath(__file__)).parents[1],
                    "src",
                    "03_invoke_model.R",
                )
            ),
            "15",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "0",
        ],
        capture_output=True,
    )

    prediction = None
    if "result" in ret.stdout.decode("ascii"):
        match = re.match(".*result=([0-9]*\.[0-9]*)", ret.stdout.decode("ascii"))
        if match is not None:
            prediction = match.group(0)
            print(prediction)

    return {
        "ret": ret,
        "prediction": prediction,
        "prediction_succeed": prediction is not None,
        "raw_stdout": ret.stdout.decode("ascii"),
    }


# @app.get("/predict/")
# def predict():


# @app.get("/items/{item_id}")
# def read_item(item_id: int, q: str = None):
#     return {"item_id": item_id, "q": q}


test = '[1] "result=45.4320640563965"\n'

