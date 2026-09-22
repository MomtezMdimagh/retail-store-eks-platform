import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram
from diagrams.aws.database import RDSPostgresqlInstance
from diagrams.aws.integration import SQS
from diagrams.aws.security import IAMRole
from diagrams.k8s.compute import Deployment

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("data-plane/orders-postgres module", filename=os.path.join(_here, "generated", "orders-postgres-module"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    pod = Deployment("orders")
    role = IAMRole("Pod Identity role")
    db = RDSPostgresqlInstance("orders-postgres")
    queue = SQS("orders + DLQ")

    pod >> role >> [db, queue]
