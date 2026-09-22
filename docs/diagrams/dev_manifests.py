import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram, Edge
from diagrams.aws.security import SecretsManager
from diagrams.programming.flowchart import PredefinedProcess as Blank
from diagrams.k8s.compute import Deployment

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("gitops/environments/dev/manifests (planned)",
             filename=os.path.join(_here, "generated", "dev-manifests"), show=False, direction="LR",
             graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    secret = SecretsManager("Secrets Manager")
    spc = Blank("SecretProviderClass")
    k8s_secret = Blank("K8s Secret")
    pod = Deployment("service pod")

    secret >> spc >> k8s_secret >> pod
