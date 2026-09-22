import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram
from diagrams.aws.database import Dynamodb, ElasticacheForRedis, RDSMysqlInstance, RDSPostgresqlInstance
from diagrams.programming.flowchart import PredefinedProcess as Blank

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("data-plane module", filename=os.path.join(_here, "generated", "data-plane-overview"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    root = Blank("data-plane")

    mysql = RDSMysqlInstance("catalog-mysql")
    ddb = Dynamodb("cart-dynamodb")
    redis = ElasticacheForRedis("checkout-redis")
    postgres = RDSPostgresqlInstance("orders-postgres")

    root >> [mysql, ddb, redis, postgres]
