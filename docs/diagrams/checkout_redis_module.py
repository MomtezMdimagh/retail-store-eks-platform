import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram
from diagrams.aws.database import ElasticacheForRedis
from diagrams.aws.security import IAMRole, SecretsManager
from diagrams.k8s.compute import Deployment

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("data-plane/checkout-redis module", filename=os.path.join(_here, "generated", "checkout-redis-module"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    pod = Deployment("checkout")
    role = IAMRole("Pod Identity role")
    cache = ElasticacheForRedis("checkout-redis")
    secret = SecretsManager("auth token")

    pod >> role >> [cache, secret]
